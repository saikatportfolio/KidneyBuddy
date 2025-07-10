import 'package:flutter/material.dart';
import 'food_category_tab.dart'; // Import the new FoodCategoryTab

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allows more tabs than fit on screen
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabViews,
      ),
    );
  }
}
