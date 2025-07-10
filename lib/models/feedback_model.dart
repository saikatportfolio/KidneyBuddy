import 'package:flutter/foundation.dart';

class FeedbackModel {
  String? id; // Changed to String for UUID
  String name;
  String phoneNumber;
  String feedbackText;
  String category; // Added for feedback category
  DateTime timestamp;

  FeedbackModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.feedbackText,
    required this.category, // Added to constructor
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'name': name,
      'phone_number': phoneNumber,
      'feedback_text': feedbackText,
      'category': category, // Added to map
      'timestamp': timestamp.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as String?, // Cast to String?
      name: map['name'],
      phoneNumber: map['phone_number'],
      feedbackText: map['feedback_text'],
      category: map['category'], // Added from map
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class FeedbackProvider with ChangeNotifier {
  List<FeedbackModel> _feedbacks = [];

  List<FeedbackModel> get feedbacks => _feedbacks;

  void addFeedback(FeedbackModel feedback) {
    _feedbacks.add(feedback);
    notifyListeners();
  }

  void setFeedbacks(List<FeedbackModel> feedbacks) {
    _feedbacks = feedbacks;
    notifyListeners();
  }
}
