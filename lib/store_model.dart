class StoreModel {
  String? storeId;
  String? area;
  String? address;
  String? zipCode;
  String? storePhoneNum;
  String? country;
  int? vat;

  StoreModel(
      {this.storeId,
      this.area,
      this.address,
      this.zipCode,
      this.storePhoneNum,
      this.country,
      this.vat});

  factory StoreModel.fromMap(map) {
    return StoreModel(
        //uid: map['uid'],
        storeId: map["storeId"],
        area: map['area'],
        address: map['address'],
        zipCode: map['zipCode'],
        storePhoneNum: map['storePhoneNum'],
        country: map['country'],
        vat: map['vat']);
  }

  Map<String, dynamic> toMap() {
    return {
      //'uid': uid,
      'store_id': storeId,
      'areaName': area,
      'address': address,
      //'imageUrl': "",
      'zipCode': zipCode,
      'storePhoneNum': storePhoneNum,
      'country': country,
      'vat': vat,
    };
  }
}
