import * as T from "three";
export const devices = [
  ["Camera", "AP14B_Camera_", "AP14B_Camera_MountBase", "A"],
  ["Gateway", "AP14B_Gateway_", "AP14B_Gateway_LowerChassis", "A"],
  ["GlassSensor", "AP14C_GlassSensor_", "AP14C_GlassSensor_Base", "A"],
  ["Controller", "AP14C_Controller_", "AP14C_Controller_Chassis", "B"],
  ["Cylinder", "AP14C_Cylinder_", "AP14C_Cylinder_Mount", "B"],
  ["Embedded", "AP14C_Embedded_", "AP14C_Embedded_PCB", "Core"],
  ["Orb", "AP14C_Orb_", "AP14C_Orb_Mount", "B"],
];
export class Registry {
  constructor(root) {
    this.root = root;
    this.objects = new Map();
    this.baselines = new Map();
    this.materials = new Map();
    root.updateMatrixWorld(true);
    root.traverse((o) => {
      if (o.name) this.objects.set(o.name, o);
      if (o.isMesh) {
        o.castShadow = !o.material.transparent;
        o.receiveShadow = true;
        const list = Array.isArray(o.material) ? o.material : [o.material];
        o.material = list.map((m) =>
          /^AP16|^AP15A|^AP14[B-CF-K]_|ContinuousSignal/.test(o.name)
            ? m.clone()
            : m,
        );
        if (!Array.isArray(list) || list.length === 1)
          o.material = o.material[0];
      }
    });
  }
  requireObject(name) {
    const o = this.objects.get(name);
    if (!o)
      throw new Error(
        `Required GLB object "${name}" is missing. Re-export the production asset with its named controls.`,
      );
    return o;
  }
  findObjectsByPrefix(prefix) {
    return [...this.objects.values()].filter((o) => o.name.startsWith(prefix));
  }
  findObjectsByProperty(key, value) {
    return [...this.objects.values()].filter((o) => o.userData[key] === value);
  }
  getWorldBounds(name) {
    return new T.Box3().setFromObject(this.requireObject(name));
  }
  getWorldCenter(name) {
    return this.getWorldBounds(name).getCenter(new T.Vector3());
  }
  control(name, objects) {
    const group = new T.Group();
    group.name = name;
    this.root.add(group);
    this.root.updateMatrixWorld(true);
    for (const o of objects) group.attach(o);
    this.objects.set(name, group);
    return group;
  }
  snapshot() {
    this.root.updateMatrixWorld(true);
    this.root.traverse((o) => {
      this.baselines.set(o.uuid, {
        position: o.position.clone(),
        quaternion: o.quaternion.clone(),
        scale: o.scale.clone(),
        visible: o.visible,
        world: o.matrixWorld.clone(),
      });
      if (o.isMesh)
        for (const m of this.list(o)) {
          this.materials.set(m.uuid, {
            opacity: m.opacity,
            transparent: m.transparent,
            color: m.color?.clone(),
            emissive: m.emissive?.clone(),
            emissiveIntensity: m.emissiveIntensity,
            depthWrite: m.depthWrite,
          });
        }
    });
  }
  base(o) {
    return this.baselines.get(o.uuid);
  }
  list(o) {
    return Array.isArray(o.material) ? o.material : [o.material];
  }
  setGroupVisible(name, on) {
    this.requireObject(name).visible = on;
  }
  setMaterialOpacity(name, amount) {
    this.requireObject(name).traverse((o) => {
      if (o.isMesh)
        for (const m of this.list(o)) {
          const b = this.materials.get(m.uuid);
          m.opacity = (b?.opacity ?? 1) * amount;
          m.transparent = amount < 0.999 || b?.transparent;
          m.depthWrite = m.transparent ? false : b?.depthWrite;
        }
    });
  }
  setEmissiveState(name, color, intensity) {
    this.requireObject(name).traverse((o) => {
      if (o.isMesh)
        for (const m of this.list(o)) {
          if (m.emissive) {
            m.emissive.set(color);
            m.emissiveIntensity = intensity;
          }
        }
    });
  }
  getDeviceRoot(id) {
    return this.requireObject(`runtime_device_${id}`);
  }
  getZoneRoot(name) {
    return this.requireObject(`runtime_zone_${name}`);
  }
}
export function setupRegistry(root) {
  const r = new Registry(root);
  for (const [id, prefix, anchor] of devices) {
    r.requireObject(anchor);
    const group = r.control(
      `runtime_device_${id}`,
      r.findObjectsByPrefix(prefix),
    );
    group.userData.deviceId = id;
    group.traverse((o) => (o.userData.deviceId = id));
  }
  const zoneControls = {
    A: r.control("runtime_zone_A", [r.requireObject("Zone_A")]),
    Core: r.control("runtime_zone_Core", [r.requireObject("Zone_Core")]),
    B: r.control("runtime_zone_B", [r.requireObject("Zone_B")]),
  };
  // Zone_A/B are individual slabs rather than parents. Group only their physical
  // region hardware; the central pipeline remains connected by runtime bridges.
  for (const [id, , , zone] of devices) {
    zoneControls[zone].attach(r.getDeviceRoot(id));
    zoneControls[zone].attach(r.requireObject("TrafficRoute_" + id));
  }
  for (const o of [...root.children]) {
    if (o.name.startsWith("runtime_") || /^AP16/.test(o.name)) continue;
    let zone = null;
    if (/^Device_(Camera|Gateway|SensorGlass)_Dock|^ZoneA_/.test(o.name))
      zone = "A";
    if (/^Device_(Controller|Cylinder|Orb)_Dock|^ZoneB_/.test(o.name))
      zone = "B";
    if (/^Device_Embedded_Dock|^ZoneCore_/.test(o.name)) zone = "Core";
    if (zone) zoneControls[zone].attach(o);
  }
  const tower = r.control(
    "runtime_tower",
    [...root.children].filter((o) =>
      /^Core_|^AP14_(Front|Right)_|^Step0/.test(o.name),
    ),
  );
  zoneControls.Core.attach(tower);
  for (const [name, zone] of [
    ["AP16J_CTRL_Zone_A", "A"],
    ["AP16J_CTRL_Zone_CORE", "Core"],
    ["AP16J_CTRL_Zone_B", "B"],
  ])
    zoneControls[zone].attach(r.requireObject(name));
  for (const name of [
    "AP16B_CTRL_01_CAPTURE",
    "AP16B_CTRL_02_TELEMETRY",
    "AP16B_CTRL_03_INTELLIGENCE",
    "AP16B_CTRL_04_POLICY",
    "AP16C_CTRL_RestrictedPlatform",
    "AP16E_CTRL_ManagementSOC",
    "AP16F_CTRL_Left",
    "AP16F_CTRL_Right",
    "AP16F_CTRL_Front",
    "AP16G_CTRL_RelationshipGraph",
    "AP16H_CTRL_01_EVIDENCE",
    "AP16H_CTRL_02_POLICY_SYNTHESIS",
    "AP16H_CTRL_03_ENFORCEABLE_POLICY",
    "AP16I_CTRL_ALLOW",
    "AP16I_CTRL_DENY",
    "AP16I_DENY_Barrier",
    "AP16I_DENY_Jaw_Left",
    "AP16I_DENY_Jaw_Right",
  ])
    r.requireObject(name);
  r.snapshot();
  // All exported stage assets are disabled before the first render, including
  // control groups whose children have default-visible flags from export.
  for (const o of r.objects.values())
    if (/^AP16/.test(o.name) || o.userData.ap_default_visible === false)
      o.visible = false;
  for (const o of r.objects.values())
    if (/Orb.*(Anomal|Red)|Anomaly.*Orb/i.test(o.name)) o.visible = false;
  return r;
}
