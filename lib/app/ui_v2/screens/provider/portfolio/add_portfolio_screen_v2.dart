import 'dart:io';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_portfolio/controller/portfolio_controller.dart';
import 'package:ustahub/app/modules/provider_portfolio/model/portfolio_model.dart';
import 'package:ustahub/app/modules/upload_file/upload_file.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class AddPortfolioScreenV2 extends StatefulWidget {
  final PortfolioModel? portfolio;
  final String? serviceId;

  const AddPortfolioScreenV2({
    super.key,
    this.portfolio,
    this.serviceId,
  });

  @override
  State<AddPortfolioScreenV2> createState() => _AddPortfolioScreenV2State();
}

class _AddPortfolioScreenV2State extends State<AddPortfolioScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectDateController = TextEditingController();
  final _tagsController = TextEditingController();

  final PortfolioController portfolioController = Get.put(PortfolioController());
  final UploadFile uploadFileController = Get.put(UploadFile());

  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> uploadedImageUrls = <String>[].obs;
  final RxBool isFeatured = false.obs;
  final RxBool isUploading = false.obs;
  final RxString? selectedServiceId = null.obs;

  DateTime? projectDate;

  @override
  void initState() {
    super.initState();
    if (widget.portfolio != null) {
      _loadPortfolioData(widget.portfolio!);
    }
    if (widget.serviceId != null) {
      selectedServiceId?.value = widget.serviceId;
    }
  }

  void _loadPortfolioData(PortfolioModel portfolio) {
    _titleController.text = portfolio.title ?? '';
    _descriptionController.text = portfolio.description ?? '';
    if (portfolio.projectDate != null) {
      projectDate = portfolio.projectDate;
      _projectDateController.text =
          '${portfolio.projectDate!.day}/${portfolio.projectDate!.month}/${portfolio.projectDate!.year}';
    }
    _tagsController.text = portfolio.tags.join(', ');
    isFeatured.value = portfolio.isFeatured;
    uploadedImageUrls.value = List<String>.from(portfolio.imageUrls);
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      selectedImages.addAll(images.map((xFile) => File(xFile.path)));
    }
  }

  Future<void> _uploadImages() async {
    if (selectedImages.isEmpty) return;

    isUploading.value = true;
    final List<String> urls = [];

    for (final file in selectedImages) {
      final url = await uploadFileController.uploadFile(
        file: file,
        type: 'portfolio',
      );
      if (url != null && url.isNotEmpty) {
        urls.add(url);
      }
    }

    uploadedImageUrls.addAll(urls);
    selectedImages.clear();
    isUploading.value = false;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: projectDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        projectDate = picked;
        _projectDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _savePortfolio() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload any pending images
    if (selectedImages.isNotEmpty) {
      await _uploadImages();
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      if (projectDate != null) 'project_date': projectDate!.toIso8601String().split('T')[0],
      'image_urls': uploadedImageUrls.toList(),
      'tags': tags,
      'is_featured': isFeatured.value,
      if (selectedServiceId?.value != null) 'service_id': selectedServiceId?.value,
    };

    bool success;
    if (widget.portfolio != null) {
      success = await portfolioController.updatePortfolio(
        widget.portfolio!.id!,
        data,
      );
    } else {
      success = await portfolioController.createPortfolio(data);
    }

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: const AppAppBarV2(
        title: 'Add Portfolio',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          children: [
            // Title field
            AppTextFieldV2(
              controller: _titleController,
              labelText: 'Title',
              hintText: 'Enter portfolio title',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.mdVertical),
            // Description field
            AppTextFieldV2(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Enter portfolio description',
              maxLines: 4,
            ),
            SizedBox(height: AppSpacing.mdVertical),
            // Project date field
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: AppTextFieldV2(
                  controller: _projectDateController,
                  labelText: 'Project Date',
                  hintText: 'Select project date',
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: AppColorsV2.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.mdVertical),
            // Tags field
            AppTextFieldV2(
              controller: _tagsController,
              labelText: 'Tags',
              hintText: 'Enter tags separated by commas',
            ),
            SizedBox(height: AppSpacing.mdVertical),
            // Featured toggle
            Obx(() => SwitchListTile(
              title: Text(
                'Featured',
                style: AppTextStyles.bodyMedium,
              ),
              subtitle: Text(
                'Show this portfolio in featured section',
                style: AppTextStyles.captionSmall,
              ),
              value: isFeatured.value,
              onChanged: (value) => isFeatured.value = value,
            )),
            SizedBox(height: AppSpacing.mdVertical),
            // Images section
            Text(
              'Images',
              style: AppTextStyles.heading4,
            ),
            SizedBox(height: AppSpacing.smVertical),
            // Selected images preview
            Obx(() {
              if (selectedImages.isEmpty && uploadedImageUrls.isEmpty) {
                return Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: AppColorsV2.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(
                      color: AppColorsV2.borderLight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: AppSpacing.iconXLarge,
                          color: AppColorsV2.textTertiary,
                        ),
                        SizedBox(height: AppSpacing.xsVertical),
                        Text(
                          'No images selected',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColorsV2.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  // Show selected files
                  ...selectedImages.map((file) => _buildImagePreview(file)),
                  // Show uploaded URLs
                  ...uploadedImageUrls.map((url) => _buildImageUrlPreview(url)),
                ],
              );
            }),
            SizedBox(height: AppSpacing.mdVertical),
            // Add images button
            SecondaryButtonV2(
              text: 'Add Images',
              icon: Icons.add_photo_alternate,
              onPressed: _pickImages,
            ),
            SizedBox(height: AppSpacing.lgVertical),
            // Save button
            Obx(() => PrimaryButtonV2(
              text: widget.portfolio != null ? 'Update Portfolio' : 'Create Portfolio',
              onPressed: isUploading.value ? null : _savePortfolio,
              isLoading: isUploading.value || portfolioController.isLoading.value,
            )),
            SizedBox(height: AppSpacing.xlVertical),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File file) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: () => selectedImages.remove(file),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColorsV2.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16.sp,
                color: AppColorsV2.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUrlPreview(String url) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: () => uploadedImageUrls.remove(url),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColorsV2.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16.sp,
                color: AppColorsV2.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectDateController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}

