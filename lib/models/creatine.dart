class Creatine {
  String? id;
  String? userId;
  double value;
  DateTime timestamp;
  String? comment;

  Creatine({
    this.id,
    this.userId,
    required this.value,
    required this.timestamp,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'comment': comment,
    };
  }

  factory Creatine.fromMap(Map<String, dynamic> map) {
    return Creatine(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      value: (map['value'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      comment: map['comment'] as String?,
    );
  }
}
