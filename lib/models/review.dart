
class Review {
  final int id;
  final int dieticianId;
  final String patientName;
  final String patientDetails;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.dieticianId,
    required this.patientName,
    required this.patientDetails,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as int,
      dieticianId: map['dietician_id'] as int,
      patientName: map['patient_name'] as String,
      patientDetails: map['patient_details'] as String,
      comment: map['comment'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dietician_id': dieticianId,
      'patient_name': patientName,
      'patient_details': patientDetails,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Review(id: $id, dieticianId: $dieticianId, patientName: $patientName, patientDetails: $patientDetails, comment: $comment, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Review &&
      other.id == id &&
      other.dieticianId == dieticianId &&
      other.patientName == patientName &&
      other.patientDetails == patientDetails &&
      other.comment == comment &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      dieticianId.hashCode ^
      patientName.hashCode ^
      patientDetails.hashCode ^
      comment.hashCode ^
      createdAt.hashCode;
  }
}
