import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Source type for media selection
enum MediaSource {
  gallery,
  camera,
  file,
}

/// Service for handling media picking operations
class MediaPickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick a single image from gallery or camera
  Future<File?> pickImage({
    required MediaSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source == MediaSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );

    return pickedFiles.map((XFile file) => File(file.path)).toList();
  }

  /// Pick a video from gallery or camera
  Future<File?> pickVideo({
    required MediaSource source,
    Duration? maxDuration,
  }) async {
    final XFile? pickedFile = await _imagePicker.pickVideo(
      source: source == MediaSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxDuration: maxDuration,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  /// Pick files using the file picker
  Future<List<File>> pickFiles({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions != null ? FileType.custom : type,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      return result.files
          .where((PlatformFile file) => file.path != null)
          .map((PlatformFile file) => File(file.path!))
          .toList();
    }

    return [];
  }

  /// Show an action sheet for selecting media source
  Future<MediaSource?> showMediaSourceSelector(BuildContext context) async {
    return await showModalBottomSheet<MediaSource>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, MediaSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, MediaSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('File'),
              onTap: () => Navigator.pop(context, MediaSource.file),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider for MediaPickerService
final Provider<MediaPickerService> mediaPickerProvider = Provider<MediaPickerService>((Ref ref) {
  return MediaPickerService();
});