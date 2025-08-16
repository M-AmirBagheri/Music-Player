import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../widgets/theme_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../profile/profile_page.dart';
import 'shop_song_list_page.dart';

class MusicShopPage extends StatefulWidget {
  const MusicShopPage({super.key});

  @override
  State<MusicShopPage> createState() => _MusicShopPageState();
}

class _MusicShopPageState extends State<MusicShopPage> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, String>> spotifyGenres = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromServer();
  }

  void _fetchDataFromServer() {
    // Connect to WebSocket
    AuthService().connect();

    // Listen to category data response
    AuthService().onEvent('categories_response', (data) {
      setState(() {
        categories = List<Map<String, dynamic>>.from(data);
      });
    });

    // Listen to Spotify genre data response
    AuthService().onEvent('spotify_genres_response', (data) {
      setState(() {
        spotifyGenres = List<Map<String, String>>.from(data);
      });
    });

    // Request category data from the server
    AuthService().emitEvent('get_categories', {});

    // Request Spotify genre data from the server
    AuthService().emitEvent('get_spotify_genres', {});
  }

  @override
  void dispose() {
    AuthService().disconnect(); // Disconnect WebSocket when leaving the page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).currentTheme == ThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : const Color(0xFFFDF6EE);
    final searchBoxColor = isDark ? Colors.grey[850] : Colors.grey[200];

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Search box
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

              // Categories section (linked to ShopSongListPage)
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
                              songs: category['songs'],
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

              const SizedBox(height: 24),

              // Spotify section (links to Spotify)
              Text('Spotify', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),

              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: spotifyGenres.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final genre = spotifyGenres[index];
                    return GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(genre['url']!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Container(
                        width: 155,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
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
                                genre['image']!,
                                height: 168,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                genre['title']!,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
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
