import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SelectLocationController extends GetxController{
  RxString selectedLocation = ''.obs;
  RxBool isTransactionFailed = false.obs;

  final captionController = TextEditingController();

  RxString latitude = ''.obs;
  RxString longitude = ''.obs;
  RxString state = ''.obs;
  RxString city = ''.obs;
  RxString country = ''.obs;
  RxString fullAddress = ''.obs;
  String userId = "";
}
