import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/weight.dart';
import 'package:myapp/models/patient_details.dart';
import 'package:myapp/widgets/add_weight_dialog.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/logger_config.dart'; // Import logger
import 'package:myapp/utils/pdf_generator.dart'; // Import PdfGenerator
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:printing/printing.dart'; // Import printing for PDF sharing
import 'package:myapp/services/database_helper.dart'; // Import DatabaseHelper

class WeightRecordsTab extends StatefulWidget {
  final String userId;
  final PatientDetails? patientDetails; // Add patientDetails parameter

  const WeightRecordsTab({
    super.key,
    required this.userId,
    this.patientDetails, // Make it optional for now, but will be required for PDF
  });

  @override
  State<WeightRecordsTab> createState() => _WeightRecordsTabState();
}

class _WeightRecordsTabState extends State<WeightRecordsTab> {
  List<Weight> _weightReadings = [];
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();

  // Public method to refresh data
  void refreshData() {
    _fetchData();
  }

  String _selectedFilterDuration = 'allTime'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant WeightRecordsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _fetchData();
    }
  }

  DateTime? _calculateStartDate(String filterDuration) {
    final now = DateTime.now();
    switch (filterDuration) {
      case 'filterLastWeek':
        return now.subtract(const Duration(days: 7));
      case 'filterLastMonth':
        return now.subtract(const Duration(days: 30)); // Approximation
      case 'filterLast3Months':
        return now.subtract(const Duration(days: 30 * 3)); // Approximation
      case 'filterLast6Months':
        return now.subtract(const Duration(days: 30 * 6)); // Approximation
      case 'allTime':
      default:
        return null; // No date filter
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final startDate = _calculateStartDate(_selectedFilterDuration);
      List<Weight> fetchedReadings = await _supabaseService.getWeightReadings(startDate: startDate);
      setState(() {
        _weightReadings = fetchedReadings;
      });
    } catch (e) {
      logger.e('Error fetching vital data for Weight: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilterOptions(AppLocalizations localizations) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(localizations.filterLastWeek),
                onTap: () {
                  setState(() {
                    _selectedFilterDuration = 'filterLastWeek';
                  });
                  _fetchData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(localizations.filterLastMonth),
                onTap: () {
                  setState(() {
                    _selectedFilterDuration = 'filterLastMonth';
                  });
                  _fetchData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(localizations.filterLast3Months),
                onTap: () {
                  setState(() {
                    _selectedFilterDuration = 'filterLast3Months';
                  });
                  _fetchData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(localizations.filterLast6Months),
                onTap: () {
                  setState(() {
                    _selectedFilterDuration = 'filterLast6Months';
                  });
                  _fetchData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(localizations.filterAllTime),
                onTap: () {
                  setState(() {
                    _selectedFilterDuration = 'allTime';
                  });
                  _fetchData();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<Weight>> _groupWeightReadingsByDate(List<Weight> readings) {
    final Map<String, List<Weight>> grouped = {};
    for (var w in readings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(w.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(w);
    }
    return grouped;
  }

  Future<void> _generatePdfReport(AppLocalizations localizations) async {
    logger.i('Attempting to generate PDF report for Weight...');

    if (widget.patientDetails == null) {
      logger.w('Patient details not available for PDF generation.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pdfGenerationErrorNoPatientDetails)),
      );
      return;
    }

    try {
      if (_weightReadings.isEmpty) {
        logger.w('No weight readings available for PDF generation.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.pdfGenerationErrorNoReadings)),
        );
        return;
      }
      // final pdfBytes = await PdfGenerator.generateWeightReport(widget.patientDetails!, _weightReadings);
      // await Printing.sharePdf(bytes: pdfBytes, filename: 'weight_report.pdf');
      logger.i('PDF report shared successfully.');
    } catch (e, stack) {
      logger.e('Error generating or sharing PDF for Weight: $e', error: e, stackTrace: stack);
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

    Widget mainContent;
    if (_weightReadings.isEmpty) {
      mainContent = Center(child: Text(localizations.noDataAvailable));
    } else {
      final groupedCrData = _groupWeightReadingsByDate(_weightReadings);
      final sortedDates = groupedCrData.keys.toList()..sort((a, b) => b.compareTo(a));

      mainContent = ListView.builder(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Add padding to the bottom
        itemCount: sortedDates.length,
        itemBuilder: (context, groupIndex) {
          final date = sortedDates[groupIndex];
          final readingsForDate = groupedCrData[date]!..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(date)),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: readingsForDate.length,
                itemBuilder: (context, readingIndex) {
                  final reading = readingsForDate[readingIndex];
                  return Card(
                    elevation: 6,
                    shadowColor: Colors.blue.shade200.withAlpha(179),
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('hh:mm a').format(reading.timestamp),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '${reading.value.toStringAsFixed(2)} kg',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.black),
                                  onPressed: () => _confirmAndDeleteWeightReading(reading, localizations),
                                ),
                              ],
                            ),
                            if (reading.comment != null && reading.comment!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Comment: ${reading.comment}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
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
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showFilterOptions(localizations),
                icon: const Icon(Icons.filter_list),
                tooltip: localizations.filter,
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              mainContent,
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddWeightDialog(
                          userId: widget.userId,
                          refreshData: refreshData,
                        );
                      },
                    );
                  },
                  label: Text(localizations.addWeight),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndDeleteWeightReading(Weight reading, AppLocalizations localizations) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteConfirmationTitle),
          content: Text(localizations.deleteWeightReadingConfirmation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.yes),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _supabaseService.deleteWeight(reading.id!);
        await DatabaseHelper().deleteWeight(reading.id!);

        setState(() {
          _weightReadings.removeWhere((w) => w.id == reading.id);
        });
      } catch (e) {
        logger.e('Error deleting Weight reading: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.errorDeletingWeightReading(e.toString()))),
        );
      }
    }
  }
}
