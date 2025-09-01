import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteQuotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get reference to current user's `favourite_quotes` subcollection
  CollectionReference<Map<String, dynamic>> _userFavouritesRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favourite_quotes');
  }

  /// Add a favourite quote
  Future<void> addFavourite(String text, String author) async {
    await _userFavouritesRef().add({
      'text': text,
      'author': author,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a favourite quote
  Future<void> deleteFavourite(String id) async {
    await _userFavouritesRef().doc(id).delete();
  }

  /// Stream all favourite quotes for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getFavourites() {
    return _userFavouritesRef()
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
