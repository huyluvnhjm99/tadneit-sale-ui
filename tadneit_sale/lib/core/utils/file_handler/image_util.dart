import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../presentation/widgets/common/file_picker_dialog.dart';
import 'image_picker_service.dart';

File compressAndResizeImage(File file, final int maxSize) {
  img.Image? image = img.decodeImage(file.readAsBytesSync());

  int width;
  int height;

  if (image!.width > image.height) {
    width = maxSize;
    height = (image.height / image.width * maxSize).round();
  } else {
    height = maxSize;
    width = (image.width / image.height * maxSize).round();
  }

  img.Image resizedImage = img.copyResize(image, width: width, height: height);

  // Compress the image with JPEG format
  List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 65);

  File compressedFile = File(file.path.replaceFirst('.jpg', '_compressed.jpg'));
  compressedFile.writeAsBytesSync(compressedBytes);

  return compressedFile;
}

Future<File?> pickImage(BuildContext context, bool isOpenCamera, int size) async {
  final List<File>? files = await FilePickerDialog.show(
    context,
    allowMultiple: false,
    allowedExtensions: <String>['jpg', 'jpeg', 'png', 'gif', 'mov', 'heic'],
    pickerService: ImagePickerService(
      imageSource: isOpenCamera ? ImageSource.camera : ImageSource.gallery,
    ),
  );

  if (files != null && files.isNotEmpty) {
    return compressAndResizeImage(files.first, size);
  }

  return null;
}

Future<List<File>?> pickImages(BuildContext context, bool isOpenCamera, int size) async {
  final List<File>? files = await FilePickerDialog.show(
    context,
    allowMultiple: true,
    allowedExtensions: <String>['jpg', 'jpeg', 'png', 'gif', 'mov', 'heic'],
    pickerService: ImagePickerService(
      imageSource: isOpenCamera ? ImageSource.camera : ImageSource.gallery,
    ),
  );

  if (files != null && files.isNotEmpty) {
    return files.map((file) => compressAndResizeImage(file, size)).toList();
  }

  return null;
}