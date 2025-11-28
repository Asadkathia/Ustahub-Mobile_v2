import 'package:intl/intl.dart';
import 'package:ustahub/app/export/exports.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

extension space on num {
  SizedBox get ph => SizedBox(height: h);
  SizedBox get pw => SizedBox(width: w);
}

String blankProfileImage =
    "https://imgs.search.brave.com/X4LThvVdH34ppwBF_Ot-YP9e62amWu5HTsvTNqKx5HI/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/aXByY2VudGVyLmdv/di9pbWFnZS1yZXBv/c2l0b3J5L2JsYW5r/LXByb2ZpbGUtcGlj/dHVyZS5wbmcvQEBp/bWFnZXMvaW1hZ2Uu/cG5n";

// Helper function to clean up local development URLs
String cleanImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return blankProfileImage;
  }

  // Check if the image URL is a local development URL and fallback to blank profile
  if (imageUrl.contains('127.0.0.1') ||
      imageUrl.contains('localhost') ||
      imageUrl.contains(':47660') ||
      imageUrl.startsWith('file://')) {
    return blankProfileImage;
  }

  // Basic URL validation - check if it starts with http/https
  if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
    return blankProfileImage;
  }

  return imageUrl;
}

String formatToYMD(DateTime date) {
  return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

String getCurrentTimeHHmm() {
  final now = DateTime.now();
  final hours = now.hour.toString().padLeft(2, '0');
  final minutes = now.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

int visitingCharge = 22;

String convertTo12HourFormat(String? time24Hour) {
  if (time24Hour == null || time24Hour.isEmpty) return "-";
  try {
    final parts = time24Hour.split(':');
    if (parts.length < 2) return "-";
    final time = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('hh:mm a').format(dateTime);
  } catch (e) {
    print("Error parsing time: $e");
    return "-";
  }
}

String formatDate(String? inputDate) {
  if (inputDate == null || inputDate.isEmpty) return "-";
  try {
    final parsedDate = DateTime.parse(inputDate); // Format: yyyy-MM-dd
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  } catch (e) {
    print("Error parsing date: $e");
    return "-";
  }
}
