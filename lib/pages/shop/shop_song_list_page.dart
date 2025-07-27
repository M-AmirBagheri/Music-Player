import 'package:flutter/material.dart';
import 'shop_song_detail_page.dart';

class ShopSongListPage extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> songs;

  const ShopSongListPage({super.key, required this.category, required this.songs});

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Iranian':
        return Colors.purple.shade100;
      case 'International':
        return Colors.orange.shade100;
      case 'Local':
        return Colors.teal.shade100;
      case 'New':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCategoryColor(category);
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هدر بزرگ
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // دکمه بازگشت و آیکون‌ها
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.favorite_border),
                          SizedBox(width: 16),
                          Icon(Icons.download),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getCategoryTitle(category),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '30 songs to sing in the shower',
                    style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // لیست آهنگ‌ها
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(song['title'], style: TextStyle(color: textColor)),
                    subtitle: Text(song['artist'], style: TextStyle(color: textColor.withOpacity(0.7))),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ShopSongDetailPage(song: song)),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(String cat) {
    switch (cat) {
      case 'Iranian':
        return 'Persian Hits';
      case 'International':
        return 'Global Top Tracks';
      case 'Local':
        return 'Local Favorites';
      case 'New':
        return 'New Releases';
      default:
        return cat;
    }
  }
}
