import 'package:flutter/material.dart';
import '../../data/models/quote_model.dart';
import '../../data/quote_repository.dart';

class QuoteProvider with ChangeNotifier {
  final QuoteRepository _repository = QuoteRepository();
  List<QuoteModel> _quotes = [];
  bool _isLoading = false;
  String? _error;

  List<QuoteModel> get quotes => _quotes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQuotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _quotes = await _repository.fetchQuotes();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
