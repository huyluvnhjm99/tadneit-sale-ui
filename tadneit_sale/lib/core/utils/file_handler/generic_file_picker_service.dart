import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'file_picker_service.dart';

class GenericFilePickerService implements FilePickerService {
  @override
  Future<List<File>> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );

    if (pickerResult != null && pickerResult.files.isNotEmpty) {
      return pickerResult.files
          .where((pf) => pf.path != null)
          .map((pf) => File(pf.path!))
          .toList();
    }

    return [];
  }
}