import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../util/app_colors.dart';

class LocationSelectController extends GetxController{
  Rx<LatLng> currentLocation = const LatLng( 0 , 0).obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  RxBool isLoading = true.obs;
  RxBool textLoading = true.obs;
  RxBool dragDisabled = false.obs;
  RxString currentAddress = ''.obs;
  RxString currentCity = ''.obs;
  RxString currentState = ''.obs;
  RxString currentCountry = ''.obs;
  Location location = Location();
  bool isExisting = false;
  final String apiKey = 'AIzaSyA6v3dj_6xsKvzwTmF0F8J_OEg5JylaLFk';

  GoogleMapController? mapController;


  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }


  void updateLocation(LatLng newLocation) {
    currentLocation.value = newLocation;
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(newLocation),
      );
    }
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      getCurrentLocation();
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      getCurrentLocation();
    } else if (status.isDenied) {
      _showPermissionDialog();
    } else if(status.isPermanentlyDenied){
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    var w = MediaQuery.of(Get.context!).size.width;
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        barrierDismissible: false,
        title: 'Location Permission Required',
        content: Text('This app requires location permission to function.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white70,
            fontFamily: 'madaRegular',
            fontSize: w*0.045,
          ),),
        confirm: ElevatedButton(
          onPressed: () async {
            Get.back();
            openAppSettings().then((val) => {
              if(val){
                _checkPermissions()
              }else{
                _requestPermission()
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(w * 0.07),
            ),
          ),
          child: Text('Request Permission',
            style: TextStyle(
              color: AppColors.white10,
              fontFamily: 'madaSemiBold',
              fontSize: w * 0.04,
            ),),
        ),
        cancel: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(w * 0.07),
                side: const BorderSide(
                    color: AppColors.kPrimaryColor
                )
            ),
          ),
          child: Text('Cancel',
            style: TextStyle(
              color: AppColors.kPrimaryColor,
              fontFamily: 'madaSemiBold',
              fontSize: w * 0.04,
            ),),
        ),
        middleTextStyle : TextStyle(
          color: AppColors.white100,
          fontFamily: 'madaRegular',
          fontSize: w*0.045,
        ),
        titleStyle: TextStyle(
          color: AppColors.white100,
          fontFamily: 'madaSemiBold',
          fontSize: w*0.05,
        )
    );
  }

  Future<void> getCurrentLocation() async {
    final locationData = await location.getLocation();
    currentLocation.value = LatLng(locationData.latitude!, locationData.longitude!);
    isLoading.value = false;
    getAddressFromLatLng(currentLocation.value);
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    textLoading.value = true;
    update();

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        final addressComponents = data['results'][0]['address_components'] as List;


        currentAddress.value = data['results'][0]['formatted_address'];

        String? city;
        String? state;
        String? country;

        for (var component in addressComponents) {
          final types = component['types'] as List<dynamic>;

          if (types.contains('locality')) {
            city = component['long_name'];
          } else if (types.contains('administrative_area_level_1')) {
            state = component['long_name'];
          } else if (types.contains('country')) {
            country = component['long_name'];
          }
        }

        // Assign the values to your reactive variables
        currentCity.value = city ?? 'City not found';
        currentState.value = state ?? 'State not found';
        currentCountry.value = country ?? 'Country not found';
      } else {
        currentAddress.value = 'No address_model available';
        currentCity.value = 'Failed to get city';
        currentState.value = 'Failed to get state';
        currentCountry.value = 'Failed to get country';
      }

      debugPrint('Current address_model: ${currentAddress.value}');
      textLoading.value = false;
    } else {
      currentAddress.value = 'Failed to get address_model';
      currentCity.value = 'Failed to get city';
      currentState.value = 'Failed to get state';
      currentCountry.value = 'Failed to get country';
    }

    update();
    if (kDebugMode) {
      print('longitude--------------->${currentLocation.value.longitude}\nlatitude--------------->${currentLocation.value.latitude}\naddress_model-------------------->$currentAddress\ncity------------------->$currentCity\nstate------------------>$currentState\ncountry------------------->$currentCountry');
    }
  }

  void updateMarker(LatLng newLocation) {
    currentLocation.value = newLocation;
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation.value,
      ),
    );
    getAddressFromLatLng(currentLocation.value);
  }

  void onCameraMove(CameraPosition position) {
    currentLocation.value = position.target;
  }

  void onCameraIdle() {
    getAddressFromLatLng(currentLocation.value);
  }



  void navigateBack(){
    Map<String, String> payload = {
      'address': currentAddress.value.toString(),
      'latitude': currentLocation.value.latitude.toString(),
      'longitude' : currentLocation.value.longitude.toString(),
      'city' : currentCity.value,
      'state' : currentState.value,
      "country": currentCountry.value,
    };
    Navigator.pop(Get.context!, payload);
  }
}