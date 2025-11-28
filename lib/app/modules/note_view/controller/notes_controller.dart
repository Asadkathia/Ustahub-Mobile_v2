import 'package:ustahub/app/export/exports.dart';

class NotesController extends GetxController {
  final NotesRepository _notesRepository = NotesRepository();

  // Observable variables
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isRefreshing = false.obs;

  // Current booking ID
  final RxString currentBookingId = ''.obs;

  // Set booking ID and fetch notes
  void setBookingId(String bookingId) {
    currentBookingId.value = bookingId;
    if (bookingId.isNotEmpty) {
      fetchNotes(bookingId);
    }
  }

  // Fetch notes for a specific booking
  Future<void> fetchNotes(String bookingId) async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Fetching notes for booking ID: $bookingId');

      final notesResponse = await _notesRepository.getNotesByBookingId(
        bookingId,
      );

      // Update notes list
      notes.value = notesResponse.data;

      print('Successfully fetched ${notes.length} notes');
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching notes: $e');

      // Show error message to user using CustomToast
      CustomToast.error('Failed to fetch notes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh notes
  Future<void> refreshNotes() async {
    if (currentBookingId.value.isNotEmpty) {
      isRefreshing.value = true;
      await fetchNotes(currentBookingId.value);
      isRefreshing.value = false;
    }
  }

  // Add a new note and refresh the list
  Future<void> addNoteAndRefresh({
    required String bookingId,
    required String note,
    required List<File> images,
  }) async {
    try {
      print('Adding note to booking $bookingId');

      // Add the note via repository
      final response = await _notesRepository.addNotesToBooking(
        bookingId: bookingId,
        note: note,
        images: images,
      );

      print('API Response: $response');

      // Check if the response is successful
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        print('Note added successfully, refreshing list...');

        // Refresh the notes list to include the new note
        await fetchNotes(bookingId);
      //  Get.back(); // Close the modal if opened

        // Show success message using CustomToast
        CustomToast.success("Note added successfully");
      } else {
        // Handle API error response
        final errorMessage =
            response['body']?['message'] ?? 'Failed to add note';
        print('API Error: $errorMessage');

        CustomToast.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error adding note: $e');

      // Show error message using CustomToast
      String errorMessage = 'Failed to add note';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMessage = 'Failed to add note: ${e.toString()}';
      }

      CustomToast.error(errorMessage);
      rethrow; // Re-throw to handle in UI
    }
  }

  // Get notes count
  int get notesCount => notes.length;

  // Check if notes list is empty
  bool get isEmpty => notes.isEmpty;

  // Check if notes list is not empty
  bool get isNotEmpty => notes.isNotEmpty;

  // Get notes for current booking
  List<NoteModel> get currentNotes => notes.toList();

  // Clear notes list
  void clearNotes() {
    notes.clear();
    currentBookingId.value = '';
  }

  // Get formatted notes for UI display
  List<Map<String, dynamic>> get formattedNotes {
    return notes.map((note) {
      return {
        'id': note.id,
        'name':
            'User ${note.userId}', // You might want to fetch actual user names
        'date': note.formattedDate,
        'note': note.note,
        'imageUrls': note.images,
        'hasImages': note.hasImages,
        'userId': note.userId,
        'createdAt': note.createdAt,
      };
    }).toList();
  }

  @override
  void onClose() {
    clearNotes();
    super.onClose();
  }
}
