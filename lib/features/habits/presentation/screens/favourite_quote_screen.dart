import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
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
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Quotes"),
        backgroundColor: colors.primary,
      ),
      backgroundColor: colors.background,
      body: StreamBuilder<List<FavouriteQuoteModel>>(
        stream: provider.favourites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No favourite quotes yet.",
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
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
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.1),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "- ${fav.author}",
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy, color: colors.secondary),
                        tooltip: "Copy quote",
                        onPressed: () => copyQuote(fav, context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colors.error),
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
    );
  }
}
