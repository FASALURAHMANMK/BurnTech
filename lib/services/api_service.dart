import 'package:burn_tech/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveUserToFirestore(UserModel user) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
    // Or .update(...) if you only want to update existing fields
  } catch (e) {
    // Handle any errors
    print('Error saving user: $e');
  }
}
Future<UserModel?> getUserFromFirestore(String uid) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        return UserModel.fromMap(data);
      }
    }
    return null;
  } catch (e) {
    // Handle errors
    print('Error getting user: $e');
    return null;
  }
}
