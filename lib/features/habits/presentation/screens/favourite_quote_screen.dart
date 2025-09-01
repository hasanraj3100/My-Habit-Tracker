import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/favourite_quote_model.dart';
import '../providers/favourite_quote_provider.dart';

class FavouriteQuotesPage extends StatelessWidget {
  const FavouriteQuotesPage({super.key});

  void copyQuote(FavouriteQuoteModel quote, BuildContext context) {
    final content = '"${quote.text}"\n- ${quote.author}';
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavouriteQuotesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Quotes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<FavouriteQuoteModel>>(
        stream: provider.favourites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No favourite quotes yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final favourites = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final fav = favourites[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  title: Text(
                    fav.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "- ${fav.author}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blueAccent),
                        tooltip: "Copy quote",
                        onPressed: () => copyQuote(fav, context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: "Remove from favourites",
                        onPressed: () {
                          provider.removeFavourite(fav.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
