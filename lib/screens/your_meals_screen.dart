import 'package:flutter/material.dart';
import 'package:myapp/models/meal.dart';
import 'package:myapp/models/meal_item.dart';
import 'package:myapp/models/meal_item_option.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/meal.dart';
import 'package:myapp/models/meal_item.dart';
import 'package:myapp/models/meal_item_option.dart';
import 'package:myapp/models/user_meal_plan.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/screens/upload_file_screen.dart';

class YourMealsScreen extends StatefulWidget {
  const YourMealsScreen({Key? key}) : super(key: key);

  @override
  State<YourMealsScreen> createState() => _YourMealsScreenState();
}

class _YourMealsScreenState extends State<YourMealsScreen> {
  late Future<Map<String, dynamic>> _mealPlanFuture;

  @override
  void initState() {
    super.initState();
    _mealPlanFuture = SupabaseService().getMealPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meals'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _mealPlanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meal plan found.'));
          }

          final data = snapshot.data!;
          final userMealPlan = UserMealPlan.fromMap(data['userMealPlan']);
          final meals = (data['meals'] as List).map((e) => Meal.fromMap(e)).toList();
          final mealItems = (data['mealItems'] as List).map((e) => MealItem.fromMap(e)).toList();
          final mealItemOptions = (data['mealItemOptions'] as List).map((e) => MealItemOption.fromMap(e)).toList();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE1F5FE),
                  Color(0xFFB3E5FC),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      userMealPlan.planName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      userMealPlan.description ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                '${meal.mealType} (${meal.timing})',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (var item in mealItems.where((item) => item.mealId == meal.mealId))
                              Card(
                                elevation: 6,
                                shadowColor: Colors.blue.shade200.withOpacity(0.7),
                                margin: const EdgeInsets.only(bottom: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade800,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: mealItemOptions.where((option) => option.itemId == item.itemId).length,
                                        itemBuilder: (context, optionIndex) {
                                          final option = mealItemOptions.where((option) => option.itemId == item.itemId).toList()[optionIndex];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  option.foodName,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  option.amount ?? '',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          if (mealItemOptions.where((option) => option.itemId == item.itemId).length > 1) {
                                            return Center(
                                              child: Text(
                                                'OR',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue.shade400,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadFileScreen()),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
