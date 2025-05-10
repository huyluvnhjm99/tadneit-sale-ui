import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ConfirmDialog {
  static Future<bool> show(
      BuildContext context, {
        required String message,
        required String confirmText,
        required String cancelText,
        required VoidCallback onConfirm,
      }) async {
    if (Platform.isIOS) {
      return await _showCupertinoDialog(
        context: context,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      );
    } else {
      return await _showMaterialDialog(
        context: context,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      );
    }
  }

  // Private method for Material dialog
  static Future<bool> _showMaterialDialog({
    required BuildContext context,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText, style: const TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop(true);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Private method for Cupertino dialog
  static Future<bool> _showCupertinoDialog({
    required BuildContext context,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) async {
    final bool? result = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            isDestructiveAction: true,
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop(true);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}