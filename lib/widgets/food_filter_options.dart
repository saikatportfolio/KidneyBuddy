import 'package:flutter/material.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodFilterOptions extends StatefulWidget {
  final List<String> selectedFilters;
  final Function(List<String>) onFiltersChanged;

  const FoodFilterOptions({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FoodFilterOptions> createState() => _FoodFilterOptionsState();
}

class _FoodFilterOptionsState extends State<FoodFilterOptions> {
  late List<String> _selectedFilters;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSelectedFilters();
  }

  Future<void> _loadSelectedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFilters = (prefs.getStringList('selectedFilters') ?? []).toList();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _isScrolledToBottom = true;
      });
    } else {
      setState(() {
        _isScrolledToBottom = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              setState(() {
                _isScrolledToBottom = notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent;
              });
              return true;
            },
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                ListTile(
          title: const Text(
            'Renal Nutrition Filters',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('Low Potassium'),
          tileColor: _selectedFilters.contains('Low Potassium') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('Low Potassium')) {
                _selectedFilters.remove('Low Potassium');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('Low Potassium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('Medium Potassium'),
          tileColor: _selectedFilters.contains('Medium Potassium') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('Medium Potassium')) {
                _selectedFilters.remove('Medium Potassium');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('Medium Potassium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('High Potassium'),
          tileColor: _selectedFilters.contains('High Potassium') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('High Potassium')) {
                _selectedFilters.remove('High Potassium');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('High Potassium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('Low Phosphorus'),
          tileColor: _selectedFilters.contains('Low Phosphorus') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('Low Phosphorus')) {
                _selectedFilters.remove('Low Phosphorus');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('Low Phosphorus');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('Medium Phosphorus'),
          tileColor: _selectedFilters.contains('Medium Phosphorus') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('Medium Phosphorus')) {
                _selectedFilters.remove('Medium Phosphorus');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('Medium Phosphorus');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('High Phosphorus'),
          tileColor: _selectedFilters.contains('High Phosphorus') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('High Phosphorus')) {
                _selectedFilters.remove('High Phosphorus');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('High Phosphorus');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('Low Sodium'),
          tileColor: _selectedFilters.contains('Low Sodium') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('Low Sodium')) {
                _selectedFilters.remove('Low Sodium');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('Low Sodium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('Medium Sodium'),
          tileColor: _selectedFilters.contains('Medium Sodium') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('Medium Sodium')) {
                _selectedFilters.remove('Medium Sodium');
              } else {
                                _selectedFilters.clear();
                _selectedFilters.add('Medium Sodium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('High Sodium'),
          tileColor: _selectedFilters.contains('High Sodium') ? const Color.fromARGB(255, 162, 200, 231) : null,
          onTap: () {
            setState(() {
              if (_selectedFilters.contains('High Sodium')) {
                _selectedFilters.remove('High Sodium');
              } else {
                _selectedFilters.clear();
                _selectedFilters.add('High Sodium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
            _saveSelectedFilters();
          },
        ),
        ListTile(
          title: const Text('Clear Filter',
          style: TextStyle(color: Color.fromARGB(255, 165, 90, 85), fontWeight: FontWeight.bold),
          ),
          
          onTap: () async {
            logger.i("Clearing all filters");
            setState(() {
              _selectedFilters.clear();
               _selectedFilters.add('Clear Filter');
            });
            widget.onFiltersChanged(_selectedFilters);
            removeSelectedFilters();
          },
        ),
              ],
            ),
          ),
          if (!_isScrolledToBottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Center(
                  child: Text(
                    'Scroll down for more fliter options',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveSelectedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedFilters', _selectedFilters);
  }

    Future<void> removeSelectedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedFilters');
  }
}
