import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import * as T from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { setupRegistry } from "../src/registry.js";
import { ArchitecturalLighting } from "../src/architectural-lighting.js";
import { narrative } from "../src/narrative.js";
const bytes = readFileSync(
  new URL("../../assets/3Dmodel/AutoPolicy_Production.glb", import.meta.url),
);
async function fixture() {
  const gltf = await new GLTFLoader().parseAsync(
    bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength),
    "",
  );
  const r = setupRegistry(gltf.scene);
  return {
    model: gltf.scene,
    r,
    lighting: new ArchitecturalLighting(gltf.scene, r),
  };
}
test("production windows remain separate, translucent and behind their original glass faces", async () => {
  const { r, lighting } = await fixture();
  assert.equal(lighting.windows.length, 20);
  assert.ok(new Set(lighting.windows.map((w) => w.color)).size >= 4);
  for (const w of lighting.windows) {
    const glass = r.requireObject(w.name.replace("WindowRecess", "BlueGlass"));
    assert.ok(glass.material.transparent);
    if (!w.lit) continue;
    const panel = glass.children.find((c) =>
      c.name.startsWith("runtime_lighting_windows"),
    );
    assert.ok(panel);
    const normal = w.name.includes("Right") ? "x" : "z";
    const frame = r.requireObject(
      w.name.replace("WindowRecess", "WindowFrame"),
    );
    frame.geometry.computeBoundingBox();
    glass.geometry.computeBoundingBox();
    const position = panel.getWorldPosition(new T.Vector3());
    const front = new T.Vector3();
    front[normal] = frame.geometry.boundingBox.max[normal];
    frame.localToWorld(front);
    const surface = new T.Vector3();
    surface[normal] = glass.geometry.boundingBox.max[normal];
    glass.localToWorld(surface);
    assert.ok(
      position[normal] > front[normal] && position[normal] < surface[normal],
    );
  }
  assert.equal(r.requireObject("Core_Roof").material.emissiveIntensity, 0);
  lighting.dispose();
});
test("attached light accents follow tower, zones and isolated devices and return exactly", async () => {
  const { model, r, lighting } = await fixture();
  const controls = [
    r.requireObject("runtime_tower"),
    r.requireObject("runtime_zone_A"),
    r.getDeviceRoot("GlassSensor"),
  ];
  const meshes = controls.map((parent) => {
    let found;
    parent.traverse((o) => {
      if (!found && o.name.startsWith("runtime_lighting_")) found = o;
    });
    return found;
  });
  model.updateMatrixWorld(true);
  const positions = meshes.map((o) => o.getWorldPosition(new T.Vector3()));
  const starts = controls.map((o) => o.position.clone());
  controls.forEach((o, i) => o.position.add(new T.Vector3(i + 0.5, 1, 0)));
  model.updateMatrixWorld(true);
  meshes.forEach((o, i) =>
    assert.ok(
      o.getWorldPosition(new T.Vector3()).distanceTo(positions[i]) > 0.5,
    ),
  );
  controls.forEach((o, i) => o.position.copy(starts[i]));
  model.updateMatrixWorld(true);
  meshes.forEach((o, i) =>
    assert.ok(
      o.getWorldPosition(new T.Vector3()).distanceTo(positions[i]) < 1e-6,
    ),
  );
  const camera = new T.PerspectiveCamera();
  camera.position.set(8, 8, 8);
  const count = lighting.owned.length;
  lighting.updateLightingForNarrative(
    narrative("explore", 0),
    0,
    camera,
    true,
    true,
  );
  const before = lighting.emissions.map((e) => [
    e.m.emissive.getHex(),
    e.m.emissiveIntensity,
  ]);
  for (let i = 0; i < 100; i++)
    lighting.updateLightingForNarrative(
      narrative("sec", i / 99),
      i,
      camera,
      true,
      true,
    );
  lighting.updateLightingForNarrative(
    narrative("explore", 0),
    0,
    camera,
    true,
    true,
  );
  assert.deepEqual(
    lighting.emissions.map((e) => [
      e.m.emissive.getHex(),
      e.m.emissiveIntensity,
    ]),
    before,
  );
  assert.equal(lighting.owned.length, count);
  lighting.setLightingQuality("mobile");
  assert.equal(lighting.diagnostics().beams, 1);
  assert.equal(lighting.diagnostics().localLights, 1);
  lighting.setLightingQuality("tablet");
  assert.equal(lighting.diagnostics().beams, 2);
  lighting.setLightingQuality("desktop");
  assert.equal(lighting.diagnostics().beams, 4);
  const owned = [...lighting.owned];
  lighting.dispose();
  assert.ok(owned.every((o) => !o.parent));
});

// Validate the production mesh identities as well as the new light placement.
test("lighting preserves exported tower geometry and illuminates all eight original step strips", async () => {
  const gltf = await new GLTFLoader().parseAsync(
    bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength),
    "",
  );
  const r = setupRegistry(gltf.scene);
  const names = [
    "Core_Tower",
    "Core_Roof",
    "Core_Glass_Base",
    "Core_Step_01",
    "Core_Step_02",
    ...r.findObjectsByPrefix("AP14_Front_Window").map((o) => o.name),
    ...r.findObjectsByPrefix("AP14_Right_Window").map((o) => o.name),
  ];
  const original = names.map((name) => {
    const o = r.requireObject(name);
    return { o, geometry: o.geometry, world: o.matrixWorld.clone() };
  });
  const edges = ["01", "02"].flatMap((step) =>
    ["Front", "Back", "Left", "Right"].map((face) =>
      r.requireObject(`Step${step}_LimeEdge_${face}`),
    ),
  );
  const edgeGeometry = edges.map((o) => o.geometry);
  const lighting = new ArchitecturalLighting(gltf.scene, r);
  gltf.scene.updateMatrixWorld(true);
  original.forEach(({ o, geometry, world }) => {
    assert.equal(o.geometry, geometry);
    assert.deepEqual(o.matrixWorld.elements, world.elements);
  });
  assert.equal(lighting.platformEdges.length, 8);
  edges.forEach((o, i) => {
    assert.equal(o.geometry, edgeGeometry[i]);
    assert.ok(o.material.emissiveIntensity > 1);
    assert.equal(o.userData.apBloom, true);
  });
  const spills = lighting.pools.filter((p) => p.category === "edge-spill");
  assert.equal(spills.length, 8);
  for (const { mesh } of spills) {
    mesh.parent.geometry.computeBoundingBox();
    assert.ok(
      Math.abs(
        mesh.position.y - mesh.parent.geometry.boundingBox.max.y - 0.006,
      ) < 1e-6,
    );
    assert.ok(mesh.position.x !== 0 || mesh.position.z !== 0);
  }
  assert.ok(!lighting.owned.some((o) => /tower/i.test(o.name)));
  lighting.dispose();
});
