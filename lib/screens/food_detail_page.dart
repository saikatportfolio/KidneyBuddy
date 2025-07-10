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
            Text(
              foodItem.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: foodItem.flagColor,
                  radius: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  foodItem.flagText, // Use flagText getter for display
                  style: TextStyle(
                    color: foodItem.flagColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              foodItem.safetyExplanation ?? 'No specific safety explanation available.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Nutritional Information (per 100g):',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildNutrientRow('Sodium', foodItem.sodium, 'mg', CKDDietCalculator.getNutrientFlag(foodItem.sodium, 'Sodium', ckdStage)),
            _buildNutrientRow('Potassium', foodItem.potassium, 'mg', CKDDietCalculator.getNutrientFlag(foodItem.potassium, 'Potassium', ckdStage)),
            _buildNutrientRow('Phosphorus', foodItem.phosphorus, 'mg', CKDDietCalculator.getNutrientFlag(foodItem.phosphorus, 'Phosphorus', ckdStage)),
            _buildNutrientRow('Protein', foodItem.protein, 'g', CKDDietCalculator.getNutrientFlag(foodItem.protein, 'Protein', ckdStage)),
            _buildNutrientRow('Carbohydrates', foodItem.carbs, 'g', null), // No safety flag for carbs
            _buildNutrientRow('Fat', foodItem.fat, 'g', null), // No safety flag for fat
            const SizedBox(height: 16),
            Text(
              'Category: ${foodItem.category}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (foodItem.source != null && foodItem.source!.isNotEmpty)
              Text(
                'Source: ${foodItem.source}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
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
                          : 'Avoid',
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
