import 'dart:io';

abstract class FilePickerService {
  Future<List<File>> pickFiles({
    bool allowMultiple,
    List<String>? allowedExtensions,
  });
}