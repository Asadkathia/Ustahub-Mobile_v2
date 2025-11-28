import 'package:ustahub/app/export/exports.dart';

class DocumentController extends GetxController {
  final DocumentRepository _repository = DocumentRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isRefreshing = false.obs;
  final RxList<DocumentModel> documentsList = <DocumentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getDocuments();
  }

  // Fetch documents from API
  Future<void> getDocuments() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Fetching documents...');

      final response = await _repository.getDocuments();

      if (response['statusCode'] == 200) {
        final documentResponse = DocumentResponse.fromJson(response['body']);
        documentsList.value = documentResponse.documents;

        print('Successfully fetched ${documentsList.length} documents');
      } else {
        isError.value = true;
        errorMessage.value =
            'Failed to load documents: ${response['body']?['message'] ?? 'Unknown error'}';
        print('Failed to load documents: ${response['body']}');

        CustomToast.error(errorMessage.value);
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      print('Error loading documents: $e');

      CustomToast.error('Failed to load documents: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh documents
  Future<void> refreshDocuments() async {
    isRefreshing.value = true;
    await getDocuments();
    isRefreshing.value = false;
  }

  // Get documents count
  int get documentsCount => documentsList.length;

  // Check if documents list is empty
  bool get isEmpty => documentsList.isEmpty;

  // Check if documents list is not empty
  bool get isNotEmpty => documentsList.isNotEmpty;

  // Get verified documents count
  int get verifiedDocumentsCount =>
      documentsList.where((doc) => doc.isDocumentVerified).length;

  // Get pending documents count
  int get pendingDocumentsCount =>
      documentsList.where((doc) => !doc.isDocumentVerified).length;

  // Check if all documents are verified
  bool get allDocumentsVerified =>
      isNotEmpty && documentsList.every((doc) => doc.isDocumentVerified);

  // Get documents by verification status
  List<DocumentModel> getDocumentsByStatus(bool isVerified) {
    return documentsList
        .where((doc) => doc.isDocumentVerified == isVerified)
        .toList();
  }

  // Clear documents list
  void clearDocuments() {
    documentsList.clear();
  }

  @override
  void onClose() {
    clearDocuments();
    super.onClose();
  }
}
