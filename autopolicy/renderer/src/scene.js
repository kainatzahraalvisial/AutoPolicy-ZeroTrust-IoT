import * as T from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";
import { EffectComposer } from "three/addons/postprocessing/EffectComposer.js";
import { RenderPass } from "three/addons/postprocessing/RenderPass.js";
import { UnrealBloomPass } from "three/addons/postprocessing/UnrealBloomPass.js";
import { ShaderPass } from "three/addons/postprocessing/ShaderPass.js";
import { OutputPass } from "three/addons/postprocessing/OutputPass.js";
import { setupRegistry, devices } from "./registry.js";
import { Traffic } from "./traffic.js";
import { narrative, sm, clamp, counts } from "./narrative.js";
const canvas = document.getElementById("scene"),
  session = new URLSearchParams(location.search).get("session") || "native";
const send = (type, data = {}) => {
  canvas.dataset.event = type;
  if (type === "MODEL_ERROR") canvas.dataset.error = data.message;
  if (type === "MODEL_READY") canvas.dataset.ready = "true";
  const message = { protocol: "autopolicy.v1", session, type, data };
  if (window.flutter_inappwebview)
    window.flutter_inappwebview.callHandler("AutoPolicy", message);
  else if (window.parent !== window)
    window.parent.postMessage(message, location.origin);
};
let scene,
  renderer,
  camera,
  model,
  r,
  traffic,
  composer,
  bloomComposer,
  bloom,
  envTarget,
  pmrem,
  clock,
  frameId,
  disposed = false,
  ready = false,
  interaction = true,
  renderingEnabled = true,
  reduced = false,
  dark = true;
let viewportClass = "desktop",
  spread = 1;
let mode = "explore",
  target = 0,
  progress = 0,
  current = null,
  lastStatus = 0,
  time = 0,
  hover = null,
  selected = null;
let telemetry;
const telemetryPositions = new Float32Array(63),
  telemetryTarget = new T.Vector3(),
  featureTarget = new T.Vector3();
const roots = {},
  groups = {},
  offsets = {},
  graphEdges = [],
  evidence = [],
  labels = [],
  scratch = new T.Vector3(),
  projected = new T.Vector3();
const graphPairs = [
  [0, 1],
  [1, 2],
  [0, 2],
  [3, 4],
  [4, 6],
  [3, 6],
  [5, 3],
  [5, 0],
  [0, 9],
  [3, 9],
  [2, 9],
  [9, 10],
];
const policyNames = [
  "AP16H_CTRL_01_EVIDENCE",
  "AP16H_CTRL_02_POLICY_SYNTHESIS",
  "AP16H_CTRL_03_ENFORCEABLE_POLICY",
];
const layerNames = [
  "AP16B_CTRL_01_CAPTURE",
  "AP16B_CTRL_02_TELEMETRY",
  "AP16B_CTRL_03_INTELLIGENCE",
  "AP16B_CTRL_04_POLICY",
];
const moduleNames = [
  "TrafficObservation_Base",
  "Zeek_Base",
  "Feature_Base",
  "MLGNN_Base",
  "Transformer_Base",
  "OPA_Base",
];
const modulePrefixes = [
  "AP14G_",
  "AP14H_",
  "AP14I_",
  "AP14F_",
  "AP14J_",
  "AP14K_",
];
const raycaster = new T.Raycaster(),
  pointer = new T.Vector2(),
  black = new T.MeshBasicMaterial({ color: 0 }),
  savedMaterials = new Map();
let heroBounds,
  heroCenter,
  sceneScale = 1,
  zoneGap = 0.55;
function reveal(name, amount) {
  const object = r.requireObject(name);
  object.traverse((o) => (o.visible = true));
  object.visible = amount > 0.008;
  r.setMaterialOpacity(name, clamp(amount));
  return object;
}
function basePosition(o) {
  return r.base(o).position;
}
function tone(name, color, intensity) {
  r.setEmissiveState(name, color, intensity);
}
function move(o, x = 0, y = 0, z = 0) {
  o.position.copy(basePosition(o)).add(scratch.set(x, y, z));
}
function receive(message) {
  if (message?.protocol !== "autopolicy.v1" || message.session !== session)
    return;
  const d = message.data || {};
  switch (message.type) {
    case "SET_CHAPTER":
      if (!counts[d.chapter]) return;
      selected = hover = null;
      send("DEVICE_SELECTED", { device: null });
      mode = d.chapter;
      target = progress = 0;
      current = narrative(mode, 0);
      break;
    case "SET_PROGRESS":
      target = clamp(Number(d.progress) || 0);
      break;
    case "GOTO_STAGE":
      target = clamp(Number(d.stage) / (counts[mode] - 1));
      break;
    case "SET_VIEWPORT":
      viewportClass = d.class || "desktop";
      spread = /mobile/.test(viewportClass)
        ? 0.62
        : /tablet|Compact/.test(viewportClass)
          ? 0.78
          : 1;
      canvas.dataset.viewportClass = viewportClass;
      break;
    case "SET_THEME":
      dark = d.dark !== false;
      if (ready) theme();
      break;
    case "SET_INTERACTION_ENABLED":
      interaction = d.enabled !== false;
      break;
    case "SET_RENDERING_ENABLED":
      if (renderingEnabled === (d.enabled !== false)) break;
      renderingEnabled = d.enabled !== false;
      canvas.dataset.renderingEnabled = String(renderingEnabled);
      if (!renderingEnabled) cancelAnimationFrame(frameId);
      else if (ready && !disposed) {
        time = performance.now();
        tick();
      }
      send("RENDERER_STATUS", {
        chapter: mode,
        progress,
        activeStage: current?.activeStage ?? 0,
        hero: current?.hero ?? true,
        parameters: current || {},
        annotations: [],
        demonstration: true,
        renderingEnabled,
      });
      break;
    case "SET_REDUCED_MOTION":
      reduced = d.enabled === true;
      break;
    case "RESET_SCENE":
      target = progress = 0;
      current = narrative(mode, 0);
      selected = hover = null;
      send("DEVICE_SELECTED", { device: null });
      break;
    case "CLEAR_SELECTION":
      selected = hover = null;
      send("DEVICE_SELECTED", { device: null });
      break;
    case "DISPOSE":
      dispose();
      break;
  }
}
window.AutoPolicyBridge = { receive };
const messageListener = (e) => {
  if (e.source === window.parent && e.origin === location.origin)
    receive(e.data);
};
window.addEventListener("message", messageListener);
function theme() {
  scene.background = null;
  renderer.setClearColor(0x000000, 0);
  document.body.style.background = dark
    ? "radial-gradient(ellipse at 52% 47%, rgba(149,180,40,.14) 0%, rgba(89,111,33,.055) 40%, transparent 72%), radial-gradient(ellipse at 65% 62%, rgba(117,145,166,.045), transparent 58%), #000000"
    : "radial-gradient(ellipse at 52% 47%, rgba(128,164,22,.12), rgba(205,212,178,.045) 48%, transparent 74%), #FAF9F6";
  scene.getObjectByName("fill").intensity = dark ? 0.45 : 1.0;
  scene.getObjectByName("key").intensity = dark ? 2 : 2.8;
  bloom.strength = dark ? 0.56 : 0.23;
  scene.environmentIntensity = dark ? 0.48 : 0.38;
}
function resize() {
  if (!renderer) return;
  const w = innerWidth,
    h = innerHeight;
  renderer.setPixelRatio(Math.min(devicePixelRatio, w < 700 ? 1.4 : 1.75));
  renderer.setSize(w, h, false);
  composer?.setSize(w, h);
  bloomComposer?.setSize(w, h);
  camera.aspect = w / h;
  camera.updateProjectionMatrix();
}
function makeGraph() {
  const samples = new T.BufferGeometry();
  samples.setAttribute(
    "position",
    new T.BufferAttribute(telemetryPositions, 3),
  );
  telemetry = new T.Points(
    samples,
    new T.PointsMaterial({
      color: 0xffeda8,
      size: 0.055,
      transparent: true,
      depthWrite: false,
      opacity: 0,
    }),
  );
  telemetry.name = "runtime_telemetry_features";
  telemetry.frustumCulled = false;
  model.add(telemetry);
  telemetryTarget.copy(r.getWorldCenter("Zeek_Base")).y += 0.22;
  featureTarget.copy(r.getWorldCenter("Feature_Base")).y += 0.22;
  const graph = new T.Group();
  graph.name = "runtime_graph_edges";
  model.add(graph);
  for (const [a, b] of graphPairs) {
    const geometry = new T.BufferGeometry();
    geometry.setAttribute(
      "position",
      new T.BufferAttribute(new Float32Array(12), 3),
    );
    const material = new T.LineBasicMaterial({
      color: 0xb1a9da,
      transparent: true,
      opacity: 0,
      depthWrite: false,
    });
    const edge = new T.Line(geometry, material);
    edge.frustumCulled = false;
    graph.add(edge);
    graphEdges.push({ a, b, edge });
  }
  for (let i = 0; i < 3; i++) {
    const particle = new T.Mesh(
      new T.SphereGeometry(0.055, 8, 6),
      new T.MeshBasicMaterial({ color: 0xffeda8 }),
    );
    model.add(particle);
    evidence.push(particle);
  }
  // The prototype has a separate management zone and SOC screen.
  const management = new T.Mesh(
    new T.BoxGeometry(2.5, 0.12, 1.4),
    new T.MeshStandardMaterial({
      color: 0x464d50,
      metalness: 0.7,
      roughness: 0.35,
    }),
  );
  const bounds = r.getWorldBounds("Zone_Core");
  management.position.set(0, bounds.max.y - 0.06, bounds.max.z + 1.1);
  model.add(management);
  management.name = "runtime_management";
  groups.management = management;
}
function initializeModel(gltf) {
  model = gltf.scene;
  scene.add(model);
  r = setupRegistry(model);
  // Ground is the exported 16x16 dark presentation board, not a system zone.
  r.requireObject("Ground").visible = false;
  const floor = new T.Mesh(
    new T.PlaneGeometry(20, 20),
    new T.ShaderMaterial({
      transparent: true,
      depthWrite: false,
      vertexShader:
        "varying vec2 vUv; void main(){vUv=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}",
      fragmentShader:
        "varying vec2 vUv; void main(){float d=length((vUv-.5)*2.0);float a=.18*exp(-d*d*7.0);gl_FragColor=vec4(.08,.10,.04,a);}",
    }),
  );
  floor.name = "runtime_soft_grounding";
  floor.rotation.x = -Math.PI / 2;
  floor.position.y =
    new T.Box3().setFromObject(r.requireObject("Ground")).max.y + 0.003;
  scene.add(floor);
  const shadowFloor = new T.Mesh(
    new T.PlaneGeometry(17, 17),
    new T.ShadowMaterial({
      opacity: 0.17,
      transparent: true,
      depthWrite: false,
    }),
  );
  shadowFloor.name = "runtime_contact_shadow";
  shadowFloor.rotation.x = -Math.PI / 2;
  shadowFloor.position.y = floor.position.y + 0.001;
  shadowFloor.receiveShadow = true;
  scene.add(shadowFloor);
  // Preserve the approved palette: clone only semantic focal materials.
  for (const o of r.objects.values()) {
    if (
      !o.isMesh ||
      !/ContinuousSignal|AP14_(Front|Right)_(Shield|Network)|Core_Glass/.test(
        o.name,
      )
    )
      continue;
    o.material = o.material.clone();
    if (/ContinuousSignal/.test(o.name)) {
      o.material.emissive?.set(0xc4e326);
      o.material.emissiveIntensity = 0.8;
    } else if (/Core_Glass/.test(o.name)) {
      o.material.emissive?.set(0x7ba9c2);
      o.material.emissiveIntensity = 0.075;
    } else {
      o.material.emissive?.copy(o.material.color);
      o.material.emissiveIntensity = 0.4;
    }
  }
  for (const [id, , , zone] of devices) {
    roots[id] = r.getDeviceRoot(id);
    offsets[id] = new T.Vector3();
  }
  for (const n of moduleNames) r.requireObject(n);
  heroBounds = new T.Box3();
  for (const name of [
    "Zone_A",
    "Zone_Core",
    "Zone_B",
    "runtime_tower",
    ...devices.map((d) => "runtime_device_" + d[0]),
  ])
    heroBounds.union(r.getWorldBounds(name));
  heroCenter = heroBounds.getCenter(new T.Vector3());
  const size = heroBounds.getSize(new T.Vector3());
  sceneScale = Math.max(size.x / 9.1, size.y / 4.5, size.z / 9);
  zoneGap = size.x * 0.055;
  traffic = new Traffic(model, r, gltf.animations);
  makeGraph();
  for (const id of ["A", "Core", "B"]) groups[id] = r.getZoneRoot(id);
  for (const o of r.objects.values())
    if (
      /^AP16/.test(o.name) ||
      /^(Segmentation_|Zone[ABCore]+.*Boundary)/.test(o.name)
    )
      o.visible = false;
  groups.management.visible = false;
  const initial = narrative("explore", 0);
  current = { ...initial };
  apply(initial, 0);
  theme();
  resize();
  render();
  ready = true;
  send("MODEL_READY", {
    ...traffic.diagnostics(),
    bounds: { min: heroBounds.min.toArray(), max: heroBounds.max.toArray() },
    extrasCount: [...r.objects.values()].filter((o) =>
      Object.keys(o.userData).some(
        (key) => key !== "name" && key !== "deviceId",
      ),
    ).length,
  });
}
const cameraBounds = new T.Box3(),
  cameraCenter = new T.Vector3(),
  cameraDirection = new T.Vector3(),
  cameraRight = new T.Vector3(),
  cameraUp = new T.Vector3(),
  cameraCorner = new T.Vector3();
function cameraState(x) {
  // Fit the actual moving geometry inside the dedicated Flutter scene viewport.
  // Keep the reference chapter azimuth/elevation, without UI-dependent view offsets.
  cameraBounds.makeEmpty();
  for (const name of [
    "runtime_zone_A",
    "runtime_zone_Core",
    "runtime_zone_B",
    "runtime_tower",
    ...devices.map((d) => "runtime_device_" + d[0]),
  ]) {
    const object = r.objects.get(name);
    if (object) cameraBounds.expandByObject(object);
  }
  if (cameraBounds.isEmpty()) cameraBounds.copy(heroBounds);
  for (const name of [
    ...layerNames,
    ...policyNames,
    "AP16C_CTRL_RestrictedPlatform",
    "AP16E_CTRL_ManagementSOC",
  ]) {
    const object = r.requireObject(name);
    if (object.visible) cameraBounds.expandByObject(object);
  }
  cameraBounds.getCenter(cameraCenter);
  cameraCenter.x += x.c4 * sceneScale * 0.08;
  cameraDirection
    .set(Math.sin(x.c0), x.c2 / Math.max(x.c1, 0.1), Math.cos(x.c0))
    .normalize();
  cameraRight.crossVectors(camera.up, cameraDirection).normalize();
  cameraUp.crossVectors(cameraDirection, cameraRight).normalize();
  const tanV = Math.tan(T.MathUtils.degToRad(camera.fov / 2)),
    tanH = tanV * camera.aspect;
  let distance = 0;
  for (let i = 0; i < 8; i++) {
    cameraCorner
      .set(
        i & 1 ? cameraBounds.max.x : cameraBounds.min.x,
        i & 2 ? cameraBounds.max.y : cameraBounds.min.y,
        i & 4 ? cameraBounds.max.z : cameraBounds.min.z,
      )
      .sub(cameraCenter);
    distance = Math.max(
      distance,
      cameraCorner.dot(cameraDirection) +
        Math.max(
          Math.abs(cameraCorner.dot(cameraRight)) / tanH,
          Math.abs(cameraCorner.dot(cameraUp)) / tanV,
        ),
    );
  }
  const margin =
    {
      desktopWide: 1.07,
      desktop: 1.09,
      laptopCompact: 1.1,
      tabletLandscape: 1.12,
      tabletPortrait: 1.08,
      mobileLarge: 1.1,
      mobileSmall: 1.14,
    }[viewportClass] || 1.1;
  camera.position
    .copy(cameraCenter)
    .addScaledVector(cameraDirection, distance * margin);
  camera.setViewOffset(
    innerWidth,
    innerHeight,
    0,
    innerHeight *
      (/mobile|Portrait/.test(viewportClass) ? 0.015 : 0.065) *
      (1 - x.ex * 0.7),
    innerWidth,
    innerHeight,
  );
  camera.lookAt(cameraCenter);
  camera.updateProjectionMatrix();
}
function nodePosition(id, out) {
  if (id < 7) {
    const [device, , anchor] = devices[id];
    const bounds = r.getWorldBounds("runtime_device_" + device);
    return out.copy(r.getWorldCenter(anchor)).setY(bounds.max.y + 0.15);
  }
  if (id === 9)
    return out
      .copy(r.getWorldCenter("Core_Tower"))
      .setY(r.getWorldBounds("Core_Roof").max.y + 0.12);
  return out
    .copy(r.getWorldCenter("AP16E_CTRL_ManagementSOC"))
    .add(scratch.set(0, 0.5, 0));
}
const endpointA = new T.Vector3(),
  endpointB = new T.Vector3(),
  midA = new T.Vector3(),
  midB = new T.Vector3();
function updateGraph(x) {
  reveal("AP16G_CTRL_RelationshipGraph", Math.max(x.gr, x.dash * 0.35));
  for (const o of r.findObjectsByProperty("ap_role", "relationship_node")) {
    const id = o.userData.ap_node_id;
    nodePosition(id, endpointA);
    o.parent.worldToLocal(endpointA);
    o.position.copy(endpointA);
    if (o.userData.ap_state === "anomaly") o.visible = x.roq > 0.1;
    else if (id === 2) o.visible = x.roq <= 0.1;
    if (id === 10) o.visible = x.dash > 0.02;
  }
  for (const { a, b, edge } of graphEdges) {
    const anomaly = a === 2 || b === 2;
    let alpha = x.gr;
    if (a === 2 && b === 9) alpha *= sm(0.1, 0.5, x.roq);
    if (b === 10) alpha = x.dash * 0.5;
    nodePosition(a, endpointA);
    nodePosition(b, endpointB);
    // Orthogonal elevated perimeter routing avoids a cross-tower diagonal.
    midA.copy(endpointA);
    midB.copy(endpointB);
    if ((a < 7 && b === 9) || a === 5) {
      const side = endpointA.x < 0 ? -1 : 1;
      midA.x = midB.x = side * 2.15;
      midA.z = endpointA.z;
      midB.z = endpointB.z;
    } else {
      midA.z = midB.z = (endpointA.z + endpointB.z) * 0.5;
      midA.y = midB.y = Math.max(endpointA.y, endpointB.y);
    }
    const array = edge.geometry.attributes.position.array;
    [endpointA, midA, midB, endpointB].forEach((v, i) =>
      v.toArray(array, i * 3),
    );
    edge.geometry.attributes.position.needsUpdate = true;
    edge.material.opacity = alpha * 0.65;
    edge.visible = alpha > 0.01;
    edge.material.color.set(anomaly && x.roq > 0.1 ? 0xd92949 : 0xb1a9da);
  }
}
function highlightModules(x) {
  const stage = x.activeStage;
  const index =
    mode === "arch"
      ? [-1, 0, 1, 2, 3, 4, 5, -1, -1][stage]
      : mode === "explore"
        ? [-1, 0, 1, 3, 3, 4, 5, -1, -1][stage]
        : [-1, 3, 4, 5, -1][stage];
  modulePrefixes.forEach((prefix, i) => {
    for (const o of r.findObjectsByPrefix(prefix)) {
      if (!o.isMesh) continue;
      for (const m of r.list(o)) {
        const b = r.materials.get(m.uuid);
        if (!b || !m.emissive) continue;
        m.emissive.copy(b.emissive);
        m.emissiveIntensity = b.emissiveIntensity;
        if (
          i === index &&
          /Status|Indicator|Trace|Accent|Activity/.test(o.name)
        ) {
          m.emissive.set(i === 5 ? 0x80a416 : i === 4 ? 0xffeda8 : 0x9d8df1);
          m.emissiveIntensity = Math.max(0.4, b.emissiveIntensity) * 1.4;
        }
      }
    }
  });
}
function apply(x, t) {
  const split = x.zt * zoneGap * spread,
    isolation = Math.max(x.iso, x.zt),
    sensor = roots.GlassSensor;
  move(groups.A, -split);
  move(groups.B, split);
  move(groups.Core);
  move(
    r.requireObject("runtime_tower"),
    0,
    x.lift * 0.35 + x.ex * sm(0, 0.7, x.stageFloat) * 0.65,
  );
  for (const [id, , , zone] of devices) {
    const o = roots[id];
    move(o);
    offsets[id].set(zone === "A" ? -split : zone === "B" ? split : 0, 0, 0);
  }
  const restricted = reveal("AP16C_CTRL_RestrictedPlatform", isolation);
  move(restricted, -split);
  model.updateMatrixWorld(true);
  const sensorBase = r.base(sensor),
    sensorAnchor = r.getWorldCenter("AP14C_GlassSensor_Base");
  const platform = r.getWorldBounds("AP16C_CTRL_RestrictedPlatform");
  const landing = platform.getCenter(new T.Vector3());
  landing.y =
    platform.max.y +
    r.getWorldBounds("AP14C_GlassSensor_Base").getSize(new T.Vector3()).y * 0.5;
  const delta = landing.sub(sensorAnchor);
  sensor.position
    .copy(sensorBase.position)
    .add(delta.clone().multiplyScalar(isolation));
  sensor.position.y += 0.25 * x.roq * (1 - isolation) * (1 - x.enf);
  offsets.GlassSensor.add(delta.clone().multiplyScalar(isolation));
  // Sensor indicators, not the glass housing, carry threat color. Orb stays green.
  for (const o of r.findObjectsByPrefix("AP14C_GlassSensor_"))
    if (/Chip|Electronics|Aperture/.test(o.name))
      tone(o.name, x.roq > 0.1 ? 0xd92949 : 0x80a416, 0.3 + 0.6 * x.roq);
  tone("AP14C_Orb_NormalIndicator", 0x80a416, 0.65);
  const ring = reveal(
    "AP16D_GlassSensor_WarningRing",
    x.roq * (1 - 0.8 * isolation),
  );
  const beacon = reveal(
    "AP16D_GlassSensor_WarningBeacon",
    x.roq * (1 - 0.5 * x.enf),
  );
  model.updateMatrixWorld(true);
  const sensorPos = r.getWorldCenter("AP14C_GlassSensor_Base");
  ring.position.set(
    sensorPos.x,
    sensorPos.y +
      r.base(ring).position.y -
      r.base(r.requireObject("AP14C_GlassSensor_Base")).world.elements[13],
    sensorPos.z,
  );
  beacon.position.set(
    sensorPos.x,
    r.getWorldBounds("runtime_device_GlassSensor").max.y + 0.16,
    sensorPos.z,
  );
  const pulse = reduced ? 0.2 : (t * 0.6) % 1;
  ring.scale.copy(r.base(ring).scale).multiplyScalar(1 + pulse * 1.5);
  r.setMaterialOpacity(ring.name, x.roq * (1 - pulse) * (1 - 0.7 * x.enf));
  for (const [i, name] of [
    "AP16F_CTRL_Left",
    "AP16F_CTRL_Right",
    "AP16F_CTRL_Front",
  ].entries()) {
    const amount =
      (x.hero ? 0 : i < 2 ? Math.max(x.obs * 0.45, x.ins) : x.ins) *
      (1 - 0.8 * Math.max(x.enf, x.zt));
    reveal(name, amount * 0.55);
    for (const o of r.findObjectsByPrefix("AP16F_"))
      if (o.parent === r.requireObject(name) && /Scan/.test(o.name)) {
        move(o, 0, (reduced ? 0 : Math.sin(t * 1.5 + i) * 0.45) * amount);
        o.scale.x = r.base(o).scale.x * (1 + x.fx * 0.5);
      }
  }
  layerNames.forEach((name, i) => {
    const starts = [0.5, 1.6, 3.3, 4.7];
    const amount =
      mode === "arch" && !x.hero
        ? sm(starts[i], starts[i] + 0.8, x.stageFloat)
        : 0;
    const activeLayer =
      x.activeStage < 2
        ? 0
        : x.activeStage < 4
          ? 1
          : x.activeStage === 4
            ? 2
            : 3;
    const o = reveal(name, amount * (i === activeLayer ? 0.42 : 0.18));
    move(o, 0, x.ex * i * 0.22 * spread);
    o.scale.copy(r.base(o).scale).multiplyScalar(0.5 * (0.9 + 0.1 * amount));
    const layer =
      x.activeStage < 2
        ? 0
        : x.activeStage < 4
          ? 1
          : x.activeStage === 4
            ? 2
            : 3;
    o.traverse((child) => {
      if (child.isMesh && /Highlight|Accent|Line|Status/.test(child.name))
        for (const m of r.list(child))
          if (m.emissive) {
            m.emissive.set(0x9d8df1);
            m.emissiveIntensity = i === layer ? 1.0 : 0.18;
          }
    });
  });
  policyNames.forEach((name, i) => {
    const amount = sm(i * 0.25, i * 0.25 + 0.5, x.gen);
    const o = reveal(name, amount);
    o.scale.copy(r.base(o).scale).multiplyScalar(Math.max(0.001, amount));
    move(o, 0, x.ex * 1.3 - (1 - amount) * 0.35);
    const lines = [];
    o.traverse((child) => {
      if (/Data|Rule|Line/.test(child.name) && child.isMesh) lines.push(child);
    });
    lines.forEach(
      (child, k) => (child.visible = amount > (k + 1) / (lines.length + 1)),
    );
  });
  const allow = reveal("AP16I_CTRL_ALLOW", x.enf),
    deny = reveal("AP16I_CTRL_DENY", x.enf);
  move(allow, split);
  move(deny, -split);
  reveal("AP16I_DENY_Barrier", x.enf * 0.55);
  for (const [i, name] of [
    "AP16I_DENY_Jaw_Left",
    "AP16I_DENY_Jaw_Right",
  ].entries()) {
    const jaw = r.requireObject(name);
    move(jaw, (jaw.userData.ap_closed_x - jaw.userData.ap_open_x) * x.enf);
  }
  for (const [id, name] of [
    ["A", "AP16J_CTRL_Zone_A"],
    ["Core", "AP16J_CTRL_Zone_CORE"],
    ["B", "AP16J_CTRL_Zone_B"],
  ]) {
    const o = reveal(name, x.zt * 0.7);
    o.scale.copy(r.base(o).scale);
    o.scale.y *= Math.max(0.001, x.zt);
  }
  groups.management.visible = x.zt > 0.02;
  groups.management.scale.y = Math.max(0.001, x.zt);
  reveal("AP16E_CTRL_ManagementSOC", x.dash);
  tone("AP16E_Dashboard_Screen", 0xcfe6f2, 0.08 + 0.2 * x.dash);
  for (const bar of r.findObjectsByProperty("ap_role", "dashboard_metric")) {
    const i = bar.userData.ap_metric_index;
    const activity = reduced ? 0.7 : 0.6 + 0.2 * Math.sin(t * 1.2 + i);
    bar.scale.copy(r.base(bar).scale);
    bar.scale.y *= activity;
    bar.position.copy(r.base(bar).position);
    bar.position.y -= (1 - activity) * 0.29;
    tone(
      bar.name,
      i === 3 && x.enf > 0.5 ? 0xd92949 : 0x80a416,
      0.5 + 0.35 * activity,
    );
  }
  for (const status of r.findObjectsByProperty("ap_role", "soc_status_led"))
    tone(status.name, 0x80a416, 0.5 + 0.3 * x.dash);
  nodePosition(2, endpointA);
  nodePosition(9, endpointB);
  evidence.forEach((p, i) => {
    p.visible = x.evd > 0.02;
    const u = reduced ? 0.5 : (t * 0.55 + i / 3) % 1;
    p.position.copy(endpointA).lerp(endpointB, u);
    p.position.y += Math.sin(u * Math.PI) * 0.45;
    p.scale.setScalar(x.evd);
  });
  highlightModules(x);
  tone("AP14K_Status_ALLOW", 0x80a416, 0.35 + 0.6 * x.enf);
  tone(
    "AP14K_DecisionIndicator_01",
    x.enf > 0.1 ? 0xd92949 : 0x80a416,
    0.25 + 0.6 * x.enf,
  );
  tone("AP14K_DecisionIndicator_02", 0x80a416, 0.25 + 0.6 * x.enf);
  highlightDevices();
  updateGraph(x);
  updateTelemetry(x, t);
  traffic.update(clock.getDelta(), t, x, offsets, reduced);
  cameraState(x);
}
function updateTelemetry(x, t) {
  const strength = x.ins * (1 - 0.9 * Math.max(x.enf, x.zt));
  telemetry.visible = !x.hero && strength > 0.02;
  telemetry.material.opacity = strength * 0.7;
  telemetry.material.color.set(x.fx > 0.25 ? 0x9d8df1 : 0xffeda8);
  let index = 0;
  for (const [id, points] of traffic.routes)
    for (let packet = 0; packet < 3; packet++) {
      const u = reduced ? 0.55 : (t * 0.4 + packet / 3 + index * 0.037) % 1;
      endpointA.copy(points.at(-1));
      endpointB.copy(telemetryTarget).lerp(featureTarget, x.fx);
      scratch.copy(endpointA).lerp(endpointB, u);
      scratch.y += Math.sin(u * Math.PI) * 0.25;
      scratch.toArray(telemetryPositions, index++ * 3);
    }
  telemetry.geometry.attributes.position.needsUpdate = true;
}
function highlightDevices() {
  for (const [id] of devices)
    roots[id].traverse((o) => {
      if (!o.isMesh || !/Chassis|Housing|Shell|MountBase|_Base$/.test(o.name))
        return;
      for (const m of r.list(o)) {
        const b = r.materials.get(m.uuid);
        if (!b?.emissive || !m.emissive) return;
        m.emissive.copy(b.emissive);
        m.emissiveIntensity = b.emissiveIntensity;
        if (id === (selected || hover)) {
          m.emissive.set(0xc4e326);
          m.emissiveIntensity = Math.max(0.12, b.emissiveIntensity);
        }
      }
    });
}
function annotations(x) {
  const results = [];
  const add = (id, label, world, on) => {
    if (!on) return;
    projected.copy(world).project(camera);
    if (projected.z > 1) return;
    results.push({
      id,
      label,
      x: projected.x * 0.5 + 0.5,
      y: -0.5 * projected.y + 0.5,
    });
  };
  if (x.zt > 0.3) {
    add("zone-a", "ZONE A · DEVICES", r.getWorldCenter("Zone_A"), true);
    add("zone-b", "ZONE B · VERIFIED", r.getWorldCenter("Zone_B"), true);
    add("core", "CORE SERVICES", r.getWorldCenter("Core_Roof"), true);
    add(
      "restricted",
      "RESTRICTED",
      r.getWorldCenter("AP16C_CTRL_RestrictedPlatform"),
      true,
    );
    add("management", "MANAGEMENT ZONE", groups.management.position, true);
  }
  add(
    "soc",
    "SOC · MONITORING",
    r.getWorldCenter("AP16E_Dashboard_Screen"),
    x.dash > 0.3,
  );
  add(
    "allow",
    x.zt > 0.5 ? "VERIFY → ALLOW" : "ALLOW",
    r.getWorldCenter("AP16I_CTRL_ALLOW"),
    x.enf > 0.3,
  );
  add(
    "deny",
    x.zt > 0.5 ? "VERIFY → DENY" : "DENY",
    r.getWorldCenter("AP16I_CTRL_DENY"),
    x.enf > 0.3,
  );
  if (hover || selected) {
    const id = selected || hover;
    add(
      "device",
      id === "GlassSensor" ? "GLASS SENSOR" : id.toUpperCase(),
      r.getWorldCenter("runtime_device_" + id),
      true,
    );
  }
  return results;
}
function render() {
  if (!composer) {
    renderer.render(scene, camera);
    return;
  }
  const background = scene.background;
  scene.background = black.color;
  scene.traverse((o) => {
    if (!o.isMesh) return;
    const semantic =
      /Packet|Signal|Indicator|Status|Warning|Graph_Node|DataLine|Policy.*Rule|Evidence|AP14_(Front|Right)_(Shield|Network)/i.test(
        o.name,
      );
    if (!semantic) {
      savedMaterials.set(o.uuid, o.material);
      o.material = black;
    }
  });
  bloomComposer.render();
  scene.traverse((o) => {
    if (savedMaterials.has(o.uuid)) {
      o.material = savedMaterials.get(o.uuid);
    }
  });
  savedMaterials.clear();
  scene.background = background;
  composer.render();
}
function tick() {
  if (disposed || !renderingEnabled) return;
  canvas.dataset.renderingEnabled = "true";
  frameId = requestAnimationFrame(tick);
  if (!ready || document.hidden) return;
  const dt = Math.min(0.05, (performance.now() - time) / 1000 || 0.016);
  time = performance.now();
  progress = reduced ? target : T.MathUtils.damp(progress, target, 8, dt);
  const desired = narrative(mode, progress);
  const blend = 1 - Math.exp(-12 * dt);
  for (const key of Object.keys(desired)) {
    if (typeof desired[key] === "number")
      current[key] = T.MathUtils.lerp(
        current[key] ?? desired[key],
        desired[key],
        blend,
      );
    else current[key] = desired[key];
  }
  current.activeStage = desired.activeStage;
  current.stageFloat = desired.stageFloat;
  apply(current, clock.elapsedTime);
  render();
  if (time - lastStatus > 100) {
    lastStatus = time;
    canvas.dataset.progress = progress.toFixed(3);
    canvas.dataset.chapter = mode;
    canvas.dataset.state = JSON.stringify({
      chapter: mode,
      progress,
      parameters: current,
      sensor: roots.GlassSensor.position.toArray(),
      tower: r.requireObject("runtime_tower").position.toArray(),
      zones: [groups.A.position.toArray(), groups.B.position.toArray()],
      traffic: traffic.diagnostics(),
      visible: [...r.objects.values()]
        .filter((o) => /^AP16.*CTRL/.test(o.name) && o.visible)
        .map((o) => o.name),
    });
    send("RENDERER_STATUS", {
      chapter: mode,
      progress,
      activeStage: desired.activeStage,
      renderingEnabled,
      hero: desired.hero,
      parameters: current,
      annotations: annotations(current),
      demonstration: true,
    });
  }
}
function hit(event) {
  if (!ready || !interaction || !renderingEnabled) return null;
  pointer.set(
    (event.clientX / innerWidth) * 2 - 1,
    1 - (event.clientY / innerHeight) * 2,
  );
  raycaster.setFromCamera(pointer, camera);
  return (
    raycaster.intersectObjects(Object.values(roots), true)[0]?.object.userData
      .deviceId || null
  );
}
const pointerMove = (e) => {
  const id = hit(e);
  if (id !== hover) {
    hover = id;
    send("DEVICE_HOVER", {
      device: id,
      status:
        id === "GlassSensor" && current?.roq > 0.1 ? "anomalous" : "normal",
    });
  }
  canvas.style.cursor = id ? "pointer" : "default";
};
let pointerStart = 0,
  dragged = false;
const pointerDown = (e) => {
  pointerStart = e.clientY;
  dragged = false;
  canvas.dataset.pointerY = e.clientY;
};
const pointerUp = (e) => {
  if (!dragged && Math.abs(e.clientY - pointerStart) < 6) {
    selected = hit(e);
    send("DEVICE_SELECTED", {
      device: selected,
      status:
        selected === "GlassSensor" && current?.roq > 0.1
          ? "anomalous"
          : "normal",
    });
  }
  delete canvas.dataset.pointerY;
};
const wheel = (e) => {
  e.preventDefault();
  send("SCROLL_INPUT", { delta: e.deltaY });
};
const pointerDrag = (e) => {
  if (e.buttons === 1 && canvas.dataset.pointerY) {
    const before = Number(canvas.dataset.pointerY);
    if (Math.abs(e.clientY - pointerStart) > 6) dragged = true;
    send("SCROLL_INPUT", { delta: before - e.clientY });
    canvas.dataset.pointerY = e.clientY;
  }
};
const keyboard = (e) => {
  const delta = {
    ArrowDown: innerHeight * 0.6,
    ArrowUp: -innerHeight * 0.6,
    PageDown: innerHeight,
    PageUp: -innerHeight,
    Home: -innerHeight * counts[mode],
    End: innerHeight * counts[mode],
  }[e.key];
  if (delta !== undefined) {
    e.preventDefault();
    send("SCROLL_INPUT", { delta });
  }
};
window.addEventListener("keydown", keyboard);
const lost = (e) => {
  e.preventDefault();
  ready = false;
  send("MODEL_ERROR", {
    message: "WebGL context lost. Reload the scene to restore rendering.",
  });
};
canvas.addEventListener("pointermove", pointerMove);
canvas.addEventListener("pointermove", pointerDrag);
canvas.addEventListener("pointerdown", pointerDown);
canvas.addEventListener("pointerup", pointerUp);
canvas.addEventListener("wheel", wheel, { passive: false });
canvas.addEventListener("webglcontextlost", lost);
window.addEventListener("resize", resize);
function dispose() {
  if (disposed) return;
  disposed = true;
  cancelAnimationFrame(frameId);
  traffic?.dispose();
  window.removeEventListener("message", messageListener);
  window.removeEventListener("resize", resize);
  window.removeEventListener("keydown", keyboard);
  canvas.removeEventListener("pointermove", pointerMove);
  canvas.removeEventListener("pointermove", pointerDrag);
  canvas.removeEventListener("pointerdown", pointerDown);
  canvas.removeEventListener("pointerup", pointerUp);
  canvas.removeEventListener("wheel", wheel);
  canvas.removeEventListener("webglcontextlost", lost);
  scene?.traverse((o) => {
    o.geometry?.dispose();
    if (o.material)
      for (const m of Array.isArray(o.material) ? o.material : [o.material])
        m.dispose();
  });
  composer?.dispose();
  bloomComposer?.dispose();
  envTarget?.dispose();
  pmrem?.dispose();
  renderer?.dispose();
  black.dispose();
}
window.addEventListener("pagehide", dispose, { once: true });
window.AutoPolicyDiagnostics = {
  getState: () => ({
    ready,
    chapter: mode,
    progress,
    parameters: current,
    traffic: traffic?.diagnostics(),
    stageVisible: r
      ? [...r.objects.values()]
          .filter((o) => /^AP16.*CTRL/.test(o.name) && o.visible)
          .map((o) => o.name)
      : [],
    sensor: roots.GlassSensor?.position.toArray(),
    zones: groups.A
      ? [groups.A.position.toArray(), groups.B.position.toArray()]
      : [],
  }),
};
async function init() {
  try {
    scene = new T.Scene();
    camera = new T.PerspectiveCamera(30, innerWidth / innerHeight, 0.05, 250);
    renderer = new T.WebGLRenderer({
      canvas,
      antialias: true,
      alpha: true,
      premultipliedAlpha: false,
      powerPreference: "high-performance",
    });
    renderer.outputColorSpace = T.SRGBColorSpace;
    renderer.toneMapping = T.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 0.72;
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = T.PCFSoftShadowMap;
    const key = new T.DirectionalLight(0xffffff, 3);
    key.name = "key";
    key.position.set(-8, 15, 7);
    key.castShadow = true;
    key.shadow.mapSize.set(1024, 1024);
    Object.assign(key.shadow.camera, {
      left: -12,
      right: 12,
      top: 12,
      bottom: -12,
      near: 1,
      far: 50,
    });
    key.shadow.bias = -0.0002;
    scene.add(key);
    const fill = new T.HemisphereLight(0xcfe6f2, 0x464d50, 1.4);
    fill.name = "fill";
    scene.add(fill);
    const rim = new T.DirectionalLight(0xb1a9da, 0.8);
    rim.position.set(7, 9, -8);
    scene.add(rim);
    pmrem = new T.PMREMGenerator(renderer);
    const room = new RoomEnvironment();
    envTarget = pmrem.fromScene(room, 0.04);
    room.dispose();
    scene.environment = envTarget.texture;
    scene.environmentIntensity = 0.35;
    bloomComposer = new EffectComposer(renderer);
    bloomComposer.renderToScreen = false;
    bloomComposer.addPass(new RenderPass(scene, camera));
    bloom = new UnrealBloomPass(
      new T.Vector2(innerWidth, innerHeight),
      0.25,
      0.2,
      0.6,
    );
    bloomComposer.addPass(bloom);
    composer = new EffectComposer(renderer);
    composer.addPass(new RenderPass(scene, camera));
    composer.addPass(
      new ShaderPass(
        {
          uniforms: {
            baseTexture: { value: null },
            bloomTexture: { value: null },
          },
          vertexShader:
            "varying vec2 vUv; void main(){vUv=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}",
          fragmentShader:
            "uniform sampler2D baseTexture; uniform sampler2D bloomTexture; varying vec2 vUv; void main(){vec4 base=texture2D(baseTexture,vUv);vec3 glow=texture2D(bloomTexture,vUv).rgb;gl_FragColor=vec4(base.rgb+glow,max(base.a,clamp(dot(glow,vec3(.333))*1.5,0.,1.)));}",
        },
        "baseTexture",
      ),
    );
    composer.passes[1].uniforms.bloomTexture.value =
      bloomComposer.renderTarget2.texture;
    composer.addPass(new OutputPass());
    clock = new T.Clock();
    resize();
    const url = new URL("../3Dmodel/AutoPolicy_Production.glb", location.href);
    const gltf = await new GLTFLoader().loadAsync(url.href);
    initializeModel(gltf);
    tick();
  } catch (error) {
    console.error(error);
    send("MODEL_ERROR", { message: error.message, stack: error.stack });
  }
}
init();
