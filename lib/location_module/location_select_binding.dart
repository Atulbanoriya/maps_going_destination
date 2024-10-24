import 'package:get/get.dart';
import 'package:maps_gomaps_api/location_module/location_select_controller.dart';

class LocationSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationSelectController>(() => LocationSelectController(),
    );
  }
}