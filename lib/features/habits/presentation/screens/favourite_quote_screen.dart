import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/favourite_quote_model.dart';
import '../providers/favourite_quote_provider.dart';

class FavouriteQuotesPage extends StatelessWidget {
  const FavouriteQuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavouriteQuotesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Quotes"),
      ),
      body: StreamBuilder<List<FavouriteQuoteModel>>(
        stream: provider.favourites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No favourite quotes yet."));
          }

          final favourites = snapshot.data!;

          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final fav = favourites[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(fav.text),
                  subtitle: Text("- ${fav.author}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.removeFavourite(fav.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
