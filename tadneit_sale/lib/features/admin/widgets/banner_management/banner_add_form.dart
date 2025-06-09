import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/data/models/item/banner.dart';
import 'package:tadneit_sale/features/admin/providers/banner_provider.dart';
import 'package:tadneit_sale/presentation/widgets/common/image_carousel.dart';

import '../../../../core/utils/file_handler/image_util.dart';
import '../../../../core/utils/language_service.dart';
import '../../../../data/datasources/api_service.dart';
import '../../../../data/models/file/file.dart';
import '../../../../data/providers/api_service_provider.dart';

class AddBannerForm extends StatefulWidget {
  const AddBannerForm(this.ref, {super.key});

  final WidgetRef ref;

  @override
  State<AddBannerForm> createState() => AddCategoryFormState();
}

class AddCategoryFormState extends State<AddBannerForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<File> bannerImages = [];
  bool isSavingBanner = false;

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
                LanguageService.translate('addNewBanner'),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Image display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                bannerImages.isNotEmpty
                    ? Stack(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 250,
                                maxHeight: 100
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                FileImageCarouselWidget(imageFiles: bannerImages),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5.0,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  bannerImages = [];
                                });
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Select banner Images:",
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      tooltip: "Add photo",
                      onPressed: () async {
                        final List<File>? images = await pickImages(
                          context,
                          false,
                          600,
                        );
                        if (images != null) {
                          setState(() {
                            bannerImages.addAll(images);
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
                            bannerImages.add(image);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: LanguageService.translate('bannerName'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.announcement_outlined),
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
                  labelText: LanguageService.translate('bannerDescription'),
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
                  isSavingBanner
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () => _saveBanner(),
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

  Future<void> _saveBanner() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isSavingBanner = true;
      });

      final BannerDTO newBannerDTO = BannerDTO(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
      );

      if (bannerImages.isNotEmpty) {
        final ApiService apiService = widget.ref.read(apiServiceProvider);
        final List<FileDTO> imgDTOs = await Future.wait(
            bannerImages.map((img) => apiService.uploadFile(img))
        );
        newBannerDTO.imgs = imgDTOs;
      }

      try {
        widget.ref.read(bannerProvider.notifier).saveBanner(newBannerDTO);
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
          isSavingBanner = false;
        });
        if (mounted) {
          context.pop();
        }
      }
    }
  }
}