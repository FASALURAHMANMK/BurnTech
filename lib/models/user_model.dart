class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final List<String>? favCamps;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.favCamps,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'favCamps': favCamps,
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      favCamps: map['favCamps'] != null
          ? List<String>.from(map['favCamps'])
          : null,
    );
  }
}
