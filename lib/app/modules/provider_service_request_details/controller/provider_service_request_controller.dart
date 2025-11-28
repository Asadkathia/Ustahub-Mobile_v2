// provider_service_request_details_controller.dart
import 'package:ustahub/app/export/exports.dart';

/// Represents each stage in the workflow.
enum WorkStatus { reachedLocation, startWork, completeWork }

class ProviderServiceRequestDetailsController extends GetxController {
  /// Reactive variable that holds the current status.
  final Rx<WorkStatus> currentWorkStatus = WorkStatus.reachedLocation.obs;

  // --- Convenient computed properties --------------------------------------

  String get buttonText {
    switch (currentWorkStatus.value) {
      case WorkStatus.reachedLocation:
        return 'Reached on location';
      case WorkStatus.startWork:
        return 'Start work';
      case WorkStatus.completeWork:
        return 'Complete Work';
    }
  }

  bool get isWorkCompleted =>
      currentWorkStatus.value == WorkStatus.completeWork;

  // --- State-transition logic ----------------------------------------------

  void onBottomButtonTap() {
    switch (currentWorkStatus.value) {
      case WorkStatus.reachedLocation:
        currentWorkStatus.value = WorkStatus.startWork;
        break;
      case WorkStatus.startWork:
        currentWorkStatus.value = WorkStatus.completeWork;
        break;
      case WorkStatus.completeWork:
        _showCompletionDialog();
        break;
    }
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Work'),
        content: const Text(
          'Are you sure you want to mark this work as completed?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back(); // close dialog
              // TODO: call API, navigate, or otherwise finalise the job
              Get.snackbar(
                'Success',
                'Work marked as complete',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
