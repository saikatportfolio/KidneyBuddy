import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/food_item.dart';
// Import CKDDietCalculator
import '../services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FoodDetailPage extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailPage({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(foodItem.name),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty)
                  Center(
                    child: Image.network(
                      foodItem.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey));
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // Disclaimer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Disclaimer : This is just a general guidance. Please consult with renal deitician before choosing any food for you",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Gemini Response
                FutureBuilder<String>(
                  future: GeminiService.getFoodRecommendation(foodItem.name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitWave(
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Markdown(
                          data: snapshot.data ?? 'No data',
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
                ),
      ),
      ),
    );
  }
}
