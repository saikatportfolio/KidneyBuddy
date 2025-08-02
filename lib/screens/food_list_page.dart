import 'package:flutter/material.dart';
import 'food_category_tab.dart'; // Import the new FoodCategoryTab

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  int _selectedCategoryIndex = 0; // New state variable for selected category

  final List<Map<String, dynamic>> _categoryCards = [
    {'name': 'All Foods', 'icon': Icons.fastfood, 'categories': ['All']},
    {'name': 'Vegetables', 'icon': Icons.local_florist, 'categories': ['Vegetable']},
    {'name': 'Fruits', 'icon': Icons.apple, 'categories': ['Fruit']},
    {'name': 'Grains', 'icon': Icons.grain, 'categories': ['Grains']},
    {'name': 'Plant Protein', 'icon': Icons.eco, 'categories': ['Plant Protein']},
    {'name': 'Animal Protein', 'icon': Icons.egg, 'categories': ['Animal Protein']},
    {'name': 'Dairy', 'icon': Icons.local_drink, 'categories': ['Dairy']},
    {'name': 'Other', 'icon': Icons.category, 'categories': ['Other']},
  ];

  void _showSafetyFlagMeaningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Safety Flag Meanings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFlagMeaningRow(Colors.green, 'Safe', 'Generally suitable.'),
              _buildFlagMeaningRow(Colors.yellow[700]!, 'Limit', 'Generally can consume in moderation.'),
              _buildFlagMeaningRow(Colors.red, 'Danger', 'Generally can be harmful.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Nutritional Info',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the back button
                ],
              ),
            ),
            // Category Cards at the top
            SizedBox(
              height: 120, // Adjust height as needed for the category cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categoryCards.length,
                itemBuilder: (context, index) {
                  final category = _categoryCards[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index; // Update selected category index
                      });
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _selectedCategoryIndex == index
                              ? Theme.of(context).primaryColor // Highlight selected card
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                      child: Container(
                        width: 100, // Fixed width for each card
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => _showSafetyFlagMeaningDialog(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40), // Make button full width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('See Safety Flag Meanings'),
              ),
            ),
            // Display FoodCategoryTab based on selected category
            Expanded(
              child: FoodCategoryTab(
                categories: _categoryCards[_selectedCategoryIndex]['categories'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
