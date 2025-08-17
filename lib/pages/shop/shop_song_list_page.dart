import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'shop_song_detail_page.dart';
import '../../widgets/theme_provider.dart';

class ShopSongListPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> songs;

  const ShopSongListPage({
    super.key,
    required this.category,
    required this.songs,
  });

  @override
  State<ShopSongListPage> createState() => _ShopSongListPageState();
}

class _ShopSongListPageState extends State<ShopSongListPage> {
  List<Map<String, dynamic>> songs = [];
  late Socket _socket;

  @override
  void initState() {
    super.initState();
    _connectToServer(); // Connect to server when page is loaded
  }

  // Connect to the server using Socket
  Future<void> _connectToServer() async {
    try {
      _socket = await Socket.connect('localhost', 12345);
      print('Connected to server');

      // Listen for server responses
      _socket.listen((data) {
        String response = String.fromCharCodes(data);
        print('Received from server: $response');

        // Handle songs data response
        if (response.startsWith('songs_response')) {
          var dataList = jsonDecode(response.substring(16)); // Extract JSON data
          setState(() {
            songs = List<Map<String, dynamic>>.from(dataList);
          });
        }
      });

      // Request songs data from the server
      _socket.write('get_songs_by_category;${widget.category}');
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

  String _getHeaderImage(String cat) {
    switch (cat) {
      case 'Iranian':
        return 'assets/images/header_iranian.png';
      case 'International':
        return 'assets/images/header_international.png';
      case 'Local':
        return 'assets/images/header_local.png';
      case 'New':
        return 'assets/images/header_new.png';
      default:
        return 'assets/images/header_default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with image
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryColor(widget.category),
                image: DecorationImage(
                  image: AssetImage(_getHeaderImage(widget.category)),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row with top icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.favorite_border, color: Colors.black87),
                            SizedBox(width: 16),
                            Icon(Icons.download, color: Colors.black87),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Song List section
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
                    title: Text(song['title'], style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
                    subtitle: Text(
                      song['artist'],
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color?.withOpacity(0.7)),
                    ),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopSongDetailPage(song: song),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
