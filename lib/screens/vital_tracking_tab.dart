import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:myapp/models/patient_details.dart'; // Import PatientDetails
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService
import 'package:myapp/utils/logger_config.dart'; // Import logger
import 'package:myapp/utils/pdf_generator.dart'; // Import PdfGenerator
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:printing/printing.dart'; // Import printing for PDF sharing

class VitalTrackingTab extends StatefulWidget {
  final String vitalType;
  final String userId;
  final PatientDetails? patientDetails; // Add patientDetails parameter

  const VitalTrackingTab({
    super.key,
    required this.vitalType,
    required this.userId,
    this.patientDetails, // Make it optional for now, but will be required for PDF
  });

  @override
  State<VitalTrackingTab> createState() => _VitalTrackingTabState();
}

class _VitalTrackingTabState extends State<VitalTrackingTab> {
  List<BloodPressure> _bloodPressureReadings = [];
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService(); // Create an instance

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant VitalTrackingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vitalType != oldWidget.vitalType || widget.userId != oldWidget.userId) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.vitalType == 'BP') {
        List<BloodPressure> fetchedReadings = await _supabaseService.getBloodPressureReadings();
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

  Future<void> _generatePdfReport(AppLocalizations localizations) async {
    logger.i('Attempting to generate PDF report for ${widget.vitalType}...');

    if (widget.patientDetails == null) {
      logger.w('Patient details not available for PDF generation.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pdfGenerationErrorNoPatientDetails)),
      );
      return;
    }

    try {
      if (widget.vitalType == 'BP') {
        if (_bloodPressureReadings.isEmpty) {
          logger.w('No blood pressure readings available for PDF generation.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.pdfGenerationErrorNoReadings)),
          );
          return;
        }
        final pdfBytes = await PdfGenerator.generateBpReport(widget.patientDetails!, _bloodPressureReadings);
        await Printing.sharePdf(bytes: pdfBytes, filename: 'blood_pressure_report.pdf');
        logger.i('PDF report shared successfully.');
      } else {
        logger.i('PDF generation not yet implemented for ${widget.vitalType}.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.notYetImplemented('PDF Export for ${widget.vitalType}'))),
        );
      }
    } catch (e, stack) {
      logger.e('Error generating or sharing PDF for ${widget.vitalType}: $e', error: e, stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pdfGenerationError(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _generatePdfReport(localizations),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(localizations.exportPdfButton),
              ),
              const SizedBox(width: 8), // Spacing between buttons
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.notYetImplemented(localizations.filter))),
                  );
                },
                icon: const Icon(Icons.filter_list),
                tooltip: localizations.filter,
              ),
            ],
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
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
                return Center(child: Text(localizations.noDataAvailable));
              }
            },
          ),
        ),
      ],
    );
  }
}
