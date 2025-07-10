import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/patient_details.dart';
import '../services/food_recommendation_service.dart';
import 'food_detail_page.dart';

class FoodCategoryTab extends StatefulWidget {
  final List<String> categories;

  const FoodCategoryTab({super.key, required this.categories});

  @override
  State<FoodCategoryTab> createState() => _FoodCategoryTabState();
}

class _FoodCategoryTabState extends State<FoodCategoryTab> with AutomaticKeepAliveClientMixin {
  late Future<List<FoodItem>> _foodItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  void _loadFoodItems() {
    final patientDetails = Provider.of<PatientDetailsProvider>(context, listen: false).patientDetails;
    if (patientDetails != null) {
      _foodItemsFuture = FoodRecommendationService().getRecommendedFoods(patientDetails.ckdStage).then((allFoods) {
        if (widget.categories.contains('All')) {
          return allFoods; // If 'All' category is requested, return all foods
        } else {
          return allFoods.where((food) => widget.categories.contains(food.category)).toList();
        }
      });
    } else {
      _foodItemsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return FutureBuilder<List<FoodItem>>(
      future: _foodItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No food recommendations available for this category.'));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8, // Adjust aspect ratio for better card sizing
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final foodItem = snapshot.data![index];
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias, // Ensures image respects rounded corners
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailPage(foodItem: foodItem),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty
                            ? Image.network(
                                foodItem.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey));
                                },
                              )
                            : const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.grey)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // Center align content
                          children: [
                            Text(
                              foodItem.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // Center the text
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8), // Increased spacing
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: foodItem.flagColor.withOpacity(0.2), // Subtle background color
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: foodItem.flagColor, width: 1),
                              ),
                              child: Text(
                                foodItem.flagText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: foodItem.flagColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8), // Increased spacing
                            Text(
                              foodItem.safetyExplanation ?? '',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              textAlign: TextAlign.center, // Center the explanation
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the state of the tab alive
}
