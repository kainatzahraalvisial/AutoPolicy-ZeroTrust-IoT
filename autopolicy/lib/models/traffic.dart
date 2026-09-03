class NetworkTraffic {
  final String id;
  final String sourceId;
  final String sourceName;
  final String destId;
  final String destName;
  final String protocol;
  final int packetSize;
  final DateTime timestamp;
  final String info;
  final bool isSuspicious;

  const NetworkTraffic({
    required this.id,
    required this.sourceId,
    required this.sourceName,
    required this.destId,
    required this.destName,
    required this.protocol,
    required this.packetSize,
    required this.timestamp,
    required this.info,
    this.isSuspicious = false,
  });

  factory NetworkTraffic.fromJson(Map<String, dynamic> json) {
    return NetworkTraffic(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      sourceName: json['sourceName'] as String,
      destId: json['destId'] as String,
      destName: json['destName'] as String,
      protocol: json['protocol'] as String,
      packetSize: json['packetSize'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      info: json['info'] as String,
      isSuspicious: json['isSuspicious'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'sourceName': sourceName,
      'destId': destId,
      'destName': destName,
      'protocol': protocol,
      'packetSize': packetSize,
      'timestamp': timestamp.toIso8601String(),
      'info': info,
      'isSuspicious': isSuspicious,
    };
  }
}
