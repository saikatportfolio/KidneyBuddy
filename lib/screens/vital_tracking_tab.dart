import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
// Import AddBpPage
// Import LocalizationHelper
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService
// Import DatabaseHelper
// Import kIsWeb
import 'package:myapp/utils/logger_config.dart'; // Import logger
import 'package:intl/intl.dart'; // Import for DateFormat

class VitalTrackingTab extends StatefulWidget {
  final String vitalType;
  final String userId; // Add userId parameter

  const VitalTrackingTab({super.key, required this.vitalType, required this.userId});

  @override
  State<VitalTrackingTab> createState() => _VitalTrackingTabState();
}

class _VitalTrackingTabState extends State<VitalTrackingTab> {
  List<BloodPressure> _bloodPressureReadings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant VitalTrackingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vitalType != oldWidget.vitalType) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.vitalType == 'BP') {
        List<BloodPressure> fetchedReadings = await SupabaseService().getBloodPressureReadings(); // Always fetch from Supabase
        setState(() {
          _bloodPressureReadings = fetchedReadings;
        });
      }
      // Add fetching logic for other vital types here
    } catch (e) {
      logger.e('Error fetching vital data for ${widget.vitalType}: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to group BP readings by date
  Map<String, List<BloodPressure>> _groupBpReadingsByDate(List<BloodPressure> readings) {
    final Map<String, List<BloodPressure>> grouped = {};
    for (var bp in readings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(bp.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(bp);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.vitalType == 'BP') {
      if (_bloodPressureReadings.isEmpty) {
        return Center(child: Text(localizations.noDataAvailable));
      }

      final groupedBpData = _groupBpReadingsByDate(_bloodPressureReadings);
      final sortedDates = groupedBpData.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort dates descending

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedDates.length,
        itemBuilder: (context, groupIndex) {
          final date = sortedDates[groupIndex];
          final readingsForDate = groupedBpData[date]!..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort readings by time descending

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(date)), // Format date for display
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable inner list scrolling
                itemCount: readingsForDate.length,
                itemBuilder: (context, readingIndex) {
                  final reading = readingsForDate[readingIndex];
                  return Card(
                    elevation: 6,
                    shadowColor: Colors.blue.shade200.withOpacity(0.7),
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement navigation to detail page for this vital reading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped on BP reading: ${reading.systolic}/${reading.diastolic} at ${DateFormat('hh:mm a').format(reading.timestamp)}')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a').format(reading.timestamp), // Format time for display
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Blood Pressure Reading',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${reading.systolic}/${reading.diastolic} mmHg',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                ),
                              ],
                            ),
                            if (reading.comment != null && reading.comment!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Comment: ${reading.comment}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade700,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      // Placeholder for other vital types
      return Center(child: Text(localizations.notYetImplemented(widget.vitalType)));
    }
  }
}
