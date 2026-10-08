import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import * as T from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { setupRegistry, devices } from "../src/registry.js";
import { Traffic } from "../src/traffic.js";
import { narrative, counts, S, AR, SC } from "../src/narrative.js";
const bytes = readFileSync(
  new URL("../../assets/3Dmodel/AutoPolicy_Production.glb", import.meta.url),
);
const load = () =>
  new GLTFLoader().parseAsync(
    bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength),
    "",
  );
test("all 23 stages and intermediate reverse positions produce finite, history-independent state", () => {
  assert.deepEqual([S.length, AR.length, SC.length], [9, 9, 5]);
  for (const mode of Object.keys(counts)) {
    for (let i = 0; i <= 160; i++) {
      const p = i / 160,
        forward = narrative(mode, p);
      narrative(mode, 1);
      const reverse = narrative(mode, p);
      assert.deepEqual(reverse, forward);
      for (const [key, value] of Object.entries(forward))
        if (typeof value === "number")
          assert.ok(Number.isFinite(value), `${mode}.${key}@${p}`);
    }
  }
  assert.equal(narrative("sec", 0).roq, 0);
  assert.equal(narrative("sec", 1).iso, 1);
  assert.equal(narrative("sec", 1).enf, 1);
  assert.equal(narrative("sec", 1).zt, 1);
});
test("real GLB registry preserves world transforms and disables stage assets before first frame", async () => {
  const gltf = await load();
  gltf.scene.updateMatrixWorld(true);
  const before = new Map();
  gltf.scene.traverse((o) => before.set(o.name, o.matrixWorld.clone()));
  const r = setupRegistry(gltf.scene);
  gltf.scene.updateMatrixWorld(true);
  for (const [, prefix] of devices)
    for (const o of r.findObjectsByPrefix(prefix))
      assert.ok(
        o.matrixWorld.elements.every(
          (v, i) => Math.abs(v - before.get(o.name).elements[i]) < 1e-6,
        ),
        o.name + " shifted during parenting",
      );
  for (const o of r.objects.values())
    if (/^AP16/.test(o.name))
      assert.equal(o.visible, false, o.name + " should be hidden");
  assert.equal(r.requireObject("AP14C_Orb_NormalIndicator").visible, true);
});
test("all 21 Blender packet bodies animate; their 84 detailed children remain attached", async () => {
  const gltf = await load(),
    r = setupRegistry(gltf.scene),
    traffic = new Traffic(gltf.scene, r, gltf.animations);
  const before = new Map(
    traffic.packets.map((p) => [p.name, p.position.clone()]),
  );
  const offsets = Object.fromEntries(
    devices.map(([id]) => [id, new T.Vector3()]),
  );
  traffic.update(1, 1, narrative("explore", 0), offsets, false);
  assert.equal(traffic.packets.length, 21);
  assert.equal(gltf.animations.length, 78);
  for (const packet of traffic.packets) {
    assert.equal(packet.children.length, 4);
    assert.ok(
      packet.position.distanceTo(before.get(packet.name)) > 0.001,
      packet.name + " did not move",
    );
  }
  traffic.dispose();
});
test("enforcement keeps glass-sensor packets behind DENY; reverse restores clip ownership", async () => {
  const gltf = await load(),
    r = setupRegistry(gltf.scene),
    traffic = new Traffic(gltf.scene, r, gltf.animations),
    offsets = Object.fromEntries(devices.map(([id]) => [id, new T.Vector3()]));
  const state = narrative("sec", 0.8);
  traffic.update(0.016, 4, state, offsets, false);
  const barrier = r.getWorldCenter("AP16I_DENY_Barrier");
  for (const p of traffic.packets.filter(
    (p) => p.userData.autopolicy_route === "GlassSensor",
  ))
    assert.ok(p.position.x < barrier.x - 0.1, p.name + " crossed barrier");
  assert.equal(traffic.procedural, true);
  traffic.update(0.016, 4, narrative("explore", 0), offsets, false);
  assert.equal(traffic.procedural, false);
  traffic.dispose();
});

test("segmented permitted routes keep their actual core endpoints and isolated traffic restores", async () => {
  const gltf = await load(),
    r = setupRegistry(gltf.scene),
    traffic = new Traffic(gltf.scene, r, gltf.animations);
  const offsets = Object.fromEntries(
    devices.map(([id, , , zone]) => [
      id,
      new T.Vector3(zone === "A" ? -0.5 : zone === "B" ? 0.5 : 0, 0, 0),
    ]),
  );
  traffic.update(0.016, 3, narrative("explore", 1), offsets, false);
  for (const id of ["Camera", "Gateway", "Controller", "Cylinder", "Orb"]) {
    assert.ok(
      traffic.movingRoutes.get(id).at(-1).equals(traffic.routes.get(id).at(-1)),
      id + " endpoint left core",
    );
    assert.equal(traffic.bridges.get(id).visible, true);
  }
  const route = r.requireObject("GlassSensor_ContinuousSignal");
  assert.equal(r.list(route)[0].opacity, 0);
  for (const value of Object.values(offsets)) value.set(0, 0, 0);
  traffic.update(0.016, 3, narrative("explore", 0), offsets, false);
  assert.ok(r.list(route)[0].opacity > 0);
  assert.equal(traffic.bridges.get("Camera").visible, false);
  traffic.dispose();
});

test("procedural and reduced-motion traffic uses visible exported packet scale, not the 0.001 fade baseline", async () => {
  const gltf = await load(),
    r = setupRegistry(gltf.scene),
    traffic = new Traffic(gltf.scene, r, gltf.animations);
  const offsets = Object.fromEntries(
    devices.map(([id]) => [id, new T.Vector3()]),
  );
  traffic.update(0.016, 4, narrative("sec", 0.8), offsets, false);
  for (const p of traffic.packets.filter(
    (p) => p.userData.autopolicy_route !== "GlassSensor",
  ))
    assert.ok(p.scale.x > 0.1, p.name + " disappeared when its clip stopped");
  traffic.update(0.016, 4, narrative("sec", 0.8), offsets, true);
  for (const p of traffic.packets) assert.equal(p.scale.x, 1);
  traffic.update(0.016, 4, narrative("explore", 0), offsets, true);
  for (const p of traffic.packets)
    assert.ok(p.scale.x > 0.1, p.name + " invisible in reduced-motion hero");
  traffic.dispose();
});
