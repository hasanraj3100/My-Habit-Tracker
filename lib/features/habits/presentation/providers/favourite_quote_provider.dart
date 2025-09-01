import 'package:flutter/material.dart';
import '../../data/favourite_quote_repository.dart';
import '../../data/models/favourite_quote_model.dart';

class FavouriteQuotesProvider extends ChangeNotifier {
  final FavouriteQuotesRepository _repository = FavouriteQuotesRepository();

  /// Stream of favourite quotes mapped to model
  Stream<List<FavouriteQuoteModel>> get favourites {
    return _repository.getFavourites().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FavouriteQuoteModel(
          id: doc.id,
          text: data['text'] ?? '',
          author: data['author'] ?? '',
        );
      }).toList();
    });
  }

  /// Add a favourite quote
  Future<void> addFavourite(String text, String author) async {
    await _repository.addFavourite(text, author);
  }

  /// Remove a favourite quote by ID
  Future<void> removeFavourite(String id) async {
    await _repository.deleteFavourite(id);
  }
}
