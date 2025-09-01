import 'package:flutter/material.dart';
import 'package:my_habit_tracker/core/extensions%20/theme_extension.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_theme_provider.dart';
import '../widgets/quote_section.dart';

class HabitHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool loading;

  const HabitHeader({
    super.key,
    required this.userData,
    required this.loading,
  });

  Widget _quoteSection() => const QuoteSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/header_bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay only for top bar area
          Container(
            height: 120, // adjust if needed (should cover buttons & greeting)
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54, // strong at very top
                  Colors.transparent, // fades out smoothly
                ],
              ),
            ),
          ),

          // Actual content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(.9),
                          child: Icon(Icons.person,
                              color: context.colors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Hello,",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            Text(
                              loading
                                  ? "..."
                                  : (userData?['nickname'] ?? "User"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return _roundIconButton(
                              themeProvider.isDarkMode
                                  ? Icons.light_mode   // show sun if dark mode is on
                                  : Icons.nightlight_round, // show moon if light mode
                              onPressed: () => themeProvider.toggleTheme(),
                            );
                          },
                        ),
                      ],
                    ),

                  ],
                ),
                const SizedBox(height: 28),
                _quoteSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _roundIconButton(IconData icon, {required VoidCallback onPressed}) {
  return Material(
    color: Colors.white.withOpacity(.25),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white),
      ),
    ),
  );
}
