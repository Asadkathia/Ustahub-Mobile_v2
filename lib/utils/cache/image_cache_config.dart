import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom ImageCacheManager class that extends CacheManager with ImageCacheManager mixin
/// This enables disk cache resizing (maxWidthDiskCache/maxHeightDiskCache) support
/// ImageCacheManager is a mixin from flutter_cache_manager that provides image-specific caching
class CustomImageCacheManager extends CacheManager with ImageCacheManager {
  CustomImageCacheManager(Config config) : super(config);
}

/// Global image cache manager for optimized image loading
/// Uses ImageCacheManager mixin for better image-specific optimizations
/// Configures cache settings to improve performance and reduce memory/disk usage
/// Supports disk cache resizing for efficient storage (maxWidthDiskCache/maxHeightDiskCache)
final customImageCacheManager = CustomImageCacheManager(
  Config(
    'ustahub_images',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
  ),
);

/// Helper function to get optimized image cache settings
/// Returns CustomImageCacheManager which implements ImageCacheManager mixin
/// This is required for maxWidthDiskCache and maxHeightDiskCache parameters in CachedNetworkImage
/// ImageCacheManager provides the getImageFile method that handles image resizing on disk
CustomImageCacheManager getImageCacheManager() => customImageCacheManager;

