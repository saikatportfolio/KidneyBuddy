class EducationVideo {
  final String videoId;
  final int categoryId;
  final String videoName;
  final String videoImageURL;
  final String videoUrl;

  EducationVideo({
    required this.videoId,
    required this.categoryId,
    required this.videoName,
    required this.videoImageURL,
    required this.videoUrl,
  });

  factory EducationVideo.fromJson(Map<String, dynamic> json) {
    return EducationVideo(
      videoId: json['videoId'] as String,
      categoryId: json['categoryId'] as int,
      videoName: json['videoName'] as String,
      videoImageURL: json['videoImageURL'] as String,
      videoUrl: json['videoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'categoryId': categoryId,
      'videoName': videoName,
      'videoImageURL': videoImageURL,
      'videoUrl': videoUrl,
    };
  }
}
