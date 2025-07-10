import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodDetailPage extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailPage({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
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
                  foodItem.safetyFlag?.name.toUpperCase() ?? 'UNKNOWN',
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
              'Nutritional Information (per serving):',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildNutrientRow('Sodium', foodItem.sodium, 'mg'),
            _buildNutrientRow('Potassium', foodItem.potassium, 'mg'),
            _buildNutrientRow('Phosphorus', foodItem.phosphorus, 'mg'),
            _buildNutrientRow('Protein', foodItem.protein, 'g'),
            const SizedBox(height: 16),
            Text(
              'Category: ${foodItem.category}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Indian Food: ${foodItem.isIndianFood ? 'Yes' : 'No'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              foodItem.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
