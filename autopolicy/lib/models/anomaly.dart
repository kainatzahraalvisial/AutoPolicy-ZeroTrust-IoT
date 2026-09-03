enum SeverityLevel { critical, high, medium, low }

class Anomaly {
  final String id;
  final String deviceId;
  final String deviceName;
  final String attackType;
  final SeverityLevel severity;
  final double confidenceScore;
  final DateTime timestamp;
  final String details;
  final bool isAcknowledged;
  final bool isMitigated;

  const Anomaly({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.attackType,
    required this.severity,
    required this.confidenceScore,
    required this.timestamp,
    required this.details,
    this.isAcknowledged = false,
    this.isMitigated = false,
  });

  Anomaly copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? attackType,
    SeverityLevel? severity,
    double? confidenceScore,
    DateTime? timestamp,
    String? details,
    bool? isAcknowledged,
    bool? isMitigated,
  }) {
    return Anomaly(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      attackType: attackType ?? this.attackType,
      severity: severity ?? this.severity,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isMitigated: isMitigated ?? this.isMitigated,
    );
  }

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    return Anomaly(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      attackType: json['attackType'] as String,
      severity: SeverityLevel.values.firstWhere((e) => e.toString().split('.').last == json['severity']),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as String,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      isMitigated: json['isMitigated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'attackType': attackType,
      'severity': severity.toString().split('.').last,
      'confidenceScore': confidenceScore,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
      'isAcknowledged': isAcknowledged,
      'isMitigated': isMitigated,
    };
  }
}
