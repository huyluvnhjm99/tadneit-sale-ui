import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/data/models/item/category.dart';
import 'package:tadneit_sale/data/models/item/item.dart';
import 'package:tadneit_sale/features/admin/providers/item_provider.dart';

import '../../../../core/utils/file_handler/image_util.dart';
import '../../../../core/utils/language_service.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/models/file/file.dart';
import '../../../../data/providers/api_service_provider.dart';

class AddItemForm extends StatefulWidget {
  const AddItemForm(this.ref, {super.key, required this.categories});

  final WidgetRef ref;
  final List<CategoryDTO> categories;

  @override
  State<AddItemForm> createState() => AddItemFormState();
}

class AddItemFormState extends State<AddItemForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<File> _itemImages = [];
  bool _isSavingItem = false;
  List<CategoryDTO>? _selectedCategories;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
          child: SizedBox(
            height: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog title
                  Text(
                    LanguageService.translate('addNewItem'),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  _buildImageSelector(),
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: CustomDropdown<CategoryDTO>.multiSelectSearch(
                      hintText: LanguageService.translate('category'),
                      items: widget.categories,
                      onListChanged: (List<CategoryDTO> value) {
                        _selectedCategories = value;
                      },
                      listValidator: (value) {
                        if (value.isEmpty) {
                          return LanguageService.translate('required');
                        }
                        return null;
                      },
                    ),
                  ),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: LanguageService.translate('itemName'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.add_shopping_cart_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    maxLength: 255,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return LanguageService.translate('required');
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      labelText: LanguageService.translate('itemBrand'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.branding_watermark_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    maxLength: 255,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return LanguageService.translate('required');
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: LanguageService.translate('itemPrice'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.monetization_on_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    maxLength: 15,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return LanguageService.translate('required');
                      }
                      if (double.parse(value) < 0) {
                        return '>= 0';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: LanguageService.translate('itemDescription'),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    maxLength: 1024,
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
                      _isSavingItem
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () => _saveItem(),
                        child: Text(LanguageService.translate('save')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isSavingItem = true;
      });

      ItemDTO newItem = ItemDTO(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        categories: _selectedCategories ?? [],
      );

      if (_itemImages.isNotEmpty) {
        final ApiService apiService = widget.ref.read(apiServiceProvider);
        final List<FileDTO> imgDTOs = await Future.wait(
            _itemImages.map((img) => apiService.uploadFile(img))
        );
        newItem.images = imgDTOs;
      }

      try {
        await widget.ref.read(itemProvider.notifier).saveItem(newItem);
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
          _isSavingItem = false;
        });
        if (mounted) {
          context.pop();
        }
      }
    }
  }

  Widget _buildImageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Add Images",
                  style: TextStyle(fontSize: 16),
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
                        _itemImages.reversed;
                        _itemImages.add(image);
                        _itemImages.reversed;
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
                        _itemImages.reversed;
                        _itemImages.add(image);
                        _itemImages.reversed;
                      });
                    }
                  },
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_itemImages.isNotEmpty)
                    ..._itemImages.map((img) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          img,
                          fit: BoxFit.cover,
                          height: 100,
                          errorBuilder:
                              (context, error, stackTrace) =>
                          const Icon(Icons.error),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          ]
      ),
    );
  }
}