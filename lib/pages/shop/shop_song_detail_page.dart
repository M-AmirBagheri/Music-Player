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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(song['title'], style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                song['image'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Text(song['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Text(song['artist'], style: TextStyle(fontSize: 16, color: secondaryColor)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber.shade400, size: 20),
                const SizedBox(width: 4),
                Text('${song['rating']}', style: TextStyle(color: textColor)),
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
            const SizedBox(height: 20),
            if (song['price'] == 'Free' && !isDownloaded)
              FilledButton(
                onPressed: _downloadSong,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                child: const Text("Download"),
              )
            else if (isDownloaded)
              Text("✅ Downloaded", style: TextStyle(color: Colors.green.shade300)),
            if (song['price'] != 'Free')
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentPage(song: song)),
                  );
                },
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                child: const Text("Buy Now"),
              ),

            const SizedBox(height: 30),
            Text("Your Rating:", style: TextStyle(color: textColor, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: userRating >= starIndex ? Colors.amber : Colors.grey.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      userRating = starIndex.toDouble();
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 30),
            Text("Leave a Comment:", style: TextStyle(color: textColor, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Write your comment...",
                hintStyle: TextStyle(color: secondaryColor),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submitComment,
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),

            if (comments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Comments:", style: TextStyle(color: textColor, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...comments.asMap().entries.map((entry) {
                    final i = entry.key;
                    final comment = entry.value;
                    return Card(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(comment['text'], style: TextStyle(color: textColor))),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.thumb_up, size: 20),
                                  color: secondaryColor,
                                  onPressed: () => _likeComment(i),
                                ),
                                Text('${comment['likes']}', style: TextStyle(color: textColor)),
                                IconButton(
                                  icon: const Icon(Icons.thumb_down, size: 20),
                                  color: secondaryColor,
                                  onPressed: () => _dislikeComment(i),
                                ),
                                Text('${comment['dislikes']}', style: TextStyle(color: textColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
