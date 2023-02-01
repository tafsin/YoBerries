class StoreSignUpModel {
  String? email;
  String? role;
  String? uid;
  String? storeId;
  String? country;

  StoreSignUpModel(
      {this.email, this.role, this.uid, this.storeId, this.country});

  factory StoreSignUpModel.fromMap(map) {
    return StoreSignUpModel(
        //uid: map['uid'],

        email: map['email'],
        role: map['role'],
        uid: map['uid'],
        storeId: map["storeId"],
        country: map['country']);
  }

  Map<String, dynamic> toMap() {
    return {
      //'uid': uid,
      // 'storeId': storeId,
      'email': email,
      'role': role,
      //'imageUrl': "",
      'uid': uid,
      'store_id': storeId,
      'country': country
    };
  }
}
