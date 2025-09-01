import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/quote_model.dart';
import 'dart:math';

class QuoteRepository {
  final _baseUrl = 'https://zenquotes.io/api/quotes';

  Future<List<QuoteModel>> fetchQuotes() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      // Check if the list has enough quotes, if not, return all available.
      int count = data.length < 5 ? data.length : 5;

      // Create a random number generator
      final random = Random();

      // Use a Set to store unique random indices
      final Set<int> randomIndices = {};
      while (randomIndices.length < count) {
        randomIndices.add(random.nextInt(data.length));
      }

      // Get the quotes at the random indices
      final List<QuoteModel> randomQuotes = randomIndices
          .map((index) => QuoteModel.fromJson(data[index]))
          .toList();

      return randomQuotes;
    } else {
      throw Exception('Failed to load quotes');
    }
  }
}