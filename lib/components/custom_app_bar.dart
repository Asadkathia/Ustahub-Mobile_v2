import 'package:ustahub/app/export/exports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isTitleCenter;
  final VoidCallback? onBackTap;
  final bool isSHowBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isTitleCenter = false,
    this.onBackTap,
    this.isSHowBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: isTitleCenter,
      leading: IconButton(
        onPressed: onBackTap ?? () => Get.back(),
        icon:
            isSHowBackButton
                ? Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: SvgPicture.asset(
                    AppVectors.back,
                    height: 34.w,
                    width: 34.w,
                  ),
                )
                : SizedBox.shrink(),
      ),
      title: Text(
        title,
        style: GoogleFonts.ubuntu(fontSize: 18.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
