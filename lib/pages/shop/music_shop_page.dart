import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../profile/profile_page.dart';
import 'shop_song_detail_page.dart';

class MusicShopPage extends StatefulWidget {
  const MusicShopPage({super.key});

  @override
  State<MusicShopPage> createState() => _MusicShopPageState();
}

class _MusicShopPageState extends State<MusicShopPage> {
  final List<String> _categories = ['Iranian', 'International', 'Local', 'New'];
  int _selectedCategoryIndex = 0;
  String _sortType = 'rating';
  String _searchQuery = '';

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

  List<Map<String, dynamic>> getFilteredAndSortedSongs() {
    final selectedCategory = _categories[_selectedCategoryIndex];
    List<Map<String, dynamic>> songs = List.from(_categorySongs[selectedCategory]!);

    if (_searchQuery.isNotEmpty) {
      songs = songs
          .where((song) =>
      song['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song['artist'].toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    songs.sort((a, b) {
      switch (_sortType) {
        case 'rating':
          return (b['rating'] as double).compareTo(a['rating']);
        case 'price':
          num getPrice(String price) {
            if (price.toLowerCase() == 'free') return 0;
            return num.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          }
          return getPrice(a['price']).compareTo(getPrice(b['price']));
        case 'downloads':
          return (b['downloads'] as int).compareTo(a['downloads']);
        default:
          return 0;
      }
    });

    return songs;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Sort by Rating'),
            onTap: () => setState(() {
              _sortType = 'rating';
              Navigator.pop(context);
            }),
          ),
          ListTile(
            title: const Text('Sort by Price'),
            onTap: () => setState(() {
              _sortType = 'price';
              Navigator.pop(context);
            }),
          ),
          ListTile(
            title: const Text('Sort by Downloads'),
            onTap: () => setState(() {
              _sortType = 'downloads';
              Navigator.pop(context);
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final songs = getFilteredAndSortedSongs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ChoiceChip(
                  label: Text(_categories[index]),
                  selected: _selectedCategoryIndex == index,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: const TextStyle(color: Colors.white),
                  onSelected: (_) => setState(() => _selectedCategoryIndex = index),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey,
                          child: const Icon(Icons.music_note),
                        ),
                      ),
                    ),
                    title: Text(song['title']),
                    subtitle: Text(
                      '${song['artist']} • ⭐ ${song['rating']} • ${song['downloads']} downloads',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      song['price'],
                      style: TextStyle(
                        color: song['price'] == 'Free' ? Colors.green : Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ShopSongDetailPage(song: song)),
                      );
                    },
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
