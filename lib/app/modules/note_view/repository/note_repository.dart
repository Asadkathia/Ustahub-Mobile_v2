import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class NoteRepository {
  final _apiServices = SupabaseApiServices();

  Future<dynamic> addNotesToBooking({
    required int bookingId,
    required String note,
    required List<File> images,
  }) async {
    try {
      // Upload images first
      List<String> imageUrls = [];
      final uploader = Get.put(UploadFile());
      
      for (File file in images) {
        if (await file.exists()) {
          final url = await uploader.uploadFile(
            file: file,
            type: 'document',
          );
          if (url != null && url.isNotEmpty) {
            imageUrls.add(url);
          }
        }
      }

      final response = await _apiServices.addBookingNote(
        bookingId: bookingId.toString(),
        note: note,
        imageUrls: imageUrls,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
