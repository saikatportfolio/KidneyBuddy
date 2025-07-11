import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/patient_details.dart';
import '../utils/ckd_diet_calculator.dart'; // Import CKDDietCalculator

class FoodDetailPage extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailPage({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final patientDetails = Provider.of<PatientDetailsProvider>(context).patientDetails;
    final String ckdStage = patientDetails?.ckdStage ?? 'Stage 1'; // Default to Stage 1 if not available

    return Scaffold(
      appBar: AppBar(
        title: Text(foodItem.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // Food Details Card
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: foodItem.flagColor,
                          radius: 14,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          foodItem.flagText,
                          style: TextStyle(
                            color: foodItem.flagColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      foodItem.safetyExplanation ?? 'No specific safety explanation available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Divider(height: 24, thickness: 1),
                    Text(
                      'Category: ${foodItem.category}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (foodItem.source != null && foodItem.source!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Source: ${foodItem.source}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacing between cards

            // Safety Flag Explanations (Legend)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safety Flag Meanings:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildFlagMeaningRow(Colors.green, 'Safe', 'Generally suitable for consumption.'),
                    _buildFlagMeaningRow(Colors.yellow[700]!, 'Limit', 'Generally can Consume in moderation.'),
                    _buildFlagMeaningRow(Colors.red, 'Danger', 'Generally be harmful.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacing between cards and next element (Nutrition Info Card)

            // Nutrition Info Card
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Info (per 100g):',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientRow('Sodium', foodItem.sodium, 'mg', CKDDietCalculator.getNutrientFlag(foodItem.sodium, 'Sodium', ckdStage)),
                    _buildNutrientRow('Potassium', foodItem.potassium, 'mg', CKDDietCalculator.getNutrientFlag(foodItem.potassium, 'Potassium', ckdStage)),
                    _buildNutrientRow('Phosphorus', foodItem.phosphorus, 'mg', CKDDietCalculator.getNutrientFlag(foodItem.phosphorus, 'Phosphorus', ckdStage)),
                    _buildNutrientRow('Protein', foodItem.protein, 'g', CKDDietCalculator.getNutrientFlag(foodItem.protein, 'Protein', ckdStage)),
                    _buildNutrientRow('Carbohydrates', foodItem.carbs, 'g', null),
                    _buildNutrientRow('Fat', foodItem.fat, 'g', null),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagMeaningRow(Color color, String flagText, String explanation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 8,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flagText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  explanation,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value, String unit, SafetyFlag? flag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: const TextStyle(fontSize: 16),
              ),
              if (flag != null) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: flag == SafetyFlag.green
                      ? Colors.green
                      : flag == SafetyFlag.yellow
                          ? Colors.yellow[700]
                          : Colors.red,
                  radius: 6,
                ),
                const SizedBox(width: 4),
                Text(
                  flag == SafetyFlag.green
                      ? 'Safe'
                      : flag == SafetyFlag.yellow
                          ? 'Limit'
                          : 'Danger',
                  style: TextStyle(
                    fontSize: 12,
                    color: flag == SafetyFlag.green
                        ? Colors.green
                        : flag == SafetyFlag.yellow
                            ? Colors.yellow[700]
                            : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
