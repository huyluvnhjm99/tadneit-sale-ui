import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/core/errors/api_exception.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import 'package:tadneit_sale/core/utils/language_service.dart';
import 'package:tadneit_sale/data/models/item/banner.dart';
import 'package:tadneit_sale/features/admin/providers/banner_provider.dart';
import 'package:tadneit_sale/features/admin/widgets/banner_management/banner_add_form.dart';
import 'package:tadneit_sale/presentation/widgets/common/image_carousel.dart';

import '../../../presentation/widgets/common/confirmation_dialog.dart';

class BannerManagementScreen extends ConsumerStatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  ConsumerState<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends ConsumerState<BannerManagementScreen> {
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        ref.read(bannerProvider.notifier).fetchBanners();
      } on ApiException catch (e) {
        if (mounted) {
          ApiErrorHandler.showErrorSnackBar(context, e.message);
        }
      }
    });
  }

  void toggleEditMode() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  // Preload images that are about to come into view
  void _preloadImages(List<BannerDTO> banners, int currentIndex) {
    final int preloadRange = 5; // Preload 5 items ahead
    for (int i = currentIndex; i < (currentIndex + preloadRange).clamp(0, banners.length); i++) {
      final String? imageUrl = (banners[i].imgs != null) ? (banners[i].imgs?[0].url) : null;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Preload image into cache
        precacheImage(CachedNetworkImageProvider(imageUrl), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final BannerState bannerState = ref.watch(bannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.translate('banner')),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: toggleEditMode,
            icon: !_isEditable
                ? const Icon(Icons.edit)
                : const Icon(Icons.cancel, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: bannerState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : bannerState.banners.isEmpty
            ? const Center(child: Text('No data'))
            : RefreshIndicator(
          onRefresh: () => ref.read(bannerProvider.notifier).fetchBanners(),
          child: ListView.builder(
            // Add caching for better performance
            cacheExtent: 1000, // Cache 1000 pixels ahead
            itemCount: bannerState.banners.length,
            itemBuilder: (BuildContext context, int index) {
              final BannerDTO bannerDTO = bannerState.banners[index];

              if (index % 10 == 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _preloadImages(bannerState.banners, index);
                });
              }

              return _BannerListItem(
                bannerDTO: bannerDTO,
                isEditable: _isEditable,
                onEdit: () => _handleEdit(bannerDTO),
                onDelete: () => _showBannerDeleteConfirmationDialog(bannerDTO),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBannerDialog(context),
        tooltip: LanguageService.translate('addNewBanner'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleEdit(BannerDTO bannerDTO) {
    // Handle edit logic here
    print('Edit Banner: ${bannerDTO.name}');
  }

  void _showBannerDeleteConfirmationDialog(BannerDTO bannerDTO) {
    ConfirmDialog.show(
      context,
      message: 'Are you sure you want to delete Banner \'${bannerDTO.name}\'?',
      confirmText: 'OK',
      cancelText: LanguageService.translate('cancel'),
      onConfirm: () async {
        if (bannerDTO.id != null) {
          ref.read(bannerProvider.notifier).deleteBanner(bannerDTO.id ?? '');
        }
        ApiErrorHandler.showSuccessSnackBar(
            context,
            LanguageService.translate('successfully')
        );
      },
    );
  }

  void _showAddBannerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) => AddBannerForm(ref),
    );
  }
}

class _BannerListItem extends StatelessWidget {
  final BannerDTO bannerDTO;
  final bool isEditable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerListItem({
    required this.bannerDTO,
    required this.isEditable,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildLeadingImage(),
      title: Text(bannerDTO.name),
      subtitle: Text(bannerDTO.description),
      trailing: isEditable ? _buildTrailingActions() : null,
    );
  }

  Widget _buildLeadingImage() {
    if (bannerDTO.imgs == null || bannerDTO.imgs!.isEmpty) {
      return const SizedBox(
        width: 70,
        height: 70,
        child: Icon(Icons.announcement, size: 40),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 70,
          maxHeight: 70
        ),
        child: NetworkImageCarouselWidget(
          imageUrls: bannerDTO.imgs!.map((img) => img.url).whereType<String>().toList()
        )
      ),
    );
  }

  Widget _buildTrailingActions() {
    return SizedBox(
      width: 96,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Edit',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}