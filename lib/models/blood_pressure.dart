
class BloodPressure {
  String? id;
  String? userId;
  int systolic;
  int diastolic;
  DateTime timestamp;
  String? comment;

  BloodPressure({
    this.id,
    this.userId,
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': timestamp.toIso8601String(),
      'comment': comment,
    };
  }

  factory BloodPressure.fromMap(Map<String, dynamic> map) {
    return BloodPressure(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      comment: map['comment'] as String?,
    );
  }
}
