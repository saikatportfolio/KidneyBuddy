import 'package:flutter/material.dart';

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
    _selectedFilters = List.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView(
        children: <Widget>[
    
        ListTile(
          title: const Text('Filter Options'),
        ),
        CheckboxListTile(
          title: const Text('Low Potassium'),
          value: _selectedFilters.contains('Low Potassium'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('Low Potassium');
              } else {
                _selectedFilters.remove('Low Potassium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('Medium Potassium'),
          value: _selectedFilters.contains('Medium Potassium'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('Medium Potassium');
              } else {
                _selectedFilters.remove('Medium Potassium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('High Potassium'),
          value: _selectedFilters.contains('High Potassium'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('High Potassium');
              } else {
                _selectedFilters.remove('High Potassium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('Low Phosphorus'),
          value: _selectedFilters.contains('Low Phosphorus'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('Low Phosphorus');
              } else {
                _selectedFilters.remove('Low Phosphorus');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('Medium Phosphorus'),
          value: _selectedFilters.contains('Medium Phosphorus'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('Medium Phosphorus');
              } else {
                _selectedFilters.remove('Medium Phosphorus');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('High Phosphorus'),
          value: _selectedFilters.contains('High Phosphorus'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('High Phosphorus');
              } else {
                _selectedFilters.remove('High Phosphorus');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('Low Sodium'),
          value: _selectedFilters.contains('Low Sodium'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('Low Sodium');
              } else {
                _selectedFilters.remove('Low Sodium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('Medium Sodium'),
          value: _selectedFilters.contains('Medium Sodium'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('Medium Sodium');
              } else {
                _selectedFilters.remove('Medium Sodium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
        CheckboxListTile(
          title: const Text('High Sodium'),
          value: _selectedFilters.contains('High Sodium'),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedFilters.add('High Sodium');
              } else {
                _selectedFilters.remove('High Sodium');
              }
            });
            widget.onFiltersChanged(_selectedFilters);
          },
        ),
      ],
      ),
    );
  }
}
