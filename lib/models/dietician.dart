
class Dietician {
  final String id;
  final String name;
  final String experience;
  final String specialty;
  final String imageUrl;
  final String whatsappNumber;
  final String education;
  final String availableDay;
  final String availableHour;

  Dietician({
    required this.id,
    required this.name,
    required this.experience,
    required this.specialty,
    required this.imageUrl,
    required this.whatsappNumber,
    required this.education,
    required this.availableDay,
    required this.availableHour,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'experience': experience,
      'specialty': specialty,
      'image_url': imageUrl,
      'whatsapp_number': whatsappNumber,
      'education': education,
      'available_day': availableDay,
      'available_hour': availableHour,
    };
  }

  factory Dietician.fromMap(Map<String, dynamic> map) {
    return Dietician(
      id: map['id'].toString(), // Convert int to String
      name: map['name'] as String,
      experience: map['experience'] as String,
      specialty: map['specialty'] as String,
      imageUrl: map['image_url'] as String,
      whatsappNumber: map['whatsapp_number'] as String,
      education: map['education'] as String,
      availableDay: map['available_day'] as String,
      availableHour: map['available_hour'] as String,
    );
  }
}
