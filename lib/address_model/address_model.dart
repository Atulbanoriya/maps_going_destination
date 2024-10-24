class AddressModel {
  bool? success;
  String? message;
  Data? data;

  AddressModel({this.success, this.message, this.data});

  AddressModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? email;
  String? roleType;
  String? address;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? country;
  String? label;
  String? image;
  String? deviceToken;
  String? referralCode;
  String? totalWalletAmount;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.name,
        this.email,
        this.roleType,
        this.address,
        this.latitude,
        this.longitude,
        this.city,
        this.state,
        this.country,
        this.label,
        this.image,
        this.deviceToken,
        this.referralCode,
        this.totalWalletAmount,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    roleType = json['role_type'].toString();
    address = json['address'];
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    city = json['city'];
    state = json['state'];
    country = json['country'];
    label = json['label'];
    image = json['image'];
    deviceToken = json['device_token'];
    referralCode = json['referral_code'];
    totalWalletAmount = json['total_wallet_amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['role_type'] = roleType;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['label'] = label;
    data['image'] = image;
    data['device_token'] = deviceToken;
    data['referral_code'] = referralCode;
    data['total_wallet_amount'] = totalWalletAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
