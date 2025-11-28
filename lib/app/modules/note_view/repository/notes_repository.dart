import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/network/supabase_client.dart';

class NotesRepository {
  final _apiServices = SupabaseApiServices();

  // Get notes by booking ID
  Future<NotesResponse> getNotesByBookingId(String bookingId) async {
    try {
      final response = await _apiServices.getBookingNotes(bookingId);

      // Parse response
      if (response['statusCode'] == 200 &&
          response['body']['data'] != null) {
        return NotesResponse.fromJson({
          'data': response['body']['data'],
        });
      } else {
        throw Exception('Failed to fetch notes: ${response['body']}');
      }
    } catch (e) {
      print('Error fetching notes: $e');
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Add note to booking
  Future<Map<String, dynamic>> addNotesToBooking({
    required String bookingId,
    required String note,
    required List<File> images,
  }) async {
    try {
      // Upload images first
      List<String> imageUrls = [];
      final uploader = Get.put(UploadFile());
      
      for (File file in images) {
        if (file.existsSync()) {
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
        bookingId: bookingId,
        note: note,
        imageUrls: imageUrls,
      );

      return response;
    } catch (e) {
      print('Error adding note: $e');
      throw Exception('Failed to add note: $e');
    }
  }
}
