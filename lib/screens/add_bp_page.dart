import 'package:flutter/material.dart';
import 'package:myapp/utils/localization_helper.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService
import 'package:myapp/services/database_helper.dart'; // Import DatabaseHelper
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:myapp/utils/logger_config.dart'; // Import logger
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
// Import VitalTrackingPage
import 'package:uuid/uuid.dart'; // Import uuid package
import 'package:numberpicker/numberpicker.dart'; // Import numberpicker

class AddBpPage extends StatefulWidget {
  const AddBpPage({super.key});

  @override
  State<AddBpPage> createState() => _AddBpPageState();
}

class _AddBpPageState extends State<AddBpPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  int _currentSystolicValue = 120;
  int _currentDiastolicValue = 80;

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
      _timeController.text = _selectedTime!.format(context);
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

  void _saveBloodPressure() async {
    logger.d('_saveBloodPressure call ');

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationHelper.translateKey(context, 'selectDateAndTimeError'))),
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

    final String newId = Uuid().v4(); // Generate a new UUID
    final bloodPressure = BloodPressure(
      id: newId, // Assign the generated ID
      systolic: _currentSystolicValue,
      diastolic: _currentDiastolicValue,
      timestamp: combinedDateTime,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
    );
    logger.d('Blood pressure data: $bloodPressure');

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      logger.d('AddBpPage: Current user before saving BP: ${currentUser?.id != null ? 'Logged In (ID: ${currentUser!.id})' : 'Logged Out'}');

        // Save to SQLite for mobile
        if (!kIsWeb) {
          await DatabaseHelper().insertBloodPressure(bloodPressure);
          logger.i('AddBpPage: BP saved to SQLite: ${bloodPressure.systolic}/${bloodPressure.diastolic}');
        }
        
        // Always sync to Supabase
        await SupabaseService().insertBloodPressure(bloodPressure);
        logger.i('AddBpPage: BP saved to Supabase: ${bloodPressure.systolic}/${bloodPressure.diastolic}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.translateKey(context, 'BP Saved Successfully'))),
        );

        // Clear fields after successful save
        _commentController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
          _updateDateAndTimeControllers();
          _currentSystolicValue = 120; // Reset to default
          _currentDiastolicValue = 80; // Reset to default
        });

        // Pop back to the previous screen (VitalTrackingPage) with a result indicating success
        if (mounted) {
          Navigator.of(context).pop(true); // Pass true to indicate success
        }
      } catch (e) {
        logger.e('Error saving BP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.translateKey(context, 'bpSaveError').replaceFirst('{error}', e.toString()))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Add BP reading',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48), // To balance the IconButton
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNumberPickerColumn(
                            label: LocalizationHelper.translateKey(context, 'SYS'),
                            value: _currentSystolicValue,
                            minValue: 70,
                            maxValue: 180,
                            onChanged: (value) =>
                                setState(() => _currentSystolicValue = value),
                          ),
                          _buildNumberPickerColumn(
                            label: LocalizationHelper.translateKey(context, 'DIA'),
                            value: _currentDiastolicValue,
                            minValue: 40,
                            maxValue: 120,
                            onChanged: (value) =>
                                setState(() => _currentDiastolicValue = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocalizationHelper.translateKey(context, 'Add Your Comment'),
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
                              context, 'Add Your Comment'),
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
                                    context, 'Select date'),
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
                                    context, 'Select Time'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.access_time),
                              ),
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveBloodPressure,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            LocalizationHelper.translateKey(context, 'Save'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPickerColumn({
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        NumberPicker(
          value: value,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
          textStyle: TextStyle(color: Colors.grey[400], fontSize: 20),
          selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }
}
