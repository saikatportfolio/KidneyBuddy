import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myapp/utils/logger_config.dart';
import '../models/food_item.dart';
import '../services/food_recommendation_service.dart';
import '../widgets/food_filter_options.dart';
import 'food_detail_page.dart';

class FoodCategoryTab extends StatefulWidget {
  final List<String> categories;
  final List<String> selectedFilters;

  const FoodCategoryTab({
    super.key,
    required this.categories,
    required this.selectedFilters,
  });

  @override
  State<FoodCategoryTab> createState() => _FoodCategoryTabState();
}

class _FoodCategoryTabState extends State<FoodCategoryTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<FoodItem>> _foodItemsFuture;
  List<FoodItem> _foodItems = []; // Store the food items

  @override
  void initState() {
    super.initState();
    _loadFoodItems(0);
  }

  void _loadFoodItems(int selectedFilters) {
    logger.d("selected categories: ${widget.categories}");
    logger.d("selected filter saikat: ${widget.selectedFilters}");

    _foodItemsFuture = FoodRecommendationService()
        .getRecommendedFoods(widget.categories[0], selectedFilters)
        .then((allFoods) {
          logger.d("Filtering foods for categories: ${widget.categories}");
          _foodItems =
              allFoods; // If 'All' category is requested, return all foods
          return allFoods;
        });
  }

  @override
  void didUpdateWidget(covariant FoodCategoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload food items if the categories change
    if (widget.categories != oldWidget.categories) {
      _loadFoodItems(0);
    }
  }

  List<FoodItem> _applyFilters(List<FoodItem> foodItems) {
    //logger.d("Applying filters: ${widget.selectedFilters}");
    //logger.d("foodItems: $foodItems");
    if (widget.selectedFilters.isEmpty) {
      return foodItems;
    }

    return foodItems.where((foodItem) {
      bool passesFilters = true;
      for (String filter in widget.selectedFilters) {
        switch (filter) {
          case 'Low Potassium':
            if (foodItem.getPotassiumType() != 'Low') passesFilters = false;
            break;
          case 'Medium Potassium':
            if (foodItem.getPotassiumType() != 'Medium') passesFilters = false;
            break;
          case 'High Potassium':
            if (foodItem.getPotassiumType() != 'High') passesFilters = false;
            break;
          case 'Low Phosphorus':
            if (foodItem.getPhosphorusType() != 'Low') passesFilters = false;
            break;
          case 'Medium Phosphorus':
            if (foodItem.getPhosphorusType() != 'Medium') passesFilters = false;
            break;
          case 'High Phosphorus':
            if (foodItem.getPhosphorusType() != 'High') passesFilters = false;
            break;
          case 'Low Sodium':
            if (foodItem.getSodiumType() != 'Low') passesFilters = false;
            break;
          case 'Medium Sodium':
            if (foodItem.getSodiumType() != 'Medium') passesFilters = false;
            break;
          case 'High Sodium':
            if (foodItem.getSodiumType() != 'High') passesFilters = false;
            break;
        }
        if (!passesFilters) break;
      }
      return passesFilters;
    }).toList();
  }

  int getNutritionFilterValue(List<String> filters) {
    switch (filters[0]) {
      case 'Low Potassium':
        return 12;
      case 'Medium Potassium':
        return 13;
      case 'High Potassium':
        return 14;
      case 'Low Phosphorus':
        return 22;
      case 'Medium Phosphorus':
        return 23;
      case 'High Phosphorus':
        return 24;
      case 'Low Sodium':
        return 32;
      case 'Medium Sodium':
        return 33;
      case 'High Sodium':
        return 34;
      default:
        return -1; // Unknown filter
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return FoodFilterOptions(
                selectedFilters: widget.selectedFilters,
                onFiltersChanged: (List<String> filters) {
                  Navigator.pop(context);
                  setState(() {
                    logger.d("Selected Filters: $filters");
                    int filterno = getNutritionFilterValue(filters);
                    logger.d("Selected Filters number: $filterno");
                    _loadFoodItems(filterno);
                  });
                },
              );
            },
          );
        },
        child: const Icon(Icons.filter_list),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _foodItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitWave(color: Colors.blue, size: 40.0),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No food recommendations available for this category.',
              ),
            );
          } else {
            List<FoodItem> filteredFoodItems = _applyFilters(_foodItems);
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio:
                    1, // Adjust aspect ratio for better card sizing
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final foodItem = snapshot.data![index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior:
                      Clip.antiAlias, // Ensures image respects rounded corners
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FoodDetailPage(foodItem: foodItem),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child:
                              foodItem.imageUrl != null &&
                                  foodItem.imageUrl!.isNotEmpty
                              ? Image.network(
                                  foodItem.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Center align content
                            children: [
                              Text(
                                foodItem.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.eco,
                                          color: Colors.green,
                                        ), // Leaf icon for Potassium
                                        const SizedBox(width: 4),
                                        Text(
                                          'Potassium: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            foodItem.getPotassiumType() == 'Low'
                                            ? Colors.blue
                                            : foodItem.getPotassiumType() ==
                                                  'Medium'
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        foodItem.getPotassiumType(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.local_hospital,
                                          color: Colors.orange,
                                        ), // Hospital icon for Phosphorus
                                        const SizedBox(width: 4),
                                        Text(
                                          'Phosphorus: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            foodItem.getPhosphorusType() ==
                                                'Low'
                                            ? Colors.blue
                                            : foodItem.getPhosphorusType() ==
                                                  'Medium'
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        foodItem.getPhosphorusType(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.water_drop,
                                          color: Colors.blue,
                                        ), // Water drop icon for Sodium
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sodium: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: foodItem.getSodiumType() == 'Low'
                                            ? Colors.grey
                                            : foodItem.getSodiumType() ==
                                                  'Medium'
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        foodItem.getSodiumType(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the state of the tab alive
}
