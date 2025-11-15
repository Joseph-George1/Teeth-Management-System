import 'package:flutter/material.dart';

class ImagePrecacheService {
  static final ImagePrecacheService _instance = ImagePrecacheService._internal();
  
  // Private constructor
  ImagePrecacheService._internal();
  
  // Factory constructor to return the same instance
  factory ImagePrecacheService() => _instance;
  
  // Cache to store preloaded images
  final Map<String, ImageProvider> _precachedImages = {};
  
  /// Preloads all onboarding images
  Future<void> preloadOnboardingImages(BuildContext context) async {
    final imagePaths = [
      'assets/images/1-onboarding.jpg',
      'assets/images/2-inboarding.jpg',
      'assets/images/3-onboarding.jpg',
    ];
    
    await Future.wait(
      imagePaths.map((path) => _precacheImage(context, path)),
    );
  }
  
  /// Precaches a single image and stores it in cache
  Future<void> _precacheImage(BuildContext context, String assetPath) async {
    if (_precachedImages.containsKey(assetPath)) {
      return; // Already precached
    }
    
    try {
      final image = AssetImage(assetPath);
      // Precache the image
      await precacheImage(image, context);
      // Store the image provider for later use
      _precachedImages[assetPath] = image;
    } catch (e) {
      debugPrint('Error precaching image $assetPath: $e');
    }
  }
  
  /// Gets a preloaded image by its path
  ImageProvider? getImage(String assetPath) {
    return _precachedImages[assetPath];
  }
}
