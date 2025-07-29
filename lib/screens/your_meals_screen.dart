import 'package:flutter/material.dart';
import 'package:myapp/models/meal.dart';
import 'package:myapp/models/meal_item.dart';
import 'package:myapp/models/meal_item_option.dart';
import 'package:myapp/models/user_meal_plan.dart';
import 'package:myapp/models/nutrition_restriction.dart'; // Import NutritionRestriction
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/widgets/upload_diet_dialog.dart'; // Import the new dialog widget

class YourMealsScreen extends StatefulWidget {
  const YourMealsScreen({super.key});

  @override
  State<YourMealsScreen> createState() => _YourMealsScreenState();
}

class _YourMealsScreenState extends State<YourMealsScreen> {
  late Future<Map<String, dynamic>> _mealPlanFuture;
  late Future<List<NutritionRestriction>> _nutritionRestrictionsFuture;

  final List<List<Color>> _gradientColors = [
    [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)], // Light Green
    [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)], // Light Cyan
    [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)], // Light Orange
    [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)], // Light Purple
    [const Color(0xFFFBE9E7), const Color(0xFFFFCCBC)], // Light Red/Peach
  ];

  final Map<String, IconData> _mealIcons = {
    'Breakfast': Icons.breakfast_dining,
    'Lunch': Icons.lunch_dining,
    'Dinner': Icons.dinner_dining,
    'Snack': Icons.cookie,
    // Add more meal types and their corresponding icons as needed
  };

  final Map<String, IconData> _nutritionRestrictionIcons = {
    'Carbs': Icons.monitor_weight, // Example icon for Carbs
    'Fat': Icons.local_fire_department, // Example icon for Fat
    'Protein': Icons.fitness_center, // Example icon for Protein
    // Add more nutrition keys and their corresponding icons as needed
  };

  IconData _getMealIcon(String mealType) {
    return _mealIcons[mealType] ?? Icons.fastfood; // Default icon
  }

  IconData _getNutritionIcon(String nutritionKey) {
    return _nutritionRestrictionIcons[nutritionKey] ?? Icons.fastfood; // Default icon
  }

  @override
  void initState() {
    super.initState();
    _mealPlanFuture = SupabaseService().getMealPlan();
    _nutritionRestrictionsFuture = SupabaseService().getNutritionRestrictions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white, // Set background to white
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Your Meals', // Fixed title as requested
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                              fontSize: 24.0,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button space
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _mealPlanFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Expanded(child: Center(child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      return Expanded(child: Center(child: Text('Error: ${snapshot.error}')));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No meal plan found.',
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Upload your diet chart by clicking the 'Upload Diet' button below to import your personalized meal plan.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    final userMealPlan = UserMealPlan.fromMap(data['userMealPlan']);
                    final meals = (data['meals'] as List).map((e) => Meal.fromMap(e)).toList();
                    final mealItems = (data['mealItems'] as List).map((e) => MealItem.fromMap(e)).toList();
                    final mealItemOptions = (data['mealItemOptions'] as List).map((e) => MealItemOption.fromMap(e)).toList();

                    return Expanded( // Wrap the rest of the content in Expanded
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Original meal plan name and description, now inside FutureBuilder
                    // Nutritional Restrictions Grid List
                    FutureBuilder<List<NutritionRestriction>>(
                      future: _nutritionRestrictionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final restrictions = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Your Daily Nutritional Limit',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: restrictions.length,
                                itemBuilder: (context, index) {
                                  final restriction = restrictions[index];
                                  final gradient = _gradientColors[index % _gradientColors.length];
                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: gradient,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getNutritionIcon(restriction.nutritionKey), // Get icon based on nutrition key
                                            color: Colors.blue.shade900,
                                            size: 20, // Reduced icon size
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            restriction.nutritionKey,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade900, // Adjusted color for better contrast on gradients
                                                  fontSize: 12.0, // Set font size to 12
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            restriction.nutritionValue,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  color: Colors.blue.shade800, // Adjusted color for better contrast on gradients
                                                  fontSize: 10.0, // Set font size to 10
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16), // Added spacing

                    // Moved planName and description here
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          userMealPlan.planName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                                fontSize: 24.0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userMealPlan.description ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.blue.shade800,
                              ),
                        ),
                      ],
                    ),
                     // Added spacing

                    Expanded(
                      child: ListView.builder(
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          final meal = meals[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _gradientColors[
                                            (mealItems.indexOf(item) + 2) %
                                                _gradientColors.length], // Use a different gradient for meal items
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.restaurant_menu, // Generic food icon
                                              color: Colors.blue.shade900,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item.itemName,
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue.shade900, // Adjusted color for better contrast
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...mealItemOptions.where((option) => option.itemId == item.itemId).toList().asMap().entries.map((entry) {
                                          final optionIndex = entry.key;
                                          final option = entry.value;
                                          final isLastOption = optionIndex == mealItemOptions.where((o) => o.itemId == item.itemId).length - 1;

                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        border: Border.all(color: Colors.grey.shade300),
                                                      ),
                                                      child: Text(
                                                        option.amount ?? '',
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                              fontSize: 14.0,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black87,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        option.foodName,
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                              fontSize: 16.0,
                                                              color: Colors.blue.shade900,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!isLastOption)
                                                Center(
                                                  child: Text(
                                                    'OR',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.blue.shade400,
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }),
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const UploadDietDialog();
            },
          );
        },
        label: const Text('Upload Diet'),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }
}
