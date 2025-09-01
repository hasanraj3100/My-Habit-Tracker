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
        height: 160,
        enlargeCenterPage: true,
        autoPlay: true,
        viewportFraction: 0.85,
      ),
      items: quoteProvider.quotes.map((quote) {
        return Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Colors.black54, // top semi-transparent
                    Colors.black26, // middle fade
                    Colors.transparent, // bottom transparent
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Author at top right
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '- ${quote.author}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Quote text centered
                    Expanded(
                      child: Center(
                        child: Text(
                          '"${quote.text}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Buttons at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: Colors.white),
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
                          icon: const Icon(Icons.favorite_border, size: 20, color: Colors.white),
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
