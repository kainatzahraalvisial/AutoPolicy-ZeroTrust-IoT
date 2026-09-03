enum PolicyStatus { pending, approved, deployed, rejected }

class SecurityPolicy {
  final String id;
  final String anomalyId;
  final String deviceId;
  final String deviceName;
  final String rawJsonPolicy;
  final String explanation;
  final double confidence;
  final PolicyStatus status;
  final DateTime timestamp;

  const SecurityPolicy({
    required this.id,
    required this.anomalyId,
    required this.deviceId,
    required this.deviceName,
    required this.rawJsonPolicy,
    required this.explanation,
    required this.confidence,
    required this.status,
    required this.timestamp,
  });

  SecurityPolicy copyWith({
    String? id,
    String? anomalyId,
    String? deviceId,
    String? deviceName,
    String? rawJsonPolicy,
    String? explanation,
    double? confidence,
    PolicyStatus? status,
    DateTime? timestamp,
  }) {
    return SecurityPolicy(
      id: id ?? this.id,
      anomalyId: anomalyId ?? this.anomalyId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      rawJsonPolicy: rawJsonPolicy ?? this.rawJsonPolicy,
      explanation: explanation ?? this.explanation,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory SecurityPolicy.fromJson(Map<String, dynamic> json) {
    return SecurityPolicy(
      id: json['id'] as String,
      anomalyId: json['anomalyId'] as String,
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      rawJsonPolicy: json['rawJsonPolicy'] as String,
      explanation: json['explanation'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      status: PolicyStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anomalyId': anomalyId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'rawJsonPolicy': rawJsonPolicy,
      'explanation': explanation,
      'confidence': confidence,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
