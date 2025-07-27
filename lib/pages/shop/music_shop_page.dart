import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../profile/profile_page.dart';
import 'shop_song_list_page.dart';

class MusicShopPage extends StatefulWidget {
  const MusicShopPage({super.key});

  @override
  State<MusicShopPage> createState() => _MusicShopPageState();
}

class _MusicShopPageState extends State<MusicShopPage> {
  final List<String> _categories = ['Iranian', 'International', 'Local', 'New'];
  final Map<String, List<Map<String, dynamic>>> _categorySongs = {
    'Iranian': [
      {
        'title': 'Bi To Mimiram',
        'artist': 'Mohsen Yeganeh',
        'rating': 4.5,
        'price': 'Free',
        'downloads': 1500,
        'image': 'https://picsum.photos/id/1011/200/200',
      },
      {
        'title': 'Gole Yakh',
        'artist': 'Ebi',
        'rating': 4.7,
        'price': '\$4.66',
        'downloads': 2200,
        'image': 'https://picsum.photos/id/1012/200/200',
      },
      {
        'title': 'To Ke Nisti',
        'artist': 'Sirvan Khosravi',
        'rating': 4.6,
        'price': '\$1.20',
        'downloads': 1700,
        'image': 'https://picsum.photos/id/1025/200/200',
      },
      {
        'title': 'Zendegi Ba To',
        'artist': 'Reza Sadeghi',
        'rating': 4.4,
        'price': 'Free',
        'downloads': 1400,
        'image': 'https://picsum.photos/id/1026/200/200',
      },
    ],
    'International': [
      {
        'title': 'Shape of You',
        'artist': 'Ed Sheeran',
        'rating': 4.9,
        'price': 'Free',
        'downloads': 5000,
        'image': 'https://picsum.photos/id/1013/200/200',
      },
      {
        'title': 'Stay',
        'artist': 'Justin Bieber',
        'rating': 4.8,
        'price': '\$2.23',
        'downloads': 4300,
        'image': 'https://picsum.photos/id/1014/200/200',
      },
    ],
    'Local': [
      {
        'title': 'Bandari Beat',
        'artist': 'Bandari Group',
        'rating': 4.3,
        'price': '\$0.84',
        'downloads': 800,
        'image': 'https://picsum.photos/id/1015/200/200',
      },
      {
        'title': 'Kordi Melody',
        'artist': 'Kurdish Folk',
        'rating': 4.0,
        'price': 'Free',
        'downloads': 1000,
        'image': 'https://picsum.photos/id/1016/200/200',
      },
    ],
    'New': [
      {
        'title': 'Space Vibes',
        'artist': 'Electro Boy',
        'rating': 4.6,
        'price': '\$1.37',
        'downloads': 2100,
        'image': 'https://picsum.photos/id/1018/200/200',
      },
      {
        'title': 'Future Flow',
        'artist': 'DJ Nova',
        'rating': 4.2,
        'price': 'Free',
        'downloads': 1700,
        'image': 'https://picsum.photos/id/1019/200/200',
      },
      {
        'title': 'Bassline Rise',
        'artist': 'Tronik',
        'rating': 4.3,
        'price': '\$0.79',
        'downloads': 1800,
        'image': 'https://picsum.photos/id/1020/200/200',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search music...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopSongListPage(
                            category: cat,
                            songs: _categorySongs[cat]!,
                          ),
                        ),
                      );
                    },
                    child: Chip(
                      label: Text(cat),
                      backgroundColor: theme.chipTheme.backgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
