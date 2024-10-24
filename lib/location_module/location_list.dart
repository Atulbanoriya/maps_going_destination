import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:maps_gomaps_api/util/app_colors.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  var h = 0.0;
  var w = 0.0;
  final apiKey = 'Your Maps API Key Here';
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> places = [];
  bool isLoading = false;
  bool addressTextLoading = false;
  String currentAddress = '';
  String latitude = '';
  String longitude = '';
  late LocationData locationData;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: w,
        height: h,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: h * 0.1,
              ),
              searchTextField(),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: (){
                  debugPrint('location===> ${locationData.longitude}   ${locationData.latitude}');
                  latitude =  '${locationData.latitude}';
                  longitude =  '${locationData.longitude}';
                  navigateBack();
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.my_location_rounded, color: AppColors.kPrimaryColor,),
                          const SizedBox(width: 10,),
                          SizedBox(
                            width: w/1.5                                                                                       ,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Use Current Location',
                                  style: TextStyle(
                                      color: AppColors.kPrimaryColor,
                                      fontSize: 15,
                                      fontFamily: 'madaRegular'
                                  ),
                                ),
                                Text(currentAddress,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.white60,
                                      fontSize: 15,
                                      fontFamily: 'madaRegular'
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      !addressTextLoading ? const SizedBox() :const SizedBox(width: 15, height : 15, child: CircularProgressIndicator(strokeWidth: 2,))
                    ],
                  ),
                ),
              ),
              Container(
                color: AppColors.white60,
                width: w,
                height: 0.5,
              ),
              const SizedBox(
                height: 10,
              ),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else places.isNotEmpty ?
              Expanded(
                  child: ListView.builder(
                    itemCount: places.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: ListTile(
                          title: Text(place['description'],
                            style: const TextStyle(
                                color: AppColors.white60,
                                fontSize: 15,
                                fontFamily: 'madaRegular'
                            ),
                          ),
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          leading: Image.asset('assets/images/map_pin_small.png', width: 25, height: 25,),
                          onTap: () async{
                            final details = await fetchPlaceDetails(place['place_id']);
                            // Handle place details
                            debugPrint('Latitude: ${details['latitude']}, Longitude: ${details['longitude']}');
                            latitude = '${details['latitude']}';
                            longitude = '${details['longitude']}';
                            navigateBack();
                          },
                          tileColor: Colors.white,
                        ),
                      );
                    },
                  )
              ) :
              const Center(
                child: Text('No Places Found',
                  style: TextStyle(
                      color: AppColors.white60,
                      fontSize: 15,
                      fontFamily: 'madaRegular'
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget searchTextField(){
    return TextFormField(
      controller: searchController,
      onChanged: (value) async {
        if (value.isNotEmpty) {
          setState(() {
            isLoading = true;
          });
          try {
            final fetchedPlaces = await fetchPlaces(value);
            setState(() {
              places.clear();
              places.addAll(fetchedPlaces);
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              isLoading = false;
            });
            // Handle error
          }
        } else {
          setState(() {
            places.clear();
          });
        }
      },
      decoration: InputDecoration(
          hintText: 'search for area, landmark',
          hintStyle: const TextStyle(
              color: AppColors.white50,
              fontSize: 15,
              fontFamily: 'madaRegular'
          ),
          filled: true,
          fillColor: AppColors.white30,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.white40, width: 1)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: AppColors.white40, width: 1)
          ),
          prefixIcon: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios)),
          suffixIcon: searchController.text.isEmpty ? null :
          SizedBox(
            height: 20,
            width: 20,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: (){},
                child: IconButton(
                  onPressed: (){
                    searchController.clear();
                    places.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close, color: Colors.white,),
                  iconSize: 13,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.kPrimaryColor,
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchPlaces(String query) async {
    const apiKey = 'AIzaSyA6v3dj_6xsKvzwTmF0F8J_OEg5JylaLFk'; // Replace with your API key
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List;

      return predictions.map<Map<String, dynamic>>((place) {
        return {
          'description': place['description'],
          'place_id': place['place_id']
        };
      }).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {

    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['result']['geometry']['location'];
      return {
        'latitude': geometry['lat'],
        'longitude': geometry['lng']
      };
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      addressTextLoading = true;
    });
    final location = Location();
    try {
      locationData = await location.getLocation();
      getAddressFromLatLng(LatLng(locationData.latitude!, locationData.longitude!));
    } catch (e) {
      setState(() {
        addressTextLoading = false;
      });
    }
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    setState(() {
      addressTextLoading = true;
    });
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        currentAddress = data['results'][0]['formatted_address'];
      } else {
        currentAddress = 'No address_model available';
      }
    } else {
      currentAddress = 'Failed to get address_model';
    }
    setState(() {
      addressTextLoading = false;
    });
  }

  void navigateBack(){
    Map<String, String> payload = {
      'latitude': latitude,
      'longitude' : longitude,
    };
    Navigator.pop(context, payload);
  }

}