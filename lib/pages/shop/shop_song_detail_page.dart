import 'package:flutter/material.dart';
import '../payment/payment_page.dart';

class ShopSongDetailPage extends StatefulWidget {
  final Map<String, dynamic> song;

  const ShopSongDetailPage({super.key, required this.song});

  @override
  State<ShopSongDetailPage> createState() => _ShopSongDetailPageState();
}

class _ShopSongDetailPageState extends State<ShopSongDetailPage> {
  double userRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> comments = [];

  bool isDownloaded = false;

  void _downloadSong() {
    setState(() {
      isDownloaded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Download started...")),
    );
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      comments.add({
        'text': _commentController.text.trim(),
        'likes': 0,
        'dislikes': 0,
      });
      _commentController.clear();
    });
  }

  void _likeComment(int index) {
    setState(() {
      comments[index]['likes']++;
    });
  }

  void _dislikeComment(int index) {
    setState(() {
      comments[index]['dislikes']++;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(song['title'], style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  song['image'],
                  height: 220,
                  width: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    width: 220,
                    color: Colors.grey,
                    child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(song['title'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(song['artist'], style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text('${song['rating']}', style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Price: ${song['price']}',
                style: TextStyle(
                  fontSize: 18,
                  color: song['price'] == 'Free' ? Colors.green : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (song['price'] == 'Free' && !isDownloaded)
                ElevatedButton(
                  onPressed: _downloadSong,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text("Download"),
                )
              else if (isDownloaded)
                const Text("✅ Downloaded", style: TextStyle(color: Colors.greenAccent)),

              if (song['price'] != 'Free')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PaymentPage(song: song)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text("Buy Now"),
                ),
              const SizedBox(height: 24),
              const Text("Your Rating:", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: userRating >= starIndex ? Colors.amber : Colors.white24,
                    ),
                    onPressed: () {
                      setState(() {
                        userRating = starIndex.toDouble();
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 24),
              const Text("Leave a Comment:", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Write your comment...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitComment,
                child: const Text("Submit Comment"),
              ),
              const SizedBox(height: 16),

              if (comments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Comments:", style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...comments.asMap().entries.map((entry) {
                      final i = entry.key;
                      final comment = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text("- ${comment['text']}", style: const TextStyle(color: Colors.white70)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.thumb_up, color: Colors.white54, size: 20),
                              onPressed: () => _likeComment(i),
                            ),
                            Text('${comment['likes']}', style: const TextStyle(color: Colors.white70)),
                            IconButton(
                              icon: const Icon(Icons.thumb_down, color: Colors.white54, size: 20),
                              onPressed: () => _dislikeComment(i),
                            ),
                            Text('${comment['dislikes']}', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
