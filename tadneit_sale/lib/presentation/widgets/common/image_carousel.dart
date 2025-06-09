import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

abstract class BaseImageCarouselWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final int? switchDuration;

  const BaseImageCarouselWidget({
    super.key,
    this.height,
    this.width,
    this.switchDuration,
  });

  int get itemCount;
  Widget buildImageWidget(BuildContext context, int index);
  Widget buildExpandedImageWidget(BuildContext context, int index);
}

abstract class BaseImageCarouselWidgetState<T extends BaseImageCarouselWidget> extends State<T> {
  late PageController _pageController;
  late Timer _autoSwitchTimer;
  int _currentIndex = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.itemCount > 0) {
      _startAutoSwitch();
    }
  }

  @override
  void dispose() {
    _autoSwitchTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSwitch() {
    _autoSwitchTimer = Timer.periodic(Duration(seconds: widget.switchDuration ?? 5), (Timer timer) {
      if (!_isUserInteracting && widget.itemCount > 1) {
        final int nextIndex = (_currentIndex + 1) % widget.itemCount;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _goToPrevious() {
    _setUserInteracting();
    final int previousIndex = _currentIndex == 0
        ? widget.itemCount - 1
        : _currentIndex - 1;

    _pageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    _setUserInteracting();
    final int nextIndex = (_currentIndex + 1) % widget.itemCount;

    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _setUserInteracting() {
    _isUserInteracting = true;
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _isUserInteracting = false;
      }
    });
  }

  void _expandImage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _BaseImageExpandedView(
          itemCount: widget.itemCount,
          initialIndex: _currentIndex,
          buildImageWidget: widget.buildExpandedImageWidget,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = ((widget.height ?? 200) / 200) * 18;

    // Handle empty list
    if (widget.itemCount == 0) {
      return Container(
        height: widget.height ?? 200,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No images', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height ?? 200,
      width: widget.width,
      child: Stack(
        children: <Widget>[
          // Main image carousel
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.itemCount,
              itemBuilder: widget.buildImageWidget,
            ),
          ),

          // Navigation buttons and indicators (same as before)
          if (widget.itemCount > 1) ...[
            // Left navigation button
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToPrevious,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),

            // Right navigation button
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToNext,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),

            // Page indicators
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.itemCount,
                      (int index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Expand button
          Positioned(
            top: 3,
            right: 3,
            child: GestureDetector(
              onTap: _expandImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Network Image Carousel
class NetworkImageCarouselWidget extends BaseImageCarouselWidget {
  final List<String> imageUrls;

  const NetworkImageCarouselWidget({
    super.key,
    required this.imageUrls,
    super.height,
    super.width,
    super.switchDuration,
  });

  @override
  int get itemCount => imageUrls.length;

  @override
  Widget buildImageWidget(BuildContext context, int index) {
    return CachedNetworkImage(
      imageUrl: imageUrls[index],
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (BuildContext context, String url, dynamic error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget buildExpandedImageWidget(BuildContext context, int index) {
    return CachedNetworkImage(
      imageUrl: imageUrls[index],
      fit: BoxFit.contain,
      placeholder: (BuildContext context, String url) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorWidget: (BuildContext context, String url, dynamic error) => const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.white),
      ),
    );
  }

  @override
  State<NetworkImageCarouselWidget> createState() => _NetworkImageCarouselWidgetState();
}

class _NetworkImageCarouselWidgetState extends BaseImageCarouselWidgetState<NetworkImageCarouselWidget> {}

// File Image Carousel
class FileImageCarouselWidget extends BaseImageCarouselWidget {
  final List<File> imageFiles;

  const FileImageCarouselWidget({
    super.key,
    required this.imageFiles,
    super.height,
    super.width,
    super.switchDuration,
  });

  @override
  int get itemCount => imageFiles.length;

  @override
  Widget buildImageWidget(BuildContext context, int index) {
    return Image.file(
      imageFiles[index],
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        );
      },
    );
  }

  @override
  Widget buildExpandedImageWidget(BuildContext context, int index) {
    return Image.file(
      imageFiles[index],
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 64, color: Colors.white),
        );
      },
    );
  }

  @override
  State<FileImageCarouselWidget> createState() => _FileImageCarouselWidgetState();
}

class _FileImageCarouselWidgetState extends BaseImageCarouselWidgetState<FileImageCarouselWidget> {}

// Base expanded view
class _BaseImageExpandedView extends StatefulWidget {
  final int itemCount;
  final int initialIndex;
  final Widget Function(BuildContext, int) buildImageWidget;

  const _BaseImageExpandedView({
    required this.itemCount,
    required this.initialIndex,
    required this.buildImageWidget,
  });

  @override
  State<_BaseImageExpandedView> createState() => _BaseImageExpandedViewState();
}

class _BaseImageExpandedViewState extends State<_BaseImageExpandedView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.itemCount}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.itemCount,
        itemBuilder: (BuildContext context, int index) {
          return InteractiveViewer(
            child: Center(
              child: widget.buildImageWidget(context, index),
            ),
          );
        },
      ),
    );
  }
}