enum DeviceStatus { safe, warning, isolated }

class IoTDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String macAddress;
  final String deviceType;
  final String protocol;
  final double riskScore;
  final DeviceStatus status;
  final double bandwidth;
  final double cpuUsage;
  final double memoryUsage;
  final List<String> connections;

  const IoTDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.macAddress,
    required this.deviceType,
    required this.protocol,
    required this.riskScore,
    required this.status,
    required this.bandwidth,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.connections,
  });

  IoTDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? macAddress,
    String? deviceType,
    String? protocol,
    double? riskScore,
    DeviceStatus? status,
    double? bandwidth,
    double? cpuUsage,
    double? memoryUsage,
    List<String>? connections,
  }) {
    return IoTDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      deviceType: deviceType ?? this.deviceType,
      protocol: protocol ?? this.protocol,
      riskScore: riskScore ?? this.riskScore,
      status: status ?? this.status,
      bandwidth: bandwidth ?? this.bandwidth,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      connections: connections ?? this.connections,
    );
  }

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      macAddress: json['macAddress'] as String,
      deviceType: json['deviceType'] as String,
      protocol: json['protocol'] as String,
      riskScore: (json['riskScore'] as num).toDouble(),
      status: DeviceStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      bandwidth: (json['bandwidth'] as num).toDouble(),
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      memoryUsage: (json['memoryUsage'] as num).toDouble(),
      connections: List<String>.from(json['connections'] as Iterable),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'deviceType': deviceType,
      'protocol': protocol,
      'riskScore': riskScore,
      'status': status.toString().split('.').last,
      'bandwidth': bandwidth,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'connections': connections,
    };
  }
}
