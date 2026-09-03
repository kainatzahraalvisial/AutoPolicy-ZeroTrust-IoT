import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../models/anomaly.dart';
import '../models/policy.dart';
import '../models/traffic.dart';
import '../services/telemetry_service.dart';
import '../services/opa_service.dart';
import '../services/websocket_service.dart';

// Declare services providers
final telemetryServiceProvider = Provider<TelemetryService>((ref) => TelemetryService());
final opaServiceProvider = Provider<OpaService>((ref) => OpaService());
final webSocketServiceProvider = Provider<WebSocketService>((ref) => WebSocketService()..connect());

class CyberNotification {
  final String id;
  final String message;
  final String type; // 'threat', 'deploy', 'warning', 'info'
  final DateTime timestamp;
  bool isRead;

  CyberNotification({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

// Holds the aggregate state of the cybersecurity operations center (SOC)
class SecurityState {
  final List<IoTDevice> devices;
  final List<Anomaly> anomalies;
  final List<SecurityPolicy> policies;
  final List<NetworkTraffic> trafficFeed;
  final List<OpaLogEntry> opaLogs;
  final List<CyberNotification> notifications;
  final bool isSimulating;
  final double mlModelAccuracy;
  final int totalBlockedAttacks;

  const SecurityState({
    required this.devices,
    required this.anomalies,
    required this.policies,
    required this.trafficFeed,
    required this.opaLogs,
    required this.notifications,
    required this.isSimulating,
    required this.mlModelAccuracy,
    required this.totalBlockedAttacks,
  });

  // Derived properties
  double get networkHealth {
    if (devices.isEmpty) return 100.0;
    final compromised = devices.where((d) => d.status != DeviceStatus.safe).length;
    return max(0.0, 100.0 - (compromised * 12.5));
  }

  SecurityState copyWith({
    List<IoTDevice>? devices,
    List<Anomaly>? anomalies,
    List<SecurityPolicy>? policies,
    List<NetworkTraffic>? trafficFeed,
    List<OpaLogEntry>? opaLogs,
    List<CyberNotification>? notifications,
    bool? isSimulating,
    double? mlModelAccuracy,
    int? totalBlockedAttacks,
  }) {
    return SecurityState(
      devices: devices ?? this.devices,
      anomalies: anomalies ?? this.anomalies,
      policies: policies ?? this.policies,
      trafficFeed: trafficFeed ?? this.trafficFeed,
      opaLogs: opaLogs ?? this.opaLogs,
      notifications: notifications ?? this.notifications,
      isSimulating: isSimulating ?? this.isSimulating,
      mlModelAccuracy: mlModelAccuracy ?? this.mlModelAccuracy,
      totalBlockedAttacks: totalBlockedAttacks ?? this.totalBlockedAttacks,
    );
  }
}

// StateNotifier to orchestrate active threat simulations and telemetry loops
class SecurityNotifier extends StateNotifier<SecurityState> {
  final TelemetryService _telemetryService;
  final OpaService _opaService;
  final WebSocketService _webSocketService;
  final Random _random = Random();
  Timer? _simulationTimer;
  int _ticks = 0;

  SecurityNotifier(this._telemetryService, this._opaService, this._webSocketService)
      : super(const SecurityState(
          devices: [],
          anomalies: [],
          policies: [],
          trafficFeed: [],
          opaLogs: [],
          notifications: [],
          isSimulating: false,
          mlModelAccuracy: 98.4,
          totalBlockedAttacks: 1420,
        )) {
    _initializeData();
  }

  void _initializeData() {
    final initialDevices = _telemetryService.getInitialDevices();
    final initialTraffic = List.generate(20, (_) => _telemetryService.generateRandomTraffic(initialDevices));
    
    state = state.copyWith(
      devices: initialDevices,
      trafficFeed: initialTraffic,
      opaLogs: [
        OpaLogEntry(
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          level: 'INFO',
          message: 'OPA Edge: Policy enforcement engine initialized successfully.',
        ),
      ],
    );

    // Auto-start the simulation loop
    toggleSimulation(true);
  }

  void toggleSimulation(bool active) {
    if (active) {
      if (_simulationTimer != null) return;
      _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _simulationTick());
      state = state.copyWith(isSimulating: true);
      _pushNotification('System telemetry streams initiated.', 'info');
    } else {
      _simulationTimer?.cancel();
      _simulationTimer = null;
      state = state.copyWith(isSimulating: false);
      _pushNotification('System telemetry streams paused.', 'warning');
    }
  }

  // Periodic simulation heartbeat (telemetry shifts, traffic streams, and incident triggers)
  void _simulationTick() {
    _ticks++;
    
    // 1. Shift device telemetry metrics slightly (living dashboard aesthetics)
    final updatedDevices = state.devices.map((device) {
      if (device.status == DeviceStatus.isolated) return device;
      
      final double deltaCpu = (_random.nextDouble() - 0.5) * 4.0;
      final double deltaMem = (_random.nextDouble() - 0.5) * 2.0;
      final double deltaBandwidth = (_random.nextDouble() - 0.5) * 25.0;

      return device.copyWith(
        cpuUsage: max(1.0, min(99.0, device.cpuUsage + deltaCpu)),
        memoryUsage: max(1.0, min(99.0, device.memoryUsage + deltaMem)),
        bandwidth: max(5.0, device.bandwidth + deltaBandwidth),
      );
    }).toList();

    // 2. Generate new live network traffic packets
    final List<NetworkTraffic> newTraffic = List.from(state.trafficFeed);
    final packet1 = _telemetryService.generateRandomTraffic(updatedDevices);
    newTraffic.insert(0, packet1);
    if (newTraffic.length > 40) newTraffic.removeLast(); // Cap traffic buffer size

    // Send mock frame downstream over the WebSocket pipeline
    _webSocketService.injectWebsocketFrame('traffic', packet1.toJson());

    state = state.copyWith(
      devices: updatedDevices,
      trafficFeed: newTraffic,
    );

    // 3. Periodic Threat Injection: Inject anomaly event every 15 ticks
    if (_ticks % 15 == 0) {
      _injectMockIncident();
    }
  }

  // Generates and injects a high-fidelity Zero-Trust cybersecurity attack vector
  void _injectMockIncident() {
    // Pick a safe device to infect
    final safeDevices = state.devices.where((d) => d.status == DeviceStatus.safe).toList();
    if (safeDevices.isEmpty) return;

    final target = safeDevices[_random.nextInt(safeDevices.length)];
    final attackTypes = ['DDoS Flood', 'Port Scanner API', 'Data Exfiltration', 'Modbus MITM Injection'];
    final selectedAttack = attackTypes[_random.nextInt(attackTypes.length)];

    final double risk = 0.75 + (_random.nextDouble() * 0.23);
    final id = 'ANM-${_random.nextInt(90000) + 10000}';

    final incident = Anomaly(
      id: id,
      deviceId: target.id,
      deviceName: target.name,
      attackType: selectedAttack,
      severity: SeverityLevel.critical,
      confidenceScore: 0.94 + (_random.nextDouble() * 0.05),
      timestamp: DateTime.now(),
      details: 'GNN Graph Analyzer detected anomalous relationship behavior: Device ${target.name} initiated rapid out-of-protocol queries across unauthorized networks.',
    );

    // Update infected device risk score and status
    final List<IoTDevice> infectedDevices = state.devices.map((device) {
      if (device.id == target.id) {
        return device.copyWith(
          status: DeviceStatus.warning,
          riskScore: risk,
          cpuUsage: 94.2,
        );
      }
      return device;
    }).toList();

    // Generate corresponding Zero-Trust micro-segmentation JSON policy
    final policyId = 'POL-${_random.nextInt(90000) + 10000}';
    final rawPolicy = '''{
  "policy_id": "$policyId",
  "source_device": "${target.id}",
  "metadata": {
    "ip_address": "${target.ipAddress}",
    "mac_address": "${target.macAddress}"
  },
  "action": "MICRO_SEGMENT",
  "rules": [
    {
      "ingress": "DENY_ALL",
      "egress": {
        "allow": ["10.128.4.1"],
        "deny": ["*"]
      }
    }
  ],
  "enforcement": "OPA_SIDECAR"
}''';

    final policy = SecurityPolicy(
      id: policyId,
      anomalyId: incident.id,
      deviceId: target.id,
      deviceName: target.name,
      rawJsonPolicy: rawPolicy,
      explanation: 'Isolate target device ${target.name} under local OPA rule micro-segmentation. Deny all traffic except to regional SOC gateway.',
      confidence: incident.confidenceScore,
      status: PolicyStatus.pending,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      devices: infectedDevices,
      anomalies: [incident, ...state.anomalies],
      policies: [policy, ...state.policies],
      mlModelAccuracy: min(99.9, state.mlModelAccuracy + 0.1),
    );

    _pushNotification('CRITICAL ALARM: $selectedAttack flagged on ${target.name}!', 'threat');
    _webSocketService.injectWebsocketFrame('anomaly', incident.toJson());
  }

  // Trigger manual cyber attack injection (Security Engineer simulation test)
  void manualAttackTrigger(String deviceId, String attackType) {
    final target = state.devices.firstWhere((d) => d.id == deviceId, orElse: () => state.devices.first);
    
    final id = 'ANM-${_random.nextInt(90000) + 10000}';
    final incident = Anomaly(
      id: id,
      deviceId: target.id,
      deviceName: target.name,
      attackType: attackType,
      severity: SeverityLevel.critical,
      confidenceScore: 0.98,
      timestamp: DateTime.now(),
      details: 'Manual Simulation Injection: Forced $attackType testing payload successfully executed.',
    );

    final List<IoTDevice> infectedDevices = state.devices.map((device) {
      if (device.id == target.id) {
        return device.copyWith(
          status: DeviceStatus.warning,
          riskScore: 0.99,
          cpuUsage: 98.8,
        );
      }
      return device;
    }).toList();

    final policyId = 'POL-${_random.nextInt(90000) + 10000}';
    final rawPolicy = '''{
  "policy_id": "$policyId",
  "manual_simulation": true,
  "target_device": "${target.id}",
  "action": "QUARANTINE",
  "rules": {
    "network_block": true,
    "override_rego": "deny_all_traffic"
  }
}''';

    final policy = SecurityPolicy(
      id: policyId,
      anomalyId: incident.id,
      deviceId: target.id,
      deviceName: target.name,
      rawJsonPolicy: rawPolicy,
      explanation: 'Manual safety quarantine policy. Complete physical and digital packet isolation of ${target.name}.',
      confidence: 1.00,
      status: PolicyStatus.pending,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      devices: infectedDevices,
      anomalies: [incident, ...state.anomalies],
      policies: [policy, ...state.policies],
    );

    _pushNotification('SIMULATION INJECTED: $attackType on ${target.name}!', 'threat');
  }

  // Acknowledges active security anomaly alert
  void acknowledgeAnomaly(String anomalyId) {
    state = state.copyWith(
      anomalies: state.anomalies.map((anm) {
        if (anm.id == anomalyId) {
          return anm.copyWith(isAcknowledged: true);
        }
        return anm;
      }).toList(),
    );
    _pushNotification('Anomaly alert acknowledged.', 'info');
  }

  // Deploys generated policy rules bundle directly to edge OPA engine
  Future<void> deployPolicy(String policyId, String updatedRego) async {
    final policy = state.policies.firstWhere((p) => p.id == policyId);
    
    // Update policy state to pending compile
    state = state.copyWith(
      policies: state.policies.map((p) {
        if (p.id == policyId) {
          return p.copyWith(status: PolicyStatus.approved);
        }
        return p;
      }).toList(),
    );

    _pushNotification('Compiling Rego policies bundle for OPA deployment...', 'info');

    try {
      final logs = await _opaService.deployPolicyToOpa(policyId, updatedRego);
      
      // Update device health status, quarantine it, and restore system health
      final List<IoTDevice> quarantinedDevices = state.devices.map((device) {
        if (device.id == policy.deviceId) {
          return device.copyWith(
            status: DeviceStatus.isolated,
            riskScore: 0.05,
            cpuUsage: 12.5,
          );
        }
        return device;
      }).toList();

      state = state.copyWith(
        devices: quarantinedDevices,
        policies: state.policies.map((p) {
          if (p.id == policyId) {
            return p.copyWith(status: PolicyStatus.deployed);
          }
          return p;
        }).toList(),
        anomalies: state.anomalies.map((anm) {
          if (anm.id == policy.anomalyId) {
            return anm.copyWith(isMitigated: true, isAcknowledged: true);
          }
          return anm;
        }).toList(),
        opaLogs: [...logs, ...state.opaLogs],
        totalBlockedAttacks: state.totalBlockedAttacks + 1,
      );

      _pushNotification('OPA Deploy Success! ${policy.deviceName} successfully quarantined.', 'deploy');
    } catch (e) {
      state = state.copyWith(
        policies: state.policies.map((p) {
          if (p.id == policyId) {
            return p.copyWith(status: PolicyStatus.rejected);
          }
          return p;
        }).toList(),
      );
      _pushNotification('OPA Compile Error: Rego rule verification failed.', 'warning');
    }
  }

  // Rejects security policy recommendation
  void rejectPolicy(String policyId) {
    final policy = state.policies.firstWhere((p) => p.id == policyId);
    
    // Revert device back to safe/muted state if no other anomaly exists
    final List<IoTDevice> restoredDevices = state.devices.map((device) {
      if (device.id == policy.deviceId) {
        return device.copyWith(
          status: DeviceStatus.safe,
          riskScore: 0.15,
        );
      }
      return device;
    }).toList();

    state = state.copyWith(
      devices: restoredDevices,
      policies: state.policies.map((p) {
        if (p.id == policyId) {
          return p.copyWith(status: PolicyStatus.rejected);
        }
        return p;
      }).toList(),
    );

    _pushNotification('Policy request rejected. Device restored to telemetry.', 'warning');
  }

  // Clear or read notifications
  void clearNotifications() {
    state = state.copyWith(notifications: []);
  }

  void markNotificationAsRead(String id) {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) {
          n.isRead = true;
        }
        return n;
      }).toList(),
    );
  }

  void _pushNotification(String message, String type) {
    final n = CyberNotification(
      id: 'NTF-${_random.nextInt(90000) + 10000}',
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(notifications: [n, ...state.notifications]);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

// Global Security Provider
final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  final telemetryService = ref.watch(telemetryServiceProvider);
  final opaService = ref.watch(opaServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return SecurityNotifier(telemetryService, opaService, webSocketService);
});
