import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:myapp/models/creatine.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddCreatineDialog extends StatefulWidget {
  final String userId;
  final Function refreshData;

  const AddCreatineDialog({super.key, required this.userId, required this.refreshData});

  @override
  State<AddCreatineDialog> createState() => _AddCreatineDialogState();
}

class _AddCreatineDialogState extends State<AddCreatineDialog> {
  final TextEditingController _dateController = TextEditingController();

  double _currentCreatineValue = 1.2;

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDateAndTimeControllers();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _updateDateAndTimeControllers() {
    if (_selectedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateAndTimeControllers();
      });
    }
  }

  void _saveCreatine() async {
    logger.d('_saveCreatine call');

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocalizationHelper.translateKey(
                context, 'selectDateAndTimeError'))),
      );
      return;
    }

    final now = DateTime.now();
    final combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      now.hour,
      now.minute,
    );

    final String newId = Uuid().v4();
    final creatine = Creatine(
      id: newId,
      value: _currentCreatineValue,
      timestamp: combinedDateTime,
      comment: null,
    );
    logger.d('Creatine data: $creatine');

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      logger.d(
          'AddCreatineDialog: Current user before saving: ${currentUser?.id != null ? 'Logged In (ID: ${currentUser!.id})' : 'Logged Out'}');

      if (!kIsWeb) {
        await DatabaseHelper().insertCreatine(creatine);
        logger.i('AddCreatineDialog: Creatine saved to SQLite: ${creatine.value}');
      }

      await SupabaseService().insertCreatine(creatine);
      logger.i('AddCreatineDialog: Creatine saved to Supabase: ${creatine.value}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                LocalizationHelper.translateKey(context, 'Creatine saved Successfully'))),
      );

      widget.refreshData();
      Navigator.of(context).pop();
    } catch (e) {
      logger.e('Error saving Creatine: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocalizationHelper.translateKey(
                    context, 'creatineSaveError')
                .replaceFirst('{error}', e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocalizationHelper.translateKey(context, 'Add Creatine')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDecimalNumberPicker(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText:
                    LocalizationHelper.translateKey(context, 'select Date'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocalizationHelper.translateKey(context, 'close')),
        ),
        ElevatedButton(
          onPressed: _saveCreatine,
          child: Text(LocalizationHelper.translateKey(context, 'save')),
        ),
      ],
    );
  }

  Widget _buildDecimalNumberPicker() {
    return Center(
      child: Column(
        children: [
          Text(
            LocalizationHelper.translateKey(context, 'creatine'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          DecimalNumberPicker(
            value: _currentCreatineValue,
            minValue: 0,
            maxValue: 10,
            decimalPlaces: 2,
            onChanged: (value) => setState(() => _currentCreatineValue = value),
            textStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
            selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
