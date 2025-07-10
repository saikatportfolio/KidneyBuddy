import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/patient_details.dart';
import '../services/food_recommendation_service.dart';
import 'food_detail_page.dart'; // We will create this next

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  late Future<List<FoodItem>> _foodItemsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFoodItems();
  }

  void _loadFoodItems() {
    final patientDetails = Provider.of<PatientDetailsProvider>(context).patientDetails;
    if (patientDetails != null) {
      _foodItemsFuture = FoodRecommendationService().getRecommendedFoods(patientDetails.ckdStage);
    } else {
      // Handle case where patient details are not available (e.g., show empty list or error)
      _foodItemsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recommendations'),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _foodItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No food recommendations available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final foodItem = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: foodItem.flagColor,
                      radius: 10,
                    ),
                    title: Text(foodItem.name),
                    subtitle: Text(foodItem.safetyExplanation ?? 'Tap for details'),
                    trailing: foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty
                        ? Image.network(
                            foodItem.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailPage(foodItem: foodItem),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
