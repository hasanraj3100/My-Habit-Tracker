import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/local_storage_service.dart';

class ProfileRepository {
  final String userId;

  ProfileRepository(this.userId);

  Future<Map<String, dynamic>?> fetchFromCacheOrFirestore() async {
    final cachedData = await LocalStorageService.getUserData();
    if (cachedData != null) return cachedData;
    return await fetchFromFirestore();
  }

  Future<Map<String, dynamic>?> fetchFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      if (data['date_of_birth'] is Timestamp) {
        data['date_of_birth'] =
            (data['date_of_birth'] as Timestamp).toDate().toIso8601String();
      }
      if (data['created_at'] is Timestamp) {
        data['created_at'] =
            (data['created_at'] as Timestamp).toDate().toIso8601String();
      }

      await LocalStorageService.saveUserData(data);
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile(Map<String, dynamic> updatedData) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update(updatedData);
    final cachedData = await fetchFromFirestore();
    if (cachedData != null) await LocalStorageService.saveUserData(cachedData);
  }
}
