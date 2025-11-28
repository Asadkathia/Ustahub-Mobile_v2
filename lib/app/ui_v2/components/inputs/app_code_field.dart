import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class AppCodeField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;
  final String? errorText;

  const AppCodeField({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = false,
    this.errorText,
  });

  @override
  State<AppCodeField> createState() => _AppCodeFieldState();
}

class _AppCodeFieldState extends State<AppCodeField> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<String> _codes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _codes.add('');
    }
    if (widget.autoFocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      value = value.substring(value.length - 1);
    }
    
    setState(() {
      _codes[index] = value;
    });

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final code = _codes.join('');
    widget.onChanged?.call(code);
    
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _onBackspace(int index) {
    if (_codes[index].isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {
        _codes[index - 1] = '';
      });
    } else {
      setState(() {
        _codes[index] = '';
      });
    }
    
    final code = _codes.join('');
    widget.onChanged?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            widget.length,
            (index) => SizedBox(
              width: 60.w,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 24.sp,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColorsV2.background,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: AppSpacing.mdVertical,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    borderSide: BorderSide(
                      color: AppColorsV2.borderLight,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    borderSide: BorderSide(
                      color: _codes[index].isEmpty
                          ? AppColorsV2.borderLight
                          : AppColorsV2.borderFocus,
                      width: _codes[index].isEmpty ? 1 : 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    borderSide: BorderSide(
                      color: AppColorsV2.borderFocus,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    borderSide: BorderSide(
                      color: AppColorsV2.error,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (value) => _onChanged(index, value),
                onTap: () {
                  _controllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: _controllers[index].text.length),
                  );
                },
                onSubmitted: (_) {
                  if (index < widget.length - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: AppSpacing.smVertical),
          Text(
            widget.errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColorsV2.error,
            ),
          ),
        ],
      ],
    );
  }
}




