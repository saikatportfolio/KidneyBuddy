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

  @override
  void initState() {
    super.initState();
    _loadSelectedFilters();
  }

  Future<void> _loadSelectedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFilters = (prefs.getStringList('selectedFilters') ?? []).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView(
        children: <Widget>[
    
        ListTile(
          title: const Text(
            'Filter Options',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('Low Potassium'),
          tileColor: _selectedFilters.contains('Low Potassium') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('Medium Potassium') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('High Potassium') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('Low Phosphorus') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('Medium Phosphorus') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('High Phosphorus') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('Low Sodium') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('Medium Sodium') ? Colors.blue[50] : null,
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
          tileColor: _selectedFilters.contains('High Sodium') ? Colors.blue[50] : null,
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
