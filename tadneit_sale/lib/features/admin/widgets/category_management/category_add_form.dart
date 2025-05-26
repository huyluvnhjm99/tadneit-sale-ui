import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';

import '../../../../core/utils/file_handler/image_util.dart';
import '../../../../core/utils/language_service.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/models/file/file.dart';
import '../../../../data/models/item/category.dart';
import '../../../../data/providers/api_service_provider.dart';
import '../../providers/category_provider.dart';

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm(this.ref, {super.key});

  final WidgetRef ref;

  @override
  State<AddCategoryForm> createState() => AddCategoryFormState();
}

class AddCategoryFormState extends State<AddCategoryForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? categoryIcon;
  bool isSavingCategory = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog title
              Text(
                LanguageService.translate('addNewCategory'),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Image display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                categoryIcon != null
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          categoryIcon!,
                          fit: BoxFit.cover,
                          height: 100,
                          errorBuilder:
                              (context, error, stackTrace) =>
                          const Icon(Icons.error),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          categoryIcon = null;
                        });
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
                    : Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Select category Icon:",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      tooltip: "Add photo",
                      onPressed: () async {
                        final File? image = await pickImage(
                          context,
                          false,
                          200,
                        );
                        if (image != null) {
                          setState(() {
                            categoryIcon = image;
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      tooltip: "Take a photo",
                      onPressed: () async {
                        final File? image = await pickImage(
                          context,
                          true,
                          200,
                        );
                        if (image != null) {
                          setState(() {
                            categoryIcon = image;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Rest of your form fields...
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: LanguageService.translate('categoryName'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return LanguageService.translate('required');
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 8),

              // Description field
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: LanguageService.translate('categoryDescription'),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.description),
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LanguageService.translate('required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(LanguageService.translate('cancel')),
                  ),
                  const SizedBox(width: 8),
                  isSavingCategory
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () => _saveCategory(),
                    child: Text(LanguageService.translate('save')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isSavingCategory = true;
      });

      final CategoryDTO category = CategoryDTO(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
      );

      if (categoryIcon != null) {
        final ApiService apiService = widget.ref.read(apiServiceProvider);
        FileDTO uploadedCategoryIcon = await apiService.uploadFile(
          categoryIcon!,
        );
        category.img = uploadedCategoryIcon;
      }

      try {
        widget.ref.read(categoryProvider.notifier).saveCategory(category);
        if (mounted) {
          ApiErrorHandler.showSuccessSnackBar(
            context,
            LanguageService.translate('successfully'),
          );
        }
      } on ApiException catch (e) {
        if (mounted) {
          ApiErrorHandler.showErrorSnackBar(
            context,
            LanguageService.translate(e.message),
          );
        }
      } finally {
        setState(() {
          isSavingCategory = false;
        });
        if (mounted) {
          context.pop();
        }
      }
    }
  }
}