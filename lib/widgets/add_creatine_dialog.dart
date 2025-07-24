import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/creatine.dart';
import 'package:myapp/services/database_helper.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/logger_config.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddCreatineDialog extends StatefulWidget {
  final Function onCreatineAdded;

  const AddCreatineDialog({super.key, required this.onCreatineAdded});

  @override
  State<AddCreatineDialog> createState() => _AddCreatineDialogState();
}

class _AddCreatineDialogState extends State<AddCreatineDialog> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  double _currentCreatineValue = 1.2;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDateAndTimeControllers();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _updateDateAndTimeControllers() {
    if (_selectedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
    if (_selectedTime != null) {
      final localizations = AppLocalizations.of(context);
      if (localizations != null) {
        _timeController.text = _selectedTime!.format(context);
      }
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _updateDateAndTimeControllers();
      });
    }
  }

  void _saveCreatine() async {
    logger.d('_saveCreatine call');

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocalizationHelper.translateKey(
                context, 'selectDateAndTimeError'))),
      );
      return;
    }

    final combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final String newId = Uuid().v4();
    final creatine = Creatine(
      id: newId,
      value: _currentCreatineValue,
      timestamp: combinedDateTime,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
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
                LocalizationHelper.translateKey(context, 'creatineSavedSuccess'))),
      );

      widget.onCreatineAdded();
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
      title: Text(LocalizationHelper.translateKey(context, 'addCreatineReading')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDecimalNumberPicker(),
            const SizedBox(height: 16),
            Text(
              LocalizationHelper.translateKey(context, 'addYourComment'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: LocalizationHelper.translateKey(
                    context, 'addYourComment'),
                hintText: 'Add any relevant comments...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.comment),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: LocalizationHelper.translateKey(
                          context, 'selectDate'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: LocalizationHelper.translateKey(
                          context, 'selectTime'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
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
