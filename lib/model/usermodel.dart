class UserModel {
  String uid;
  String name;
  String email;
  String address;
  String phone;


  UserModel({required this.uid, required this.name, required this.email,required this.address,required this.phone});

  factory UserModel.fromMap(String uid ,Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data["name"] ?? "No Name",
      email: data["email"] ?? "No Email",
      address: data["address"] ?? "No address",
      phone:data["phone"] ?? "No phonenumber"
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "address": address,
      "phone":phone
    };
  }
}