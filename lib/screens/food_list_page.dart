import 'package:flutter/material.dart';
import 'food_category_tab.dart'; // Import the new FoodCategoryTab

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _categoryCards = [
    {'name': 'All Foods', 'icon': Icons.fastfood},
    {'name': 'Vegetables', 'icon': Icons.local_florist},
    {'name': 'Fruits', 'icon': Icons.apple},
    {'name': 'Grains', 'icon': Icons.grain},
    {'name': 'Plant Protein', 'icon': Icons.eco},
    {'name': 'Animal Protein', 'icon': Icons.egg},
    {'name': 'Dairy', 'icon': Icons.local_drink},
    {'name': 'Other', 'icon': Icons.category},
  ];

  final List<Tab> _tabs = const [
    Tab(text: 'All Foods'),
    Tab(text: 'Vegetables'),
    Tab(text: 'Fruits'),
    Tab(text: 'Grains'),
    Tab(text: 'Plant Protein'),
    Tab(text: 'Animal Protein'),
    Tab(text: 'Dairy'),
    Tab(text: 'Other'),
  ];

  final List<Widget> _tabViews = const [
    FoodCategoryTab(categories: ['All']),
    FoodCategoryTab(categories: ['Vegetable']),
    FoodCategoryTab(categories: ['Fruit']),
    FoodCategoryTab(categories: ['Grains']),
    FoodCategoryTab(categories: ['Plant Protein']),
    FoodCategoryTab(categories: ['Animal Protein']),
    FoodCategoryTab(categories: ['Dairy']),
    FoodCategoryTab(categories: ['Other']), // Catch-all for categories not explicitly listed
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recommendations'),
      ),
      body: Column(
        children: [
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
                    _tabController.animateTo(index); // Switch to the corresponding tab
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          // TabBar and TabBarView for food lists
          TabBar(
            controller: _tabController,
            isScrollable: true, // Allows more tabs than fit on screen
            tabs: _tabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabViews,
            ),
          ),
        ],
      ),
    );
  }
}
