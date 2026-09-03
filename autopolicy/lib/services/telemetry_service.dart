import 'dart:math';
import '../models/device.dart';
import '../models/traffic.dart';

class TelemetryService {
  final Random _random = Random();

  // Baseline hardcoded devices reflecting an enterprise Zero-Trust IoT framework
  List<IoTDevice> getInitialDevices() {
    return [
      const IoTDevice(
        id: 'DEV-001',
        name: 'GNN-Gateway-Alpha',
        ipAddress: '10.128.4.1',
        macAddress: '00:1A:2B:3C:4D:5E',
        deviceType: 'Industrial Gateway',
        protocol: 'HTTP/HTTPS',
        riskScore: 0.12,
        status: DeviceStatus.safe,
        bandwidth: 320.5,
        cpuUsage: 22.4,
        memoryUsage: 45.1,
        connections: ['DEV-002', 'DEV-003', 'DEV-004', 'DEV-007'],
      ),
      const IoTDevice(
        id: 'DEV-002',
        name: 'SmartLock-Vault-01',
        ipAddress: '10.128.4.10',
        macAddress: '3C:D9:2B:A1:4D:8F',
        deviceType: 'Smart Lock',
        protocol: 'MQTT',
        riskScore: 0.05,
        status: DeviceStatus.safe,
        bandwidth: 12.8,
        cpuUsage: 4.2,
        memoryUsage: 12.8,
        connections: ['DEV-001'],
      ),
      const IoTDevice(
        id: 'DEV-003',
        name: 'SOC-Camera-South',
        ipAddress: '10.128.4.11',
        macAddress: '00:25:90:3A:4C:1E',
        deviceType: 'IP Camera',
        protocol: 'RTSP',
        riskScore: 0.28,
        status: DeviceStatus.safe,
        bandwidth: 1450.0,
        cpuUsage: 68.1,
        memoryUsage: 54.6,
        connections: ['DEV-001', 'DEV-008'],
      ),
      const IoTDevice(
        id: 'DEV-004',
        name: 'SmartLock-Main-Exit',
        ipAddress: '10.128.4.12',
        macAddress: '3C:D9:2B:A1:7E:9A',
        deviceType: 'Smart Lock',
        protocol: 'CoAP',
        riskScore: 0.08,
        status: DeviceStatus.safe,
        bandwidth: 8.4,
        cpuUsage: 3.1,
        memoryUsage: 11.2,
        connections: ['DEV-001', 'DEV-005'],
      ),
      const IoTDevice(
        id: 'DEV-005',
        name: 'Thermal-Sensor-Core',
        ipAddress: '10.128.4.20',
        macAddress: '00:80:41:AE:FD:7C',
        deviceType: 'Industrial Sensor',
        protocol: 'Modbus',
        riskScore: 0.15,
        status: DeviceStatus.safe,
        bandwidth: 45.2,
        cpuUsage: 14.8,
        memoryUsage: 28.3,
        connections: ['DEV-004', 'DEV-006'],
      ),
      const IoTDevice(
        id: 'DEV-006',
        name: 'PLC-Water-Pump',
        ipAddress: '10.128.4.21',
        macAddress: '00:60:E0:51:7A:B4',
        deviceType: 'Industrial PLC',
        protocol: 'Modbus',
        riskScore: 0.02,
        status: DeviceStatus.safe,
        bandwidth: 18.2,
        cpuUsage: 8.5,
        memoryUsage: 19.4,
        connections: ['DEV-005', 'DEV-007'],
      ),
      const IoTDevice(
        id: 'DEV-007',
        name: 'SCADA-Turbine-Ctrl',
        ipAddress: '10.128.4.30',
        macAddress: '00:40:96:A2:2E:3F',
        deviceType: 'Industrial SCADA',
        protocol: 'OPC-UA',
        riskScore: 0.22,
        status: DeviceStatus.safe,
        bandwidth: 88.0,
        cpuUsage: 25.1,
        memoryUsage: 48.0,
        connections: ['DEV-001', 'DEV-006', 'DEV-009'],
      ),
      const IoTDevice(
        id: 'DEV-008',
        name: 'Cardiac-Gateway-B3',
        ipAddress: '192.168.10.5',
        macAddress: '00:09:B0:C1:D2:E3',
        deviceType: 'Medical Device',
        protocol: 'MQTT',
        riskScore: 0.10,
        status: DeviceStatus.safe,
        bandwidth: 110.4,
        cpuUsage: 18.2,
        memoryUsage: 35.8,
        connections: ['DEV-003', 'DEV-010'],
      ),
      const IoTDevice(
        id: 'DEV-009',
        name: 'Ventilator-NICU-04',
        ipAddress: '192.168.10.15',
        macAddress: '00:1D:2E:3F:4A:5B',
        deviceType: 'Medical Device',
        protocol: 'HTTP',
        riskScore: 0.04,
        status: DeviceStatus.safe,
        bandwidth: 64.2,
        cpuUsage: 9.3,
        memoryUsage: 22.7,
        connections: ['DEV-007', 'DEV-010'],
      ),
      const IoTDevice(
        id: 'DEV-010',
        name: 'PAC-Server-Main',
        ipAddress: '192.168.10.100',
        macAddress: '00:15:5D:01:14:AB',
        deviceType: 'Medical PACS',
        protocol: 'DICOM',
        riskScore: 0.35,
        status: DeviceStatus.safe,
        bandwidth: 2450.0,
        cpuUsage: 45.4,
        memoryUsage: 78.2,
        connections: ['DEV-008', 'DEV-009', 'DEV-011', 'DEV-012'],
      ),
      const IoTDevice(
        id: 'DEV-011',
        name: 'Infusion-Pump-5A',
        ipAddress: '192.168.10.22',
        macAddress: '00:0B:5C:88:2E:11',
        deviceType: 'Medical Device',
        protocol: 'MQTT',
        riskScore: 0.09,
        status: DeviceStatus.safe,
        bandwidth: 15.6,
        cpuUsage: 5.6,
        memoryUsage: 14.8,
        connections: ['DEV-010'],
      ),
      const IoTDevice(
        id: 'DEV-012',
        name: 'Lab-Analyzer-X1',
        ipAddress: '192.168.10.50',
        macAddress: '00:50:C2:59:7D:09',
        deviceType: 'Medical Device',
        protocol: 'HTTP',
        riskScore: 0.18,
        status: DeviceStatus.safe,
        bandwidth: 180.5,
        cpuUsage: 32.4,
        memoryUsage: 40.5,
        connections: ['DEV-010'],
      ),
    ];
  }

  // Simulates a single random packet flowing through the network
  NetworkTraffic generateRandomTraffic(List<IoTDevice> devices) {
    final src = devices[_random.nextInt(devices.length)];
    String destId = src.connections.isNotEmpty
        ? src.connections[_random.nextInt(src.connections.length)]
        : src.id;
    
    final dest = devices.firstWhere((d) => d.id == destId, orElse: () => src);

    final protocols = ['MQTT', 'CoAP', 'Modbus', 'HTTP', 'OPC-UA', 'DICOM', 'RTSP'];
    final selectedProtocol = protocols.contains(src.protocol) ? src.protocol : protocols[_random.nextInt(protocols.length)];
    final size = _random.nextInt(1500) + 64; // packet size in bytes

    final bool isSuspicious = src.status != DeviceStatus.safe && _random.nextDouble() > 0.4;
    final info = isSuspicious 
        ? 'ALERT: Unaligned buffer frame detected during raw binary stream transmission'
        : 'Packet transmission successful: Payload size $size bytes';

    return NetworkTraffic(
      id: 'TRF-${_random.nextInt(90000) + 10000}',
      sourceId: src.id,
      sourceName: src.name,
      destId: dest.id,
      destName: dest.name,
      protocol: selectedProtocol,
      packetSize: size,
      timestamp: DateTime.now(),
      info: info,
      isSuspicious: isSuspicious,
    );
  }
}
