import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_bookings/model/provider_booking_model.dart';
import 'package:ustahub/repository/provider_repository/provider_booking_repository.dart';
import 'package:ustahub/data/response/status.dart';

class ProviderBookingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _api = ProviderBookingRepository();

  final rxRequestStatus = Status.LOADING.obs;
  final providerBookingList = ProviderBookingModel().obs;
  RxString error = ''.obs;
  late TabController tabController;
  final List<String> bookingStatus = [
    "not_started",
    "ongoing",
    "completed",
    "history",
  ];
  var selectedTab = 0.obs;

  void selectTab(int index) {
    selectedTab.value = index;
    if (index < 3) {
      providerBookingApi(bookingStatus[index]);
    }
  }

  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserList(ProviderBookingModel value) =>
      providerBookingList.value = value;
  void setError(String value) => error.value = value;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    providerBookingApi(bookingStatus[0]);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index < 3) {
          providerBookingApi(bookingStatus[tabController.index]);
        }
      }
    });
  }

  void providerBookingApi(String type) {
    setRxRequestStatus(Status.LOADING);

    _api
        .providerBookingApi(type)
        .then((value) {
          setRxRequestStatus(Status.COMPLETED);
          setUserList(value);
        })
        .onError((error, stackTrace) {
          setError(error.toString());
          setRxRequestStatus(Status.ERROR);
        });
  }

  void refreshApi(String type) {
    setRxRequestStatus(Status.LOADING);

    _api
        .providerBookingApi(type)
        .then((value) {
          setRxRequestStatus(Status.COMPLETED);
          setUserList(value);
        })
        .onError((error, stackTrace) {
          setError(error.toString());
          setRxRequestStatus(Status.ERROR);
        });
  }
}
