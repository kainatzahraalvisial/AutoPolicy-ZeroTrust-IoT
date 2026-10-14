import * as T from "three";
import { devices } from "./registry.js";

const COLORS = {
  lime: 0xc4e326,
  warm: 0xbcda27,
  gold: 0xc5c764,
  purple: 0x9d8df1,
  blue: 0xcfe6f2,
  red: 0xd92949,
};
const poolVertex =
  "varying vec2 vUv; void main(){vUv=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.);}";
const poolFragment = `varying vec2 vUv; uniform vec3 tint; uniform float gain;
  void main(){float d=length((vUv-.5)*2.);float a=exp(-d*d*5.)*(1.-smoothstep(.55,1.,d));
  gl_FragColor=vec4(tint*1.6,a*gain);}`;
const edgeSpillFragment = `varying vec2 vUv; uniform vec3 tint; uniform float gain;
  void main(){float d=abs((vUv.y-.5)*2.);float a=exp(-d*d*4.)*(1.-smoothstep(.65,1.,d));
  float ends=smoothstep(0.,.045,vUv.x)*(1.-smoothstep(.955,1.,vUv.x));
  gl_FragColor=vec4(tint*1.3,a*ends*gain);}`;
const beamFragment = `varying vec2 vUv; uniform vec3 tint; uniform float gain;
  void main(){float x=(vUv.x-.5)*2.;float side=exp(-x*x*9.)*(1.-smoothstep(.65,1.,abs(x)));
  float vertical=smoothstep(0.,.12,vUv.y)*(1.-smoothstep(.35,1.,vUv.y));
  gl_FragColor=vec4(tint*1.3,side*vertical*gain);}`;

// Geometry-derived runtime accents. The production model and narrative remain intact.
export class ArchitecturalLighting {
  constructor(model, registry) {
    this.model = model;
    this.r = registry;
    this.emissions = [];
    this.pools = [];
    this.beams = [];
    this.lights = [];
    this.owned = [];
    this.windows = [];
    this.platformEdges = [];
    this.glass = [];
    this.quality = "desktop";
    this.routes = [...registry.objects.values()].filter((o) =>
      /ContinuousSignal/.test(o.name),
    );
    this.scratch = new T.Vector3();
    this.createTowerWindowLighting();
    this.createPlatformUnderlighting();
    this.createDeviceLightAccents();
    this.createAtmosphericLightBeams();
  }
  bounds(o) {
    o.geometry.computeBoundingBox();
    return o.geometry.boundingBox.clone();
  }
  mark(o, category) {
    o.userData.apBloom = true;
    o.userData.apLightingCategory = category;
    return o;
  }
  rememberMaterial(o, material) {
    this.r.materials.set(material.uuid, {
      opacity: material.opacity,
      transparent: material.transparent,
      color: material.color?.clone(),
      emissive: material.emissive?.clone(),
      emissiveIntensity: material.emissiveIntensity,
      depthWrite: material.depthWrite,
    });
  }
  emit(o, color, intensity, category, device = null) {
    const source = this.r.list(o);
    const materials = source.map((m) => m.clone());
    o.material = materials.length === 1 ? materials[0] : materials;
    this.mark(o, category);
    for (const m of materials) {
      if (!m.emissive) continue;
      m.emissive.set(color);
      m.emissiveIntensity = intensity;
      this.rememberMaterial(o, m);
      this.emissions.push({
        m,
        color: new T.Color(color),
        intensity,
        category,
        device,
      });
    }
  }
  addMesh(parent, geometry, color, intensity, category) {
    const m = new T.MeshStandardMaterial({
      color,
      emissive: color,
      emissiveIntensity: intensity,
      roughness: 0.45,
      metalness: 0.08,
    });
    const mesh = this.mark(new T.Mesh(geometry, m), category);
    mesh.name = `runtime_lighting_${category}_${this.owned.length}`;
    mesh.raycast = () => {};
    parent.add(mesh);
    this.owned.push(mesh);
    this.emissions.push({ m, color: new T.Color(color), intensity, category });
    return mesh;
  }
  softPool(parent, center, width, depth, gain, category, device = null) {
    const material = new T.ShaderMaterial({
      transparent: true,
      depthWrite: false,
      blending: T.AdditiveBlending,
      side: T.DoubleSide,
      uniforms: {
        tint: { value: new T.Color(COLORS.lime) },
        gain: { value: gain },
      },
      vertexShader: poolVertex,
      fragmentShader: poolFragment,
    });
    const mesh = this.mark(
      new T.Mesh(new T.PlaneGeometry(width, depth), material),
      category,
    );
    mesh.name = `runtime_lighting_pool_${this.pools.length}`;
    mesh.position.copy(center);
    mesh.rotation.x = -Math.PI / 2;
    mesh.renderOrder = 2;
    mesh.raycast = () => {};
    parent.add(mesh);
    this.owned.push(mesh);
    this.pools.push({ mesh, gain, device, category });
  }
  perimeter(parent, box, y, color, intensity, category, inset = 0.045) {
    const size = box.getSize(new T.Vector3());
    const center = box.getCenter(new T.Vector3());
    const w = size.x - 2 * inset,
      d = size.z - 2 * inset;
    for (const z of [box.min.z + inset, box.max.z - inset]) {
      const strip = this.addMesh(
        parent,
        new T.BoxGeometry(w, 0.017, 0.023),
        color,
        intensity,
        category,
      );
      strip.position.set(center.x, y, z);
    }
    for (const x of [box.min.x + inset, box.max.x - inset]) {
      const strip = this.addMesh(
        parent,
        new T.BoxGeometry(0.023, 0.017, d),
        color,
        intensity,
        category,
      );
      strip.position.set(x, y, center.z);
    }
    // Corner emitters are recessed into the same local lip, not world-space lights.
    for (const x of [box.min.x + inset, box.max.x - inset])
      for (const z of [box.min.z + inset, box.max.z - inset]) {
        const corner = this.addMesh(
          parent,
          new T.BoxGeometry(0.065, 0.02, 0.065),
          color,
          intensity * 1.3,
          category,
        );
        corner.position.set(x, y, z);
      }
  }
  createTowerWindowLighting() {
    const windows = [...this.r.objects.values()].filter((o) =>
      /^AP14_(Front|Right)_WindowRecess_\d+$/.test(o.name),
    );
    if (windows.length !== 20)
      throw new Error(
        `Tower lighting requires 20 window recesses; found ${windows.length}.`,
      );
    // Fixed pattern; no random assignments or one-way animation events.
    const palette = [
      COLORS.warm,
      COLORS.blue,
      COLORS.lime,
      COLORS.purple,
      COLORS.gold,
      COLORS.blue,
      COLORS.warm,
      COLORS.blue,
      COLORS.purple,
      COLORS.lime,
    ];
    for (const o of windows) {
      const i = Number(o.name.slice(-2)) - 1;
      const right = o.name.includes("Right");
      const color = palette[(i + (right ? 3 : 0)) % palette.length];
      const lit = color !== COLORS.blue || i % 3 === 1;
      const glass = this.r.requireObject(
        o.name.replace("WindowRecess", "BlueGlass"),
      );
      glass.material = glass.material.clone();
      glass.material.transparent = true;
      glass.material.opacity = 0.28;
      glass.material.depthWrite = false;
      glass.material.roughness = 0.22;
      glass.castShadow = false;
      this.rememberMaterial(glass, glass.material);
      const b = this.bounds(glass),
        size = b.getSize(new T.Vector3());
      this.emit(o, lit ? color : 0x3e687d, lit ? 0.6 : 0.08, "windows");
      if (lit) {
        const pane = this.addMesh(
          glass,
          new T.PlaneGeometry((right ? size.z : size.x) * 0.96, size.y * 0.96),
          color,
          color === COLORS.purple ? 1.45 : 1.65,
          "windows",
        );
        // Between the opaque frame backing and the translucent window surface.
        if (right) {
          pane.rotation.y = Math.PI / 2;
          pane.position.x = (b.min.x + b.max.x) / 2 - 0.001;
        } else pane.position.z = (b.min.z + b.max.z) / 2 - 0.001;
        pane.material.side = T.DoubleSide;
        // Dark internal backing lets emission carry the window hue instead of
        // reflecting the studio environment into a white rectangle.
        pane.material.color.set(0x101b19);
        pane.material.metalness = 0;
        pane.material.roughness = 0.7;
      }
      this.windows.push({ name: o.name, color, lit });
    }
    for (const name of [
      "Core_Glass_Front",
      "Core_Glass_Back",
      "Core_Glass_Left",
      "Core_Glass_Right",
    ]) {
      const o = this.r.requireObject(name);
      o.material = o.material.clone();
      o.material.color.set(0x8ebacf);
      o.material.opacity = 0.09;
      o.material.transparent = true;
      o.material.depthWrite = false;
      o.material.metalness = 0;
      o.material.roughness = 0.22;
      o.material.emissive.set(0x527b94);
      o.material.emissiveIntensity = 0.015;
      o.castShadow = false;
      this.rememberMaterial(o, o.material);
      this.glass.push(o.material);
    }
    const roof = this.r.requireObject("Core_Roof");
    roof.material = roof.material.clone();
    roof.material.color.set(0x464d50);
    roof.material.metalness = 0.82;
    roof.material.roughness = 0.42;
    roof.material.emissiveIntensity = 0;
    this.perimeter(
      roof,
      this.bounds(roof),
      this.bounds(roof).max.y + 0.008,
      COLORS.purple,
      1.9,
      "roof-rim",
      0.035,
    );
    for (const o of this.r.objects.values()) {
      if (/^Core_LimeBand_1/.test(o.name))
        this.emit(o, COLORS.lime, 1.3, "foundation");
      if (/^Core_Intelligence_Light/.test(o.name))
        this.emit(o, COLORS.warm, 0.8, "windows");
      if (/^AP14_(Front|Right)_(Shield|Network)/.test(o.name))
        this.emit(o, o.material.color, 0.95, "logo");
    }
    const tower = this.r.requireObject("runtime_tower");
    const center = tower.worldToLocal(this.r.getWorldCenter("Core_Tower"));
    for (const [offset, color, intensity] of [
      [new T.Vector3(0.36, -0.9, 0.36), COLORS.lime, 2.0],
      [new T.Vector3(0.2, 0.6, -0.2), COLORS.purple, 0.8],
    ]) {
      const light = new T.PointLight(color, intensity, 3.2, 2);
      light.position.copy(center).add(offset);
      light.name = "runtime_lighting_interior";
      tower.add(light);
      this.lights.push({ light, intensity });
    }
  }
  createEdgeSpill(slab, receiving) {
    const b = this.bounds(slab),
      rb = this.bounds(receiving);
    const size = b.getSize(new T.Vector3());
    // Surface-local reflection ribbons aligned to the exported slab edges.
    for (const [axis, sign] of [
      ["x", -1],
      ["x", 1],
      ["z", -1],
      ["z", 1],
    ]) {
      const alongX = axis === "z";
      const point = new T.Vector3(0, b.min.y, 0);
      point[axis] = sign < 0 ? b.min[axis] : b.max[axis];
      slab.localToWorld(point);
      receiving.worldToLocal(point);
      point.y = rb.max.y + 0.006;
      const material = new T.ShaderMaterial({
        transparent: true,
        depthWrite: false,
        blending: T.AdditiveBlending,
        side: T.DoubleSide,
        uniforms: {
          tint: { value: new T.Color(COLORS.lime) },
          gain: { value: 0.65 },
        },
        vertexShader: poolVertex,
        fragmentShader: edgeSpillFragment,
      });
      const mesh = new T.Mesh(
        new T.PlaneGeometry(alongX ? size.x : size.z, 0.56),
        material,
      );
      mesh.name = `runtime_lighting_edge_spill_${this.pools.length}`;
      mesh.position.copy(point);
      mesh.rotation.set(-Math.PI / 2, 0, alongX ? 0 : Math.PI / 2);
      mesh.raycast = () => {};
      receiving.add(mesh);
      this.owned.push(mesh);
      this.pools.push({ mesh, gain: 0.65, category: "edge-spill" });
    }
  }
  createPlatformUnderlighting() {
    // Enhance the eight actual exported hardware strips, keeping their geometry,
    // transforms and gold structural detailing everywhere else intact.
    for (const step of ["01", "02"])
      for (const face of ["Front", "Back", "Left", "Right"]) {
        const name = `Step${step}_LimeEdge_${face}`;
        const strip = this.r.requireObject(name);
        this.emit(strip, 0x80a416, 2.3, "exported-platform-edges");
        strip.material.color.set(0x80a416);
        this.rememberMaterial(strip, strip.material);
        this.platformEdges.push(name);
      }
    for (const name of ["Core_Step_01", "Core_Step_02", "Core_Glass_Base"]) {
      const slab = this.r.requireObject(name),
        b = this.bounds(slab);
      this.perimeter(
        slab,
        b,
        b.min.y + 0.018,
        COLORS.warm,
        1.45,
        "underlighting",
        -0.005,
      );
      // A feathered reflection proxy on the receiving slab beneath this lip.
      const receiving =
        name === "Core_Step_02"
          ? this.r.requireObject("Core_Step_01")
          : name === "Core_Step_01"
            ? this.r.requireObject("Core_Glass_Base")
            : null;
      if (receiving) {
        this.createEdgeSpill(slab, receiving);
      }
    }
    for (const name of ["Zone_A", "Zone_Core", "Zone_B"]) {
      const slab = this.r.requireObject(name),
        b = this.bounds(slab);
      this.perimeter(
        slab,
        b,
        b.min.y + 0.025,
        COLORS.lime,
        0.8,
        "zone-lighting",
        -0.004,
      );
    }
  }
  createDeviceLightAccents() {
    for (const [id, prefix, anchor, zone] of devices) {
      const root = this.r.getDeviceRoot(id),
        source = this.r.requireObject(anchor);
      const bound = new T.Box3().setFromObject(source),
        p = bound.getCenter(new T.Vector3());
      p.y = this.r.getWorldBounds("Zone_" + zone).max.y + 0.005;
      root.worldToLocal(p);
      this.softPool(
        root,
        p,
        id === "Cylinder" ? 0.85 : 0.65,
        id === "Cylinder" ? 0.85 : 0.65,
        id === "Cylinder" ? 0.28 : 0.14,
        "device-lights",
        id,
      );
      for (const o of this.r.findObjectsByPrefix(prefix)) {
        if (
          /StatusLED|StatusBand|TopIndicator|NormalIndicator|GreenIndicator/.test(
            o.name,
          )
        )
          this.emit(
            o,
            COLORS.lime,
            id === "Cylinder" ? 2.8 : 1.55,
            "device-lights",
            id,
          );
      }
    }
    for (const o of this.r.objects.values()) {
      if (
        /^AP14[B-CF-K]_.*(LED|Status|Indicator|LightStrip)/.test(o.name) &&
        !/GlassSensor|Orb_Anomal|Orb_Red|Decision|ALLOW/.test(o.name)
      )
        if (!o.userData.apLightingCategory)
          this.emit(o, COLORS.lime, 1.2, "device-lights");
      if (/ContinuousSignal/.test(o.name)) {
        o.userData.apBloom = true;
        o.userData.apLightingCategory = "traffic";
      }
      if (/AP15A_Packet_/.test(o.name)) this.mark(o, "packets");
      if (
        /^AP16.*(Warning|ALLOW|DENY|Status|Accent)/.test(o.name) &&
        o.isMesh &&
        this.r.list(o).some((m) => m.emissiveIntensity > 0.05)
      )
        this.mark(o, "anomaly");
    }
  }
  createAtmosphericLightBeams() {
    const tower = this.r.requireObject("runtime_tower");
    const core = tower.worldToLocal(this.r.getWorldCenter("Core_Tower"));
    for (const [i, width, height, x, z] of [
      [0, 0.8, 5.2, -1.3, -1.6],
      [1, 0.48, 5.7, -0.3, -1.7],
      [2, 0.65, 4.8, 0.75, -1.8],
      [3, 0.45, 5.3, 1.6, -0.9],
    ]) {
      const material = new T.ShaderMaterial({
        transparent: true,
        depthWrite: false,
        depthTest: true,
        blending: T.AdditiveBlending,
        side: T.DoubleSide,
        uniforms: {
          tint: { value: new T.Color(COLORS.warm) },
          gain: { value: 0.1 },
        },
        vertexShader: poolVertex,
        fragmentShader: beamFragment,
      });
      const mesh = this.mark(
        new T.Mesh(new T.PlaneGeometry(width, height), material),
        "beams",
      );
      mesh.name = `runtime_lighting_beam_${i}`;
      mesh.position.set(core.x + x, core.y - 1.5 + height / 2, core.z + z);
      mesh.renderOrder = 1;
      mesh.raycast = () => {};
      tower.add(mesh);
      this.owned.push(mesh);
      this.beams.push(mesh);
    }
  }
  setLightingQuality(level) {
    this.quality = level;
    this.beams.forEach((o, i) => {
      o.visible = i < (level === "mobile" ? 1 : level === "tablet" ? 2 : 4);
    });
    this.lights.forEach(({ light }, i) => {
      light.visible = level !== "mobile" || i === 0;
    });
  }
  updateLightingForNarrative(state, t, camera, dark, reduced) {
    const brightness = dark ? 1 : 0.78;
    for (const entry of this.emissions) {
      const alert = entry.device === "GlassSensor" && state.roq > 0.1;
      entry.m.emissive.copy(entry.color);
      if (alert) entry.m.emissive.set(COLORS.red);
      entry.m.emissiveIntensity = entry.intensity * brightness * (!dark && entry.category === "roof-rim" ? 1.15 : 1);
    }
    for (const { mesh, gain, device } of this.pools) {
      const alert = device === "GlassSensor" && state.roq > 0.1;
      mesh.material.uniforms.tint.value.set(alert ? COLORS.red : COLORS.lime);
      mesh.material.uniforms.gain.value = gain * brightness;
    }
    this.lights.forEach(({ light, intensity }) => {
      light.intensity = intensity * brightness;
    });
    this.glass.forEach((m) => {
      m.opacity = dark ? 0.09 : 0.075;
    });
    const tower = this.r.requireObject("runtime_tower");
    this.scratch.copy(camera.position);
    tower.worldToLocal(this.scratch);
    for (const [i, mesh] of this.beams.entries()) {
      mesh.rotation.y = Math.atan2(
        this.scratch.x - mesh.position.x,
        this.scratch.z - mesh.position.z,
      );
      mesh.material.uniforms.gain.value =
        (reduced ? 0.085 : 0.085 + 0.01 * Math.sin(t * 0.45 + i)) * brightness;
    }
    // Existing signals retain their engineered paths and threat-state hue.
    for (const o of this.routes)
      for (const m of this.r.list(o))
        if (m.emissive)
          m.emissiveIntensity =
            (1.65 + (reduced ? 0 : 0.12 * Math.sin(t * 1.7))) * brightness;
  }
  diagnostics() {
    return {
      windows: this.windows,
      exportedPlatformEdges: this.platformEdges,
      runtimeMeshes: this.owned.length,
      beams: this.beams.filter((o) => o.visible).length,
      localLights: this.lights.filter((o) => o.light.visible).length,
      quality: this.quality,
      categories: [...new Set(this.emissions.map((e) => e.category))],
    };
  }
  dispose() {
    this.owned.forEach((o) => {
      o.removeFromParent();
      o.geometry.dispose();
      o.material.dispose();
    });
    this.lights.forEach(({ light }) => {
      light.removeFromParent();
      light.dispose();
    });
    this.owned.length = 0;
  }
}
