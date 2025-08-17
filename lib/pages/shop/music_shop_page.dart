import 'dart:io';
import 'dart:convert';
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
  late Socket _socket;

  @override
  void initState() {
    super.initState();
    _connectToServer();  // Connect to server and fetch data
  }

  // Connect to the server using Socket
  Future<void> _connectToServer() async {
    try {
      _socket = await Socket.connect('172.20.10.3', 12345);
      print('Connected to server');

      // Listen for server responses
      _socket.listen((data) {
        String response = String.fromCharCodes(data);
        print('Received from server: $response');

        // Handle category data response
        if (response.startsWith('categories_response')) {
          var dataList = jsonDecode(response.substring(21)); // Extract JSON data
          setState(() {
            categories = List<Map<String, dynamic>>.from(dataList);
          });
        }

        // Handle Spotify genre data response
        if (response.startsWith('spotify_genres_response')) {
          var dataList = jsonDecode(response.substring(24)); // Extract JSON data
          setState(() {
            spotifyGenres = List<Map<String, String>>.from(dataList);
          });
        }
      });

      // Request category data from the server
      _socket.write('get_categories');

      // Request Spotify genre data from the server
      _socket.write('get_spotify_genres');
    } catch (e) {
      print('Error connecting to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server')),
      );
    }
  }

  @override
  void dispose() {
    _socket.close(); // Close the socket connection when leaving the page
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
