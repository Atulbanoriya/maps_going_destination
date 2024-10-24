import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_gomaps_api/select_location/select_location_controller.dart';
import '../util/app_routes.dart';

class SelectLocationScreen extends GetView<SelectLocationController>{
  const SelectLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;

    return GetBuilder(
        init: SelectLocationController(),
        builder: (SelectLocationController selectLocationController){
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.green,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
              title: const Text('New Post'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: h * 0.015,),
                    _buildLocationSelector(),
                  ],
                ),
              ),
            ),
          );
        });
  }







  Widget _buildLocationSelector() {
    return Obx(
          () => GestureDetector(
        onTap: () {
          getLocData();
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      controller.selectedLocation.value.isEmpty
                          ? 'Add location'
                          : controller.selectedLocation.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                "${controller.fullAddress} ${controller.state} ${controller.city} ${controller.country}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> getLocData() async {
    try {
      final result = await Get.toNamed(Routes.locationSelect);

      if (result != null) {
        controller.fullAddress.value = result['address'].toString();
        controller.latitude.value = result['latitude'];
        controller.longitude.value = result['longitude'];
        controller.city.value = result['city'];
        controller.state.value = result['state'];
        controller.country.value = result['country'];
        controller.update();
      } else {
        print('Navigation returned null, cannot update location data.');
      }
    } catch (e) {
      print('Error occurred during navigation: $e');
    }
  }


}