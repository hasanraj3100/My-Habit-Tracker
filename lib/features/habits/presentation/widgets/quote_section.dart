import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import '../providers/favourite_quote_provider.dart';
import '../providers/quote_provider.dart';

class QuoteSection extends StatelessWidget {
  const QuoteSection({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);

    if (quoteProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (quoteProvider.error != null) {
      return Center(child: Text('Error: ${quoteProvider.error}'));
    }

    if (quoteProvider.quotes.isEmpty) {
      return const Center(child: Text('No quotes available'));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: quoteProvider.quotes.map((quote) {
        return Builder(
          builder: (context) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '"${quote.text}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '- ${quote.author}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: '"${quote.text}" - ${quote.author}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied to clipboard")),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 20),
                          onPressed: () async {
                            try {
                              await Provider.of<FavouriteQuotesProvider>(context, listen: false)
                                  .addFavourite(quote.text, quote.author);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Added to favourites")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
