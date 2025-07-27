import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../../widgets/theme_provider.dart';

class MusicShopPage extends StatelessWidget {
  const MusicShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).currentTheme == ThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : const Color(0xFFFDF6EE);
    final cardColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بالای صفحه: سلام و منو
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.pinkAccent,
                        child: Icon(Icons.music_note, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hi, ',
                        style: TextStyle(fontSize: 20, color: textColor),
                      ),
                      Text(
                        'Martha',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                  Icon(Icons.menu, color: textColor),
                ],
              ),

              const SizedBox(height: 20),

              // سرچ باکس
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search music',
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),

              const SizedBox(height: 24),

              // عنوان لیست محبوب‌ها
              Text(
                'Popular',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 16),

              // لیست افقی آهنگ‌ها
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSongCard(
                      context,
                      imagePath: 'assets/images/violin.png', // آدرس تصویر محلی
                      title: 'Classic Hits',
                      subtitle: '30 songs for an acoustic afternoon',
                      cardColor: cardColor!,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 12),
                    _buildSongCard(
                      context,
                      imagePath: 'assets/images/guitar.png',
                      title: 'Acoustic Vibes',
                      subtitle: '30 songs for chilling',
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 12),
                    _buildSongCard(
                      context,
                      imagePath: 'assets/images/pop.png',
                      title: 'Pop Party',
                      subtitle: 'Feel good hits for your day',
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongCard(
      BuildContext context, {
        required String imagePath,
        required String title,
        required String subtitle,
        required Color cardColor,
        required Color textColor,
      }) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(2, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تصویر
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.6)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
