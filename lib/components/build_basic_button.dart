import 'package:ustahub/app/export/exports.dart';

class BuildBasicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final Color? buttonColor;
  final TextStyle? textStyle;
  final bool enableShadow;
  final Widget? icon; // <-- updated to Widget
  double? radius;

  BuildBasicButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.height,
    this.buttonColor,
    this.textStyle,
    this.enableShadow = true,
    this.icon,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: enableShadow ? 1 : 0,
        minimumSize: Size.fromHeight(height ?? 48.h),
        backgroundColor: buttonColor,
        textStyle: textStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 30.r),
        ),
      ),
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
        child: Text(
          title,
          style:
              textStyle ??
              TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
