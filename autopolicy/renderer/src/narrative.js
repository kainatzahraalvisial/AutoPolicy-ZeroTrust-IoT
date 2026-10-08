export const sm = (a, b, x) => {
  x = Math.min(1, Math.max(0, (x - a) / (b - a)));
  return x * x * (3 - 2 * x);
};
const bump = (c, w, x) => sm(0, 1, Math.max(0, 1 - Math.abs(x - c) / w));
const ip = (keys, f) => {
  const n = keys.length - 1,
    k = Math.min(n - 1, Math.max(0, Math.floor(f))),
    fr = sm(0, 1, f - k),
    a = keys[k],
    b = keys[k + 1];
  return a.map((x, i) => x + (b[i] - x) * fr);
};
export const S = [
  [
    "CONNECT",
    "Devices enter the network.",
    "Every IoT device becomes part of the environment AutoPolicy must observe and protect.",
    "IoT DEVICE LAYER",
  ],
  [
    "OBSERVE",
    "See the network as it behaves.",
    "AutoPolicy watches the traffic flowing between devices in real time.",
    "TRAFFIC OBSERVATION",
  ],
  [
    "ANALYZE",
    "Turn traffic into security intelligence.",
    "Raw packets pass an inspection layer and become structured telemetry.",
    "ZEEK / NETWORK TELEMETRY",
  ],
  [
    "DETECT",
    "Find abnormal relationships.",
    "ML + GNN analysis reveals communication patterns that do not belong.",
    "ML + GNN ANALYSIS",
  ],
  [
    "ANOMALY",
    "One device doesn't behave normally.",
    "Its communication breaks away from the graph and is isolated.",
    "ANOMALY IDENTIFIED",
  ],
  [
    "GENERATE",
    "Turn detection into policy.",
    "Evidence converges into the core and becomes an enforceable policy.",
    "TRANSFORMER POLICY GENERATION",
  ],
  [
    "ENFORCE",
    "Apply the decision in real time.",
    "Allowed traffic continues. Threat traffic stops at the OPA checkpoint.",
    "OPA POLICY ENFORCEMENT",
  ],
  [
    "ZERO TRUST",
    "Verify every connection.",
    "The network splits into zones. Nothing crosses without verification.",
    "ZERO-TRUST SEGMENTATION",
  ],
  [
    "SYSTEM",
    "Autonomous zero-trust infrastructure.",
    "Devices, telemetry, detection, policy and enforcement as one system.",
    "COMPLETE AUTOPOLICY SYSTEM",
  ],
];
export const AR = [
  [
    "IoT DEVICES",
    "IoT Device Layer",
    "Devices, sensors and gateways across the network.",
    "SOURCE LAYER",
  ],
  [
    "TRAFFIC OBSERVATION",
    "Traffic Observation",
    "Real-time network monitoring and packet capture.",
    "CAPTURE LAYER",
  ],
  [
    "ZEEK TELEMETRY",
    "Zeek Network Telemetry",
    "Deep packet inspection and log extraction.",
    "RAW TRAFFIC → TELEMETRY",
  ],
  [
    "FEATURE EXTRACTION",
    "Feature Extraction",
    "Convert raw data into meaningful security features.",
    "TELEMETRY → FEATURES",
  ],
  [
    "ML + GNN",
    "ML + GNN Detection",
    "Identify patterns and anomalies in device relationships.",
    "GRAPH ANALYSIS",
  ],
  [
    "TRANSFORMER",
    "Transformer Policy Generation",
    "Create enforceable security policies.",
    "ANALYSIS → POLICY",
  ],
  [
    "OPA",
    "OPA Enforcement",
    "Apply policies in real time.",
    "POLICY → ALLOW / DENY",
  ],
  [
    "ZERO TRUST",
    "Zero Trust Segmentation",
    "Verify every connection.",
    "MICRO-SEGMENTATION",
  ],
  [
    "DASHBOARD",
    "SOC / Dashboard",
    "Monitoring, alerts and system visibility.",
    "SYSTEM VISIBILITY",
  ],
];
export const SC = [
  [
    "THREATS OVERVIEW",
    "A healthy network.",
    "Normal devices communicate and traffic moves. Then something changes.",
    "THREAT MODEL",
  ],
  [
    "ANOMALY DETECTION",
    "Suspicious behavior emerges.",
    "AI + ML + GNN analysis flags a relationship that does not belong.",
    "ANOMALY DETECTED",
  ],
  [
    "DEVICE ISOLATION",
    "Separate the device.",
    "A policy is generated and the device moves into a restricted zone.",
    "DEVICE ISOLATION · RESTRICTED ACCESS",
  ],
  [
    "POLICY ENFORCEMENT",
    "Enforce the policy.",
    "OPA permits normal traffic and blocks the glass sensor at the DENY checkpoint.",
    "OPA POLICY ENFORCEMENT",
  ],
  [
    "ZERO TRUST",
    "Detect. Respond. Enforce. Protect.",
    "Trusted zones stay connected. The threat stays isolated.",
    "PROTECTED STATE",
  ],
];
export const K = [
  [0.785, 24, 18.5, 1.2, 0],
  [0.8, 22, 15, 1.2, -0.5],
  [0.55, 22, 15.5, 1.4, -0.3],
  [0.785, 24, 19.5, 2.2, 0],
  [-0.2, 22, 16, 1.4, -0.8],
  [0.6, 22, 17, 2.6, 0],
  [0.2, 22, 15.5, 1.4, -0.8],
  [0.785, 30, 26, 0, 0],
  [0.785, 32, 24, 1, 0],
];
export const KA = [
  [0.785, 24, 17, 2, -1],
  [0.65, 24, 17, 2, -0.5],
  [0.45, 23, 16, 2.2, 0.8],
  [0.7, 23, 16, 2.4, 0.3],
  [0.785, 25, 19, 2.8, 0],
  [0.6, 24, 18, 3.6, 0],
  [0.25, 23, 16, 2, -1.2],
  [0.785, 30, 26, 0.8, 0],
  [0.9, 28, 20, 1.5, 0.5],
];
export const KS = [
  [0.785, 26, 20, 1.2, 0],
  [-0.2, 22, 16, 1.2, -1],
  [-0.1, 21, 15, 1, -1.8],
  [0.2, 22, 15, 1, -1],
  [0.785, 32, 24, 1, 0],
];
export const TH = [
  ["Anomalous Device Behavior", "Unusual patterns and activity."],
  ["Unauthorized Communication", "Blocked external or unknown connections."],
  ["Suspicious Traffic", "Malicious or unexpected traffic."],
  ["Compromised IoT Devices", "Infected or vulnerable devices."],
  ["Lateral Movement", "Cross-segment exploration."],
  ["Policy Violations", "Non-compliant access or actions."],
];
export function chapter(m, f) {
  const o = {
    ex: 0,
    fx: 0,
    dash: 0,
    iso: 0,
    rv: 0,
    evd: 0,
    ptl: 0,
    lift: 0,
    det: 0,
    zt: 0,
    sys: 0,
    vx: 0.19,
  };
  let c;
  if (m == "explore") {
    c = ip(K, f);
    Object.assign(o, {
      obs: sm(0.5, 1, f),
      ins: sm(1.4, 1.9, f),
      act: sm(0.6, 1.4, f),
      lift: bump(2, 1.1, f),
      det: bump(3, 1, f),
      gr: Math.min(
        1,
        sm(2.6, 3.2, f) * (1 - sm(4.9, 5.5, f)) + 0.45 * sm(7.6, 8, f),
      ),
      roq: sm(3.6, 4.6, f),
      gen: sm(4.9, 5.9, f),
      enf: sm(5.7, 6.4, f),
      zt: sm(6.6, 7.4, f),
      sys: sm(7.5, 8, f),
      rv: f < 1.7 ? 1 : 0,
      evd: sm(4.4, 4.8, f) * (1 - sm(5.4, 5.8, f)),
      ptl: f > 6.2 ? 1 : 0,
      vx: 0.21,
    });
  } else if (m == "arch") {
    c = ip(KA, f);
    Object.assign(o, {
      obs: sm(0.6, 1.3, f),
      act: 0.25 + 0.75 * sm(0.6, 1.4, f),
      ins: sm(1.6, 2.3, f),
      fx: sm(2.6, 3.3, f),
      gr: Math.min(
        1,
        sm(3.6, 4.3, f) * (1 - sm(5.2, 5.8, f)) + 0.45 * sm(7.6, 8, f),
      ),
      det: bump(4, 1, f),
      roq: sm(3.9, 4.6, f),
      gen: sm(4.9, 5.9, f),
      evd: sm(4.6, 4.9, f) * (1 - sm(5.4, 5.8, f)),
      enf: sm(5.7, 6.4, f),
      ptl: f > 6.2 ? 1 : 0,
      zt: sm(6.6, 7.4, f),
      sys: sm(7.6, 8, f),
      dash: sm(7.4, 8, f),
      ex: 0.15 + 0.55 * sm(0, 0.9, f) - 0.3 * sm(6.5, 7.5, f),
    });
  } else {
    c = ip(KS, f);
    Object.assign(o, {
      obs: 1,
      act: 1,
      ins: 1,
      gr: Math.min(
        1,
        sm(0.4, 0.9, f) * (1 - sm(1.9, 2.3, f)) + 0.45 * sm(3.6, 4, f),
      ),
      roq: sm(0.5, 1.1, f),
      det: bump(1, 0.7, f),
      gen: sm(1.6, 2.2, f),
      evd: sm(1.4, 1.7, f) * (1 - sm(2.2, 2.5, f)),
      iso: sm(2, 2.7, f),
      enf: sm(2.6, 3.2, f),
      ptl: f > 2.6 ? 1 : 0,
      zt: sm(3.4, 3.9, f),
      sys: sm(3.6, 4, f),
    });
  }
  c.forEach((x, i) => (o["c" + i] = x));
  return o;
}
export const counts = { explore: 9, arch: 9, sec: 5 };
export const clamp = (x) => Math.max(0, Math.min(1, x));
export function narrative(mode, progress) {
  const f = clamp(progress) * (counts[mode] - 1);
  const state = chapter(mode, f);
  return {
    ...state,
    stageFloat: f,
    activeStage: Math.round(f),
    hero: f < 0.25,
  };
}
