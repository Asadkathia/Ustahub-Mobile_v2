import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ustahub/network/supabase_client.dart';

class UploadFile extends GetxController {
  RxBool isLoading = false.obs;
  RxDouble progress = 0.0.obs;

  /// Uploads a file to Supabase Storage and returns the uploaded file URL
  /// 
  /// [file] - The file to upload
  /// [type] - Type of file: 'avatar', 'document', 'banner', 'service-image'
  Future<String?> uploadFile({
    required File file,
    required String type,
  }) async {
    try {
      isLoading.value = true;
      progress.value = 0.0;

      // Determine bucket based on type
      String bucket;
      final typeLower = type.toLowerCase();
      switch (typeLower) {
        case 'avatar':
        case 'profile':
        case 'profileimage':
        case 'profile_image':
          bucket = 'avatars';
          break;
        case 'document':
        case 'kyc':
        case 'nic':
        case 'tic':
        case 'passport':
          bucket = 'documents';
          break;
        case 'banner':
          bucket = 'banners';
          break;
        case 'service':
        case 'service-image':
          bucket = 'service-images';
          break;
        case 'portfolio':
        case 'portfolio-image':
        case 'portfolio-video':
          bucket = 'portfolios';
          break;
        default:
          bucket = 'avatars'; // Default bucket
      }

      // Check if user is authenticated
      if (!SupabaseClientService.isAuthenticated) {
        Get.snackbar("Error", "Please login to upload files.");
        return null;
      }

      final supabase = SupabaseClientService.instance;
      final userId = SupabaseClientService.currentUserId;
      
      if (userId == null) {
        Get.snackbar("Error", "User not authenticated.");
        return null;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '${userId}_${timestamp}.$extension';
      final filePath = '$userId/$fileName';

      print('[UPLOAD] Uploading to bucket: $bucket, path: $filePath');

      // Upload file to Supabase Storage
      await supabase.storage.from(bucket).upload(
        filePath,
        file,
        fileOptions: FileOptions(
          upsert: true, // Allow overwriting existing files
          contentType: _getContentType(extension),
        ),
      );

      // Get public URL
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(filePath);
      
      // For private buckets, get signed URL instead
      String? fileUrl;
      if (bucket == 'documents') {
        // Private bucket - get signed URL (valid for 1 year for documents)
        try {
          final signedUrlResponse = await supabase.storage
              .from(bucket)
              .createSignedUrl(filePath, 31536000); // 1 year expiry for documents
          fileUrl = signedUrlResponse;
        } catch (e) {
          // If signed URL fails, try public URL as fallback
          print('[UPLOAD] Signed URL failed, using public URL: $e');
          fileUrl = publicUrl;
        }
      } else {
        // Public bucket - use public URL
        fileUrl = publicUrl;
      }

      progress.value = 1.0;
      print('[UPLOAD] ✅ File uploaded successfully: $fileUrl');
      return fileUrl;
    } catch (e) {
      print('[UPLOAD] ❌ Error: $e');
      
      // Handle specific error types
      if (e.toString().contains('409')) {
        Get.snackbar("Error", "File already exists. Please try again.");
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        Get.snackbar("Error", "Authentication failed. Please login again.");
      } else if (e.toString().contains('413') || e.toString().contains('too large')) {
        Get.snackbar("Error", "File too large. Please select a smaller file.");
      } else if (e.toString().contains('SocketException') || e.toString().contains('network')) {
        Get.snackbar("Error", "No internet connection.");
      } else {
        Get.snackbar("Error", "Upload failed. Please try again.");
      }
      
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get content type based on file extension
  String? _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }
}
