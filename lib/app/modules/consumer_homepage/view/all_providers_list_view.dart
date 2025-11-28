// import 'package:ustahub/app/export/exports.dart';
// import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';

// class AllProvidersListView extends StatelessWidget {
//   final List<ProvidersListModelClass> providers;
//   final String serviceName;
//   const AllProvidersListView({super.key, required this.providers, required this.serviceName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: serviceName),
//       body: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
//         itemCount: providers.length,
//         itemBuilder: (context, index) {
//           final data = providers[index];
//           final servicesString = (data.services ?? [])
//               .map((s) => s.name ?? '')
//               .where((name) => name.isNotEmpty)
//               .join(', ');
//           return ServiceProviderCard(
//             onFavoriteTap: null, // You can wire this if needed
//             isFavorite: data.isFavorite ?? false,
//             onTap: () {
//               Get.to(() => ProviderDetailsScreen(id: data.id.toString()));
//             },
//             starValue: double.parse(data.averageRating ?? '0.0'),
//             name: data.name ?? "",
//             category: servicesString,
//             amount:
//                 data.plans?.isNotEmpty ?? false
//                     ? double.tryParse(data.plans?.first.planPrice ?? '') ?? 0
//                     : 0,
//             imageUrl: data.avatar ?? blankProfileImage,
//           );
//         },
//       ),
//     );
//   }
// }
