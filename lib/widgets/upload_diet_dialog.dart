import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myapp/services/analytics_service.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:myapp/utils/analytics_event_names.dart';
import 'package:myapp/utils/logger_config.dart';

class UploadDietDialog extends StatefulWidget {
  const UploadDietDialog({super.key});

  @override
  State<UploadDietDialog> createState() => _UploadDietDialogState();
}

class _UploadDietDialogState extends State<UploadDietDialog> {
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _fileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
      logger.d('Event triggered: file_picked');
      AnalyticsService().logEvent('file_picked', {});
    }
  }

  Future<void> _uploadFile() async {
    AnalyticsService().pushToGTM(AnalyticsEventNames.buttonClick, {
      AnalyticsEventNames.buttonClickType: 'upload_diet_click',
    });
    if (_fileBytes == null || _fileName == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      final fileUrl = await supabaseService.uploadFile(_fileBytes!, _fileName!);
      await supabaseService.insertUserFile(fileUrl, _fileName!);
      logger.d('Event triggered: upload_successful');
      AnalyticsService().logEvent('upload_successful', {});
      if (!mounted) return;
      Navigator.of(context).pop(); // Close the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Upload Successful!'),
            content: const Text(
              "Thank you for sharing your diet plan. We're reviewing it now and will notify you as soon as your updated plan is ready in the app.",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _fileBytes = null;
        _fileName = null;
      });
    } catch (e) {
      logger.d('Event triggered: upload_failed, error: ${e.toString()}');
      AnalyticsService().logEvent('upload_failed', {'error': e.toString()});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Diet Chart'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_fileName != null) ...[
              Text('Selected file: $_fileName'),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () {
                logger.d('Event triggered: Pick_a_file');
                AnalyticsService().logEvent('Pick_a_file', {});
                _pickFile();
              },
              child: const Text('Pick a file'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const SpinKitWave(
                color: Colors.blue,
                size: 40.0,
              )
            else
              ElevatedButton(
                onPressed: _fileBytes != null ? _uploadFile : null,
                child: const Text('Upload file'),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
