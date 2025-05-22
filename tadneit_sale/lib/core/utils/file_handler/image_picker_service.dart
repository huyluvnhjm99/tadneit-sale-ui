import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'file_picker_service.dart';

class ImagePickerService implements FilePickerService {
  final ImageSource imageSource;

  ImagePickerService({this.imageSource = ImageSource.gallery});

  bool _isAllowed(String path, List<String>? allowedExtensions) {
    if (allowedExtensions == null) return true;
    final String ext = path.split('.').last.toLowerCase();
    return allowedExtensions.map((String e) => e.toLowerCase()).contains(ext);
  }

  @override
  Future<List<File>> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    final ImagePicker picker = ImagePicker();
    List<File> result = [];

    if (allowMultiple && imageSource == ImageSource.gallery) {
      final List<XFile> images = await picker.pickMultiImage();
      for (var x in images) {
        if (_isAllowed(x.path, allowedExtensions)) {
          result.add(File(x.path));
        }
      }
    } else {
      final XFile? image = await picker.pickImage(source: imageSource);
      if (image != null && _isAllowed(image.path, allowedExtensions)) {
        result.add(File(image.path));
      }
    }

    return result;
  }
}
