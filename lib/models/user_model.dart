  class UserModel {
    final String uid;
    final String name;
    final String email;
    final String? profileImage;
    final List<String>? favCamps;
    final List<String>? campTokens;
    final List<String>? favArts;
    final List<String>? artTokens;

    UserModel({
      required this.uid,
      required this.name,
      required this.email,
      required this.profileImage,
      required this.favCamps,
      required this.campTokens,
      required this.favArts,
      required this.artTokens,
    });

    Map<String, dynamic> toMap() {
      return {
        'uid': uid,
        'name': name,
        'email': email,
        'profileImage': profileImage,
        'favCamps': favCamps,
        'campTokens': campTokens,
        'favArts': favArts,
        'artTokens': artTokens,
      };
    }

    factory UserModel.fromMap(Map<String, dynamic> map) {
      return UserModel(
        uid: map['uid'],
        name: map['name'],
        email: map['email'],
        profileImage: map['profileImage'],
        favCamps:
            map['favCamps'] != null ? List<String>.from(map['favCamps']) : null,
        campTokens: map['campTokens'] != null
            ? List<String>.from(map['campTokens'])
            : null,
        favArts:
            map['favArts'] != null ? List<String>.from(map['favArts']) : null,
        artTokens:
            map['artTokens'] != null ? List<String>.from(map['artTokens']) : null,
      );
    }
  }
