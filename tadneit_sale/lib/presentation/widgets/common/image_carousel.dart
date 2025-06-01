import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageCarouselWidget extends StatefulWidget {
  final List<String> imageUrls;
  final double? height;
  final double? width;
  final int? switchDuration;

  const ImageCarouselWidget({
    super.key,
    required this.imageUrls,
    this.height,
    this.width,
    this.switchDuration
  });

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  late PageController _pageController;
  late Timer _autoSwitchTimer;
  int _currentIndex = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.imageUrls.isNotEmpty) {
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
      if (!_isUserInteracting && widget.imageUrls.length > 1) {
        final int nextIndex = (_currentIndex + 1) % widget.imageUrls.length;
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
        ? widget.imageUrls.length - 1
        : _currentIndex - 1;

    _pageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNext() {
    _setUserInteracting();
    final int nextIndex = (_currentIndex + 1) % widget.imageUrls.length;

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
        builder: (BuildContext context) => _ImageExpandedView(
          imageUrls: widget.imageUrls,
          initialIndex: _currentIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty list
    if (widget.imageUrls.isEmpty) {
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
              itemCount: widget.imageUrls.length,
              itemBuilder: (BuildContext context, int index) {
                return CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
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
              },
            ),
          ),

          // Left navigation button
          if (widget.imageUrls.length > 1)
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
                      size: ((widget.height ?? 200) / 200) * 24,
                    ),
                  ),
                ),
              ),
            ),

          // Right navigation button
          if (widget.imageUrls.length > 1)
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
                      size: ((widget.height ?? 200) / 200) * 24,
                    ),
                  ),
                ),
              ),
            ),

          // Expand button (center top)
          Positioned(
            top: 5,
            right: 5,
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
                  size: ((widget.height ?? 200) / 200) * 24,
                ),
              ),
            ),
          ),

          // Page indicators
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
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
      ),
    );
  }
}

// Private fullscreen view widget
class _ImageExpandedView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImageExpandedView({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ImageExpandedView> createState() => _ImageExpandedViewState();
}

class _ImageExpandedViewState extends State<_ImageExpandedView> {
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
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
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
        itemCount: widget.imageUrls.length,
        itemBuilder: (BuildContext context, int index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (BuildContext context, String url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (BuildContext context, String url, dynamic error) => const Center(
                  child: Icon(Icons.broken_image, size: 64, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}