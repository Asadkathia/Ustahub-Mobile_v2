import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Global image cache manager for optimized image loading
/// Uses ImageCacheManager for better image-specific optimizations
/// Configures cache settings to improve performance and reduce memory/disk usage
final customImageCacheManager = ImageCacheManager(
  Config(
    'ustahub_images',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
  ),
);

/// Helper function to get optimized image cache settings
/// Returns ImageCacheManager which supports disk cache resizing
ImageCacheManager getImageCacheManager() => customImageCacheManager;

