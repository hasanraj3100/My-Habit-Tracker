class FavouriteQuoteModel {
  final String id;       // Firestore document ID
  final String text;
  final String author;

  FavouriteQuoteModel({
    required this.id,
    required this.text,
    required this.author,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'author': author,
    };
  }

  factory FavouriteQuoteModel.fromMap(Map<String, dynamic> map, String id) {
    return FavouriteQuoteModel(
      id: id,
      text: map['text'] ?? '',
      author: map['author'] ?? 'Unknown',
    );
  }
}
