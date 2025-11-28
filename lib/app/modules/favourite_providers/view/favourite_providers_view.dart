import 'package:ustahub/app/export/exports.dart';

class FavouriteProvidersView extends StatefulWidget {
  const FavouriteProvidersView({super.key});

  @override
  State<FavouriteProvidersView> createState() => _FavouriteProvidersViewState();
}

class _FavouriteProvidersViewState extends State<FavouriteProvidersView> {
  final FavouriteProviderController controller = Get.put(
    FavouriteProviderController(),
  );

  @override
  void initState() {
    super.initState();
    controller.getFavouriteProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.favouriteProviders,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.favouriteProvidersList.isEmpty) {
          return Center(child: Text('No favourite providers found'));
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: controller.favouriteProvidersList.length,
          itemBuilder: (context, index) {
            final data = controller.favouriteProvidersList[index];
            final servicesString = (data.services ?? [])
                .map((s) => s.name ?? '')
                .where((name) => name.isNotEmpty)
                .join(', ');
            return ServiceProviderCard(
              isFavorite: data.isFavorite ?? false,
              onTap: () {
                Get.to(() => ProviderDetailsScreen(id: data.id.toString()));
              },
              starValue: data.averageRating ?? 0.0,
              name: data.name ?? "",
              category: servicesString,
              // amount:
              //     data.plans?.isNotEmpty ?? false
              //         ? double.tryParse(data.plans?.first.planPrice ?? '') ?? 0
              //         : 0,
              imageUrl: data.avatar ?? blankProfileImage,
              onFavoriteTap: () async {
                await controller.favouriteToggle(id: data.id.toString());
                controller.favouriteProvidersList.removeAt(index);
              },
            );
          },
        );
      }),
    );
  }
}
