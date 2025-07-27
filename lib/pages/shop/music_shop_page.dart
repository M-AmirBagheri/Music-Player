import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/theme_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../profile/profile_page.dart';
import 'shop_song_list_page.dart';

class MusicShopPage extends StatelessWidget {
  MusicShopPage({super.key});

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Iranian',
      'subtitle': 'Persian classics & pop',
      'image': 'assets/images/iran.jpg',
    },
    {
      'title': 'International',
      'subtitle': 'Global chart hits',
      'image': 'assets/images/international.jpg',
    },
    {
      'title': 'Local',
      'subtitle': 'Regional folk vibes',
      'image': 'assets/images/local.jpg',
    },
    {
      'title': 'New',
      'subtitle': 'Fresh new releases',
      'image': 'assets/images/new.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).currentTheme == ThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : const Color(0xFFFDF6EE);
    final searchBoxColor = isDark ? Colors.grey[850] : Colors.grey[200];

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Text('Hi, ', style: TextStyle(fontSize: 20, color: textColor)),
                      Text('Martha', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.menu, color: textColor),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search music',
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: searchBoxColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 24),
              Text('Genres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              SizedBox(
                height: 275,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopSongListPage(
                              category: category['title'],
                              songs: [],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
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
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.asset(
                                category['image'],
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                category['subtitle'],
                                style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.6)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                category['title'],
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
