class UserFile {
  String? fileId;
  String? userId;
  String fileName;
  String fileUrl;
  DateTime? uploadedAt;

  UserFile({
    this.fileId,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'file_id': fileId,
      'user_id': userId,
      'file_name': fileName,
      'file_url': fileUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }

  factory UserFile.fromMap(Map<String, dynamic> map) {
    return UserFile(
      fileId: map['file_id'] as String?,
      userId: map['user_id'] as String?,
      fileName: map['file_name'],
      fileUrl: map['file_url'],
      uploadedAt: map['uploaded_at'] != null ? DateTime.parse(map['uploaded_at']) : null,
    );
  }
}
