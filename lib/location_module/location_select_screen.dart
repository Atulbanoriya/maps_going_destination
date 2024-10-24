import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maps_gomaps_api/location_module/location_select_controller.dart';
import '../util/app_colors.dart';
import 'location_list.dart';

class LocationSelectScreen extends GetView<LocationSelectController> {
  const LocationSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return GetBuilder(
        init: LocationSelectController(),
        builder: (LocationSelectController locationController) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SizedBox(
                width: w,
                height: h,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Choose Your Location',
                        style: TextStyle(
                            color: AppColors.white80,
                            fontSize: 25,
                            fontFamily: 'madaSemiBold'
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      dummyTextField(context),
                      renderMap(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.dragDisabled.value =
                                !controller.dragDisabled.value;
                                controller.update();
                              },
                              child: const Text('Change',
                                style: TextStyle(
                                    color: AppColors.kPrimaryColor,
                                    fontSize: 16,
                                    fontFamily: 'madaSemiBold',
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.kPrimaryColor
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomSheet: Container(
              color: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              width: w,
              height: h * 0.22,
              child: controller.textLoading.value ?
              SizedBox(
                  width: 200,
                  height: 50,
                  child: Center(child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.kPrimaryColor, size: 50))) :
              SizedBox(
                height: h * 0.18,
                child: Column(
                  children: [
                    Text(controller.currentCity.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.white80,
                          fontSize: 20,
                          fontFamily: 'madaSemiBold'
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(controller.currentAddress.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.white80,
                            fontSize: 13,
                            fontFamily: 'madaSemiBold'
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                        onPressed: () async{
                          if(controller.isExisting){
                            navigateBack();
                          }else{
                            controller.navigateBack();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimaryColor,
                            fixedSize: Size(w / 1.1, 45),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            )
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pin_drop_rounded, color: Colors.white,),
                            SizedBox(width: 10,),
                            Text('Pin to this Location',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.white10,
                                  fontSize: 14,
                                  fontFamily: 'madaSemiBold'
                              ),
                            ),
                          ],
                        )
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget dummyTextField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateToPlaceSearch(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: AppColors.white30,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.white40)
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.kPrimaryColor,),
            SizedBox(width: 5,),
            Text('Search for area landmark',
              style: TextStyle(
                  color: AppColors.white50,
                  fontSize: 15,
                  fontFamily: 'madaRegular'
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderMap(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.white40, width: 1)
      ),
      height: MediaQuery
          .of(context)
          .size
          .height / 1.8,
      child: Obx(
              () =>
          controller.isLoading.value ?
          const SizedBox(
              width: 20,
              height: 20,
              child: Center(
                  child: CircularProgressIndicator())) :
          Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.currentLocation.value,
                  zoom: 18.0,
                ),
                markers: controller.markers,
                scrollGesturesEnabled: controller.dragDisabled.value,
                zoomGesturesEnabled: controller.dragDisabled.value,
                zoomControlsEnabled: controller.dragDisabled.value,
                myLocationEnabled: controller.dragDisabled.value,
                myLocationButtonEnabled: controller.dragDisabled.value,
                onMapCreated: (controller1) {
                  controller.setMapController(controller1);
                },
                onCameraIdle: controller.onCameraIdle,
                onCameraMove: controller.onCameraMove,
              ),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.22,
                  left: MediaQuery.of(context).size.width * 0.18,
                  right: MediaQuery.of(context).size.width * 0.22,
                  child: Image.asset(
                    'assets/images/map_pin_small.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  )
              )
            ],
          )
      ),
    );
  }

  void navigateToPlaceSearch(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationListScreen()),);

    if (result != null && result is Map<String, String>) {
      final latitudeStr = result['latitude'];
      final longitudeStr = result['longitude'];
      debugPrint(': longitude => $longitudeStr   </>  latitude => $latitudeStr');
      final latitude = double.tryParse(latitudeStr ?? '');
      final longitude = double.tryParse(longitudeStr ?? '');

      if (latitude != null && longitude != null) {
        controller.currentLocation.value = LatLng(latitude, longitude);
        controller.getAddressFromLatLng(controller.currentLocation.value);
        controller.updateLocation(controller.currentLocation.value);
        controller.update();
      } else {
        debugPrint('Error: Invalid latitude or longitude');
      }
    } else {
      debugPrint('Error: Result is null or not in the expected format');
    }
  }

  void navigateBack(){
    Map<String, String> payload = {
      'latitude': '${controller.currentLocation.value.latitude}',
      'longitude' : '${controller.currentLocation.value.longitude}',
      'address_model' : controller.currentAddress.value,
      'city' : controller.currentCity.value,
      'state' : controller.currentState.value,
      'country' : controller.currentCountry.value,
    };
    Get.back(result: payload);
  }

}