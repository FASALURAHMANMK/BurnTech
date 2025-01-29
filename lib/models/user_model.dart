class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final List<String>? campToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage,
    this.campToken,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'campToken': campToken,
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      campToken: map['campToken'] != null
          ? List<String>.from(map['campToken'])
          : null,
    );
  }
}
