import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/quote/controller/quote_controller.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class CreateQuoteRequestScreenV2 extends StatefulWidget {
  final String serviceId;
  final String? addressId;

  const CreateQuoteRequestScreenV2({
    super.key,
    required this.serviceId,
    this.addressId,
  });

  @override
  State<CreateQuoteRequestScreenV2> createState() =>
      _CreateQuoteRequestScreenV2State();
}

class _CreateQuoteRequestScreenV2State
    extends State<CreateQuoteRequestScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final QuoteController quoteController = Get.put(QuoteController());

  DateTime? preferredDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: const AppAppBarV2(
        title: 'Request Quote',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          children: [
            AppTextFieldV2(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Describe what you need',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.mdVertical),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: AppTextFieldV2(
                  controller: _dateController,
                  labelText: 'Preferred Date',
                  hintText: 'Select preferred date',
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: AppColorsV2.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lgVertical),
            Obx(() => PrimaryButtonV2(
              text: 'Request Quote',
              onPressed: quoteController.isLoading.value ? null : _submitQuote,
              isLoading: quoteController.isLoading.value,
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: preferredDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        preferredDate = picked;
        _dateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'service_id': widget.serviceId,
      if (widget.addressId != null) 'address_id': widget.addressId,
      'description': _descriptionController.text.trim(),
      if (preferredDate != null)
        'preferred_date': preferredDate!.toIso8601String().split('T')[0],
    };

    final success = await quoteController.createQuoteRequest(data);
    if (success && mounted) {
      CustomToast.success('Quote request sent successfully!');
      Get.back();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

