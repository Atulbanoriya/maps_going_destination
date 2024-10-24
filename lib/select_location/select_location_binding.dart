import 'package:get/get.dart';
import 'package:maps_gomaps_api/select_location/select_location_controller.dart';

class SelectLocationBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SelectLocationController>(()=> SelectLocationController());
  }
}
