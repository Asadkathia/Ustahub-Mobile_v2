import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Global image cache manager for optimized image loading
/// Uses CacheManager for disk caching
/// Configures cache settings to improve performance and reduce memory/disk usage
/// Note: Currently not used - banners and onboarding use default CachedNetworkImage cache
final customImageCacheManager = CacheManager(
  Config(
    'ustahub_images',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
  ),
);

/// Helper function to get optimized image cache settings
/// Returns CacheManager which supports disk cache resizing
/// Note: Currently not used - banners and onboarding use default CachedNetworkImage cache
CacheManager getImageCacheManager() => customImageCacheManager;

