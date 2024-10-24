import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:maps_gomaps_api/util/app_routes.dart';
import '../location_module/location_select_binding.dart';
import '../location_module/location_select_screen.dart';


abstract class AppPages {
  const AppPages._();
  static final routes = [
    GetPage(
      name: Routes.locationSelect,
      page: () => const LocationSelectScreen(),
      binding: LocationSelectBinding(),
    ),
  ];
}
