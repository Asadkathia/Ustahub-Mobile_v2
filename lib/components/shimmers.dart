// Shimmer effect for Address List
import 'package:ustahub/app/export/exports.dart';

class AddressCardShimmer extends StatelessWidget {
  const AddressCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            Container(width: 120.w, height: 16.h, color: Colors.white),
            SizedBox(height: 6.h),

            // Address line placeholder
            Container(
              width: double.infinity,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 6.h),
            Container(
              width: double.infinity,
              height: 14.h,
              color: Colors.white,
            ),
            SizedBox(height: 12.h),

            // Divider line
            Container(height: 1.h, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Shimmer for gridview homepage

class CategoriesGridShimmer extends StatelessWidget {
  const CategoriesGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8, // 7 items + 1 "View All"
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 1.w,
          mainAxisSpacing: 20.h,
          mainAxisExtent: 115.h,
        ),
        itemBuilder: (context, index) {
          return const HomePageServiceShimmer();
        },
      ),
    );
  }
}

class HomePageServiceShimmer extends StatelessWidget {
  const HomePageServiceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            height: 72.h,
            width: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          5.ph,
          Container(
            height: 12.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ],
      ),
    );
  }
}

// Providers List shimmer

class ServiceProviderShimmerCard extends StatelessWidget {
  const ServiceProviderShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      height: 84.h,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            // Profile Image Placeholder
            Container(
              height: 64.h,
              width: 64.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 10.w),

            // Info Placeholders
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Row
                  Row(
                    children: [
                      Container(height: 12.h, width: 40.w, color: Colors.white),
                      SizedBox(width: 10.w),
                      Container(height: 12.h, width: 30.w, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Name Row
                  Container(height: 14.h, width: 100.w, color: Colors.white),
                  SizedBox(height: 4.h),

                  // Category Row
                  Container(height: 12.h, width: 70.w, color: Colors.white),
                ],
              ),
            ),

            // Price & Favourite
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 20.h, width: 20.h, color: Colors.white),
                Container(height: 14.h, width: 40.w, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceProviderShimmerList extends StatelessWidget {
  const ServiceProviderShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return const ServiceProviderShimmerCard();
      },
    );
  }
}

// address row shimmer for Checkout view

Widget addressRowShimmer() {
  return Row(
    children: [
      // Shimmer for Icon
      Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 20.h,
          width: 20.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
      5.pw,
      // Shimmer for Address Bar
      Expanded(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: [
              // Fake "city" bar
              Container(
                height: 12.h,
                width: 70.w,
                color: Colors.white,
                margin: EdgeInsets.only(right: 3.w),
              ),
              // Fake "-" bar
              Container(
                height: 12.h,
                width: 10.w,
                color: Colors.white,
                margin: EdgeInsets.only(right: 3.w),
              ),
              // Fake address bar
              Expanded(child: Container(height: 12.h, color: Colors.white)),
            ],
          ),
        ),
      ),
    ],
  );
}

// Shimmer for timeslot

Widget timeSlotShimmerGrid() {
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 13.w,
      mainAxisSpacing: 8.h,
      mainAxisExtent: 40.h,
    ),
    itemCount: 8, // or as many slots as you want as placeholder
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.green.withOpacity(0.1)),
          ),
          alignment: Alignment.center,
          child: Container(
            height: 14.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ),
      );
    },
  );
}
