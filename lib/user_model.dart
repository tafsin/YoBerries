class UserModel {
  String? email;
  String? role;
  String? uid;
  String? name;
  String? imageUrl;
  String? phoneNumber;
  String? country;

  UserModel(
      {this.uid,
      this.email,
      this.role,
      this.name,
      this.phoneNumber,
      this.country});

  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map["userEmail"],
        role: map['role'],
        name: map['userName'],
        phoneNumber: map['userPhoneNumber'],
        country: map['country']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userEmail': email,
      'role': role,
      'userName': name,
      'imageUrl': "",
      'userPhoneNumber': phoneNumber,
      'country': country,
      'reward_point': 0,
      'balance': 0,
      'defaultPaymentMethod': 'YoBerries Wallet'
    };
  }
}
