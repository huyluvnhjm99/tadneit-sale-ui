import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/file_handler/file_picker_service.dart';

class FilePickerDialog extends ConsumerStatefulWidget {
  final FilePickerService pickerService;
  final bool allowMultiple;
  final List<String>? allowedExtensions;

  const FilePickerDialog({
    super.key,
    required this.pickerService,
    this.allowMultiple = false,
    this.allowedExtensions,
  });

  @override
  ConsumerState<FilePickerDialog> createState() => _FilePickerDialogState();

  static Future<List<File>?> show(
      BuildContext context, {
        required FilePickerService pickerService,
        bool allowMultiple = false,
        List<String>? allowedExtensions,
      }) {
    return showDialog<List<File>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        child: FilePickerDialog(
          pickerService: pickerService,
          allowMultiple: allowMultiple,
          allowedExtensions: allowedExtensions,
        ),
      ),
    );
  }
}

class _FilePickerDialogState extends ConsumerState<FilePickerDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  List<File> pickedFiles = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickFiles();
    });
  }

  Future<void> _pickFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final files = await widget.pickerService.pickFiles(
        allowMultiple: widget.allowMultiple,
        allowedExtensions: widget.allowedExtensions,
      );

      if (files.isEmpty) {
        if (mounted) Navigator.pop(context); // canceled
        return;
      }

      pickedFiles = files;
      if (mounted) Navigator.pop(context, pickedFiles);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking files: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isLoading
                ? 'Picking files...'
                : _errorMessage ?? 'Files selected successfully.',
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

