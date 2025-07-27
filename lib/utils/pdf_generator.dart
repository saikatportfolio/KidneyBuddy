import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // For date formatting
import 'package:myapp/models/creatine.dart';

import 'package:myapp/models/patient_details.dart';
import 'package:myapp/models/blood_pressure.dart';
import 'package:myapp/utils/logger_config.dart'; // Import logger

class PdfGenerator {
  static Future<Uint8List> generateBpReport(
      PatientDetails? patientDetails, List<BloodPressure> bpReadings) async {
    final pdf = pw.Document();

    // Sort readings by timestamp in descending order (newest first)
    bpReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 36,
          marginBottom: 36,
          marginLeft: 36,
          marginRight: 36,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Blood Pressure Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),

            // Patient Details Section
            if (patientDetails != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Patient Information:',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Name: ${patientDetails.name}',
                      style: pw.TextStyle(fontSize: 14)),
                  if (patientDetails.email != null)
                    pw.Text('Email: ${patientDetails.email}',
                        style: pw.TextStyle(fontSize: 14)),
                  pw.Text('Phone Number: ${patientDetails.phoneNumber}',
                      style: pw.TextStyle(fontSize: 14)),
                  pw.Text('CKD Stage: ${patientDetails.ckdStage}',
                      style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                ],
              ),

            // Blood Pressure Readings Section
            pw.Text('Blood Pressure Readings:',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            if (bpReadings.isEmpty)
              pw.Text('No blood pressure readings available.',
                  style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic))
            else
              _buildBpReadingsTable(bpReadings),
          ];
        },
      ),
    );

    logger.i('PDF report generated successfully.');
    return pdf.save();
  }

  static pw.Widget _buildBpReadingsTable(List<BloodPressure> readings) {
    // Group readings by date
    final Map<String, List<BloodPressure>> grouped = {};
    for (var bp in readings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(bp.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(bp);
    }

    final List<pw.Widget> dateSections = [];
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort dates descending

    for (var date in sortedDates) {
      final readingsForDate = grouped[date]!..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort readings by time descending
      final formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.parse(date)); // Pre-format date

      final verticalPadding = 8.0; // Make it a non-const variable
      dateSections.add(
        pw.Column( // Revert key parameter, as it's not supported by pw.Column
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: verticalPadding),
              child: pw.Text(
                formattedDate, // Use pre-formatted string
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      final cellPad = 8.0;
      final colWidth2 = 2.0;
      final colWidth1_5 = 1.5;
      final colWidth3 = 3.0;
      final tableHeaders = ['Time', 'Systolic', 'Diastolic', 'Comment']; // Make headers non-constant

      dateSections.add(
        pw.Table.fromTextArray(
          headers: tableHeaders, // Use non-constant headers
          data: readingsForDate.map((bp) => [
            DateFormat('hh:mm a').format(bp.timestamp),
            bp.systolic.toString(),
            bp.diastolic.toString(),
            bp.comment ?? '', // Display empty string if comment is null
          ]).toList(),
          border: pw.TableBorder.all(color: PdfColors.grey500),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: pw.EdgeInsets.all(cellPad),
          columnWidths: {
            0: pw.FlexColumnWidth(colWidth2),
            1: pw.FlexColumnWidth(colWidth1_5),
            2: pw.FlexColumnWidth(colWidth1_5),
            3: pw.FlexColumnWidth(colWidth3),
          },
        ),
      );
      dateSections.add(pw.SizedBox(height: 20)); // Space between date sections
    }

    return pw.Column(children: dateSections);
  }

  static Future<Uint8List> generateCreatineReport(
      PatientDetails? patientDetails, List<Creatine> creatineReadings) async {
    final pdf = pw.Document();

    // Sort readings by timestamp in descending order (newest first)
    creatineReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 36,
          marginBottom: 36,
          marginLeft: 36,
          marginRight: 36,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Creatinine Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),

            // Patient Details Section
            if (patientDetails != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Patient Information:',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Name: ${patientDetails.name}',
                      style: pw.TextStyle(fontSize: 14)),
                  if (patientDetails.email != null)
                    pw.Text('Email: ${patientDetails.email}',
                        style: pw.TextStyle(fontSize: 14)),
                  pw.Text('Phone Number: ${patientDetails.phoneNumber}',
                      style: pw.TextStyle(fontSize: 14)),
                  pw.Text('CKD Stage: ${patientDetails.ckdStage}',
                      style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                ],
              ),

            // Creatinine Readings Section
            pw.Text('Creatinine Readings:',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            if (creatineReadings.isEmpty)
              pw.Text('No creatinine readings available.',
                  style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic))
            else
              _buildCreatinineReadingsTable(creatineReadings),
          ];
        },
      ),
    );

    logger.i('PDF report generated successfully.');
    return pdf.save();
  }

  static pw.Widget _buildCreatinineReadingsTable(List<Creatine> readings) {
    // Group readings by date
    final Map<String, List<Creatine>> grouped = {};
    for (var cr in readings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(cr.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(cr);
    }

    final List<pw.Widget> dateSections = [];
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a)); // Sort dates descending

    for (var date in sortedDates) {
      final readingsForDate = grouped[date]!..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort readings by time descending
      final formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.parse(date)); // Pre-format date

      final verticalPadding = 8.0; // Make it a non-const variable
      dateSections.add(
        pw.Column( // Revert key parameter, as it's not supported by pw.Column
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: verticalPadding),
              child: pw.Text(
                formattedDate, // Use pre-formatted string
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      final cellPad = 8.0;
      final colWidth2 = 2.0;
      final colWidth1_5 = 1.5;
      final colWidth3 = 3.0;
      final tableHeaders = ['Time', 'Value (mg/dL)', 'Comment']; // Make headers non-constant

      dateSections.add(
        pw.Table.fromTextArray(
          headers: tableHeaders, // Use non-constant headers
          data: readingsForDate.map((cr) => [
            DateFormat('hh:mm a').format(cr.timestamp),
            cr.value.toStringAsFixed(2),
            cr.comment ?? '', // Display empty string if comment is null
          ]).toList(),
          border: pw.TableBorder.all(color: PdfColors.grey500),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: pw.EdgeInsets.all(cellPad),
          columnWidths: {
            0: pw.FlexColumnWidth(colWidth2),
            1: pw.FlexColumnWidth(colWidth1_5),
            2: pw.FlexColumnWidth(colWidth3),
          },
        ),
      );
      dateSections.add(pw.SizedBox(height: 20)); // Space between date sections
    }

    return pw.Column(children: dateSections);
  }
}
