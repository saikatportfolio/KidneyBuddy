import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/blood_pressure.dart'; // Import BloodPressure model
import 'package:myapp/models/patient_details.dart'; // Import PatientDetails
import 'package:myapp/services/supabase_service.dart'; // Import SupabaseService
import 'package:myapp/utils/logger_config.dart'; // Import logger
import 'package:myapp/utils/pdf_generator.dart'; // Import PdfGenerator
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:printing/printing.dart'; // Import printing for PDF sharing
import 'package:myapp/services/database_helper.dart'; // Import DatabaseHelper

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

  String _selectedFilterDuration = 'allTime'; // Default filter

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
      if (widget.vitalType == 'BP') {
        final startDate = _calculateStartDate(_selectedFilterDuration);
        List<BloodPressure> fetchedReadings = await _supabaseService.getBloodPressureReadings(startDate: startDate);
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

  void _showTrendChart(AppLocalizations localizations) {
    if (_bloodPressureReadings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.noDataAvailable)),
      );
      return;
    }

    // Sort readings by timestamp ascending for the chart
    final sortedReadings = List<BloodPressure>.from(_bloodPressureReadings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    for (int i = 0; i < sortedReadings.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), sortedReadings[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), sortedReadings[i].diastolic.toDouble()));
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.bpTrend),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48, // Increased reserved size
                          interval: 50, // Set interval to 50 for better spacing
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 9, // Reduced font size
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < sortedReadings.length) {
                              if (index % 3 == 0) {
                                return Text(
                                  DateFormat('dd MMM').format(sortedReadings[index].timestamp),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                );
                              }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    minY: 0,
                    maxY: 450, // Increased maxY to accommodate higher systolic readings
                    lineBarsData: [
                      LineChartBarData(
                        spots: systolicSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: diastolicSpots,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final reading = sortedReadings[spot.spotIndex];
                            return LineTooltipItem(
                              '${spot.y.toInt()} mmHg\n${DateFormat('MMM dd, hh:mm a').format(reading.timestamp)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(Colors.blue, localizations.systolic),
                    const SizedBox(width: 20),
                    _buildLegendItem(Colors.red, localizations.diastolic),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
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
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showTrendChart(localizations),
                icon: const Icon(Icons.trending_up),
                label: Text(localizations.trend),
              ),
              const SizedBox(width: 8), // Spacing between buttons
              IconButton(
                onPressed: () => _showFilterOptions(localizations),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0), // Adjusted padding
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
                                // onTap: () {
                                //   // TODO: Implement navigation to detail page for this vital reading
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(content: Text('Tapped on BP reading: ${reading.systolic}/${reading.diastolic} at ${DateFormat('hh:mm a').format(reading.timestamp)}')),
                                //   );
                                // },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('hh:mm a').format(reading.timestamp), // Format time for display
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade800,
                                                ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${reading.systolic}/${reading.diastolic} mmHg',
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue.shade700,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.black),
                                            onPressed: () => _confirmAndDeleteBpReading(reading, localizations),
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

  Future<void> _confirmAndDeleteBpReading(BloodPressure reading, AppLocalizations localizations) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.deleteConfirmationTitle), // Assuming you have this key
          content: Text(localizations.deleteBpReadingConfirmation), // Assuming you have this key
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User clicked "No"
              child: Text(localizations.no), // Assuming you have this key
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User clicked "Yes"
              child: Text(localizations.yes), // Assuming you have this key
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        // Delete from Supabase
        await _supabaseService.deleteBloodPressureReading(reading.id!);
        // Delete from local SQLite
        await DatabaseHelper().deleteBloodPressure(reading.id!);

        setState(() {
          _bloodPressureReadings.removeWhere((bp) => bp.id == reading.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.bpReadingDeletedSuccessfully)), // Assuming you have this key
        );
      } catch (e) {
        logger.e('Error deleting BP reading: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.errorDeletingBpReading(e.toString()))), // Assuming you have this key
        );
      }
    }
  }
}
