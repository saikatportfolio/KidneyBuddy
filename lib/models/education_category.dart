class EducationCategory {
  final int categoryId;
  final String categoryName;
  final String categoryImage;

  EducationCategory({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImage,
  });

  factory EducationCategory.fromJson(Map<String, dynamic> json) {
    return EducationCategory(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      categoryImage: json['categoryImage'],
    );
  }
}
