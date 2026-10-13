import * as T from "three";
import { clamp, sm } from "./narrative.js";
export function routePoint(points, u, out) {
  const lengths = [0];
  let total = 0;
  for (let i = 1; i < points.length; i++) {
    total += points[i].distanceTo(points[i - 1]);
    lengths.push(total);
  }
  const distance = clamp(u) * total;
  let i = 1;
  while (i < points.length - 1 && lengths[i] < distance) i++;
  const f = (distance - lengths[i - 1]) / (lengths[i] - lengths[i - 1] || 1);
  out.copy(points[i - 1]).lerp(points[i], f);
  return new T.Vector3().subVectors(points[i], points[i - 1]).normalize();
}
export class Traffic {
  constructor(root, registry, clips) {
    this.r = registry;
    this.mixer = new T.AnimationMixer(root);
    this.packets = registry.findObjectsByPrefix("AP15A_Packet_");
    this.actions = new Map();
    this.procedural = false;
    this.routes = new Map();
    this.movingRoutes = new Map();
    this.bridges = new Map();
    this.time = 0;
    if (this.packets.length !== 21)
      throw new Error(
        `Expected 21 packet bodies, found ${this.packets.length}`,
      );
    for (const clip of clips) {
      const action = this.mixer.clipAction(clip);
      action.play();
      this.actions.set(clip.name, action);
    }
    for (const p of this.packets) {
      if (!this.actions.has(p.name))
        throw new Error(`Missing animation clip for packet ${p.name}`);
    }
    for (const id of [
      "Camera",
      "Gateway",
      "GlassSensor",
      "Controller",
      "Cylinder",
      "Embedded",
      "Orb",
    ]) {
      const metadata = registry.requireObject("TrafficRoute_" + id).userData;
      if (!metadata.waypoints_xy)
        throw new Error(`TrafficRoute_${id} has no exported route waypoints`);
      const pts = JSON.parse(metadata.waypoints_xy).map(
        (p) => new T.Vector3(p[0], metadata.route_height + 0.072, -p[1]),
      );
      this.routes.set(id, pts);
      this.movingRoutes.set(id, [
        ...pts.map((v) => v.clone()),
        pts.at(-1).clone(),
      ]);
      const geometry = new T.BufferGeometry();
      geometry.setAttribute(
        "position",
        new T.BufferAttribute(new Float32Array(6), 3),
      );
      const bridge = new T.Line(
        geometry,
        new T.LineBasicMaterial({
          color: 0xc4e326,
          transparent: true,
          opacity: 0.65,
        }),
      );
      bridge.name = "runtime_" + id + "_SignalBridge";
      bridge.frustumCulled = false;
      root.add(bridge);
      this.bridges.set(id, bridge);
      if (
        this.packets.filter((p) => p.userData.autopolicy_route === id)
          .length !== 3
      )
        throw new Error(`Route ${id} must have three packets`);
    }
    this.visualScales = new Map(
      this.packets.map((p) => {
        const track = clips
          .find((c) => c.name === p.name)
          .tracks.find((t) => t.name.endsWith(".scale"));
        if (!track)
          throw new Error(`Packet ${p.name} has no exported scale track`);
        const peak = Math.max(...track.values);
        return [p.name, new T.Vector3(peak, peak, peak)];
      }),
    );
    this.probe = new T.Vector3();
    this.baseRotations = new Map(
      this.packets.map((p) => [p.name, p.quaternion.clone()]),
    );
  }
  update(dt, time, state, offsets, reduced) {
    this.time = time;
    const procedural =
      state.enf > 0.02 ||
      state.zt > 0.02 ||
      state.iso > 0.02 ||
      state.roq > 0.02;
    if (procedural !== this.procedural) {
      this.procedural = procedural;
      for (const p of this.packets) {
        const action = this.actions.get(p.name);
        if (procedural) action.stop();
        else action.reset().play();
      }
    }
    if (!reduced) this.mixer.update(dt);
    else this.mixer.setTime(1.5);
    for (const [id, points] of this.routes) {
      const offset = offsets[id];
      const moved = this.movingRoutes.get(id);
      points.forEach((v, i) => moved[i].copy(v).add(offset));
      moved.at(-1).copy(points.at(-1));
      const bridge = this.bridges.get(id);
      const array = bridge.geometry.attributes.position.array;
      moved.at(-2).toArray(array, 0);
      moved.at(-1).toArray(array, 3);
      bridge.geometry.attributes.position.needsUpdate = true;
      bridge.visible =
        state.zt > 0.02 && id !== "GlassSensor" && id !== "Embedded";
      const route = this.r.requireObject("TrafficRoute_" + id);
      this.r.setMaterialOpacity(
        route.name,
        id === "GlassSensor" ? 1 - Math.max(state.iso, state.zt) : 1,
      );
      if (id === "GlassSensor")
        route.traverse((o) => {
          if (o.isMesh && /ContinuousSignal/.test(o.name))
            for (const m of this.r.list(o))
              if (m.emissive) {
                m.emissive.set(state.roq > 0.1 ? 0xd92949 : 0xc4e326);
              }
        });
    }
    for (const p of this.packets) {
      const id = p.userData.autopolicy_route,
        anomaly = id === "GlassSensor",
        offset = offsets[id] || new T.Vector3();
      p.visible = state.hero || state.obs > 0.05;
      if (procedural) {
        const pts = this.movingRoutes.get(id);
        let u = reduced
          ? 0.35
          : (time / 10.0417 + ((p.userData.packet_index || 1) - 1) / 3) % 1;
        const fade = reduced ? 1 : sm(0, 0.06, u) * (1 - sm(0.94, 1, u));
        p.scale.copy(this.visualScales.get(p.name)).multiplyScalar(fade);
        if (anomaly && state.roq > 0.1)
          u = clamp(u + Math.sin(time * 5) * 0.025 * state.roq);
        if (anomaly && state.enf > 0.45) {
          const checkpoint = this.r.getWorldCenter("AP16I_DENY_Barrier");
          const start = pts[0].x,
            end = pts.at(-1).x;
          const stop = clamp((checkpoint.x - 0.14 - start) / (end - start));
          u *= stop;
          p.visible = p.visible && u < stop - 0.008 && state.iso < 0.45;
        }
        const tangent = routePoint(pts, u, this.probe);
        p.position.copy(this.probe);
        p.quaternion.copy(this.baseRotations.get(p.name));
        p.rotation.y = Math.atan2(-tangent.z, tangent.x);
      }
      p.traverse((o) => {
        if (!o.isMesh) return;
        for (const m of this.r.list(o)) {
          const base = this.r.materials.get(m.uuid);
          if (!m.emissive || !base) continue;
          const color =
            anomaly && state.roq > 0.1
              ? "#D92949"
              : o.name.includes("LeadingIndicator")
                ? "#FFEDA8"
                : "#C4E326";
          if (base.emissiveIntensity > 0.05) {
            m.emissive.set(color);
            m.emissiveIntensity = Math.min(
              2.0,
              base.emissiveIntensity * (1.4 + 0.3 * state.ins),
            );
          }
        }
      });
    }
  }
  dispose() {
    for (const bridge of this.bridges.values()) {
      bridge.geometry.dispose();
      bridge.material.dispose();
      bridge.removeFromParent();
    }
    this.mixer.stopAllAction();
    this.mixer.uncacheRoot(this.mixer.getRoot());
  }
  diagnostics() {
    return {
      packetCount: this.packets.length,
      routeCount: this.routes.size,
      clipCount: this.actions.size,
      packetModes: this.procedural ? "procedural" : "exported-clips",
      packets: this.packets.map((p) => ({
        name: p.name,
        position: p.position.toArray(),
        visible: p.visible,
        scale: p.scale.toArray(),
        children: p.children.length,
      })),
    };
  }
}
