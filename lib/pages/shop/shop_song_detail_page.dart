import 'package:flutter/material.dart';
import '../payment/payment_page.dart';
import '../../services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchCommentsFromServer();
  }

  void _fetchCommentsFromServer() {
    // Connect to WebSocket
    AuthService().connect();

    // Listen for comment data response
    AuthService().onEvent('comments_response', (data) {
      setState(() {
        comments.clear();
        comments.addAll(List<Map<String, dynamic>>.from(data));
      });
    });

    // Request comments for this song
    AuthService().emitEvent('get_comments', {'song_id': widget.song['id']});
  }

  void _downloadSong() {
    setState(() => isDownloaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Download started...")),
    );
    // Send a request to the server to mark the song as downloaded
    AuthService().emitEvent('download_song', {'song_id': widget.song['id']});
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

    // Send the new comment to the server
    AuthService().emitEvent('submit_comment', {
      'song_id': widget.song['id'],
      'comment': _commentController.text.trim(),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Song Details"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    song['image'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(song['title'],
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(song['artist'], style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text('${song['rating']}', style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Price: ${song['price']}",
                  style: TextStyle(
                    color: song['price'] == 'Free' ? Colors.green : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),

                // Audio Bar (Mock)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("0:00"),
                          Expanded(
                            child: Slider(
                              value: 0.3,
                              onChanged: (_) {},
                              activeColor: Colors.purple,
                              inactiveColor: Colors.grey.shade300,
                            ),
                          ),
                          const Text("3:45"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Icon(Icons.skip_previous),
                          Icon(Icons.play_circle, size: 40),
                          Icon(Icons.skip_next),
                          Icon(Icons.volume_up),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    if (song['price'] == 'Free' && !isDownloaded)
                      FilledButton.icon(
                        onPressed: _downloadSong,
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                      ),
                    if (song['price'] != 'Free')
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PaymentPage(song: song)),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Buy Now"),
                      ),
                    OutlinedButton.icon(
                      onPressed: () {} ,
                      icon: const Icon(Icons.favorite_border),
                      label: const Text("Favorite"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {} ,
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // User Rating
                Column(
                  children: [
                    Text("Rate This Song", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => userRating = star.toDouble()),
                          icon: Icon(
                            Icons.star,
                            color: userRating >= star ? Colors.amber : Colors.grey.shade400,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Comments
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Comments", style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write your comment...",
                    filled: true,
                    fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitComment,
                    child: const Text("Submit Comment"),
                  ),
                ),
                const SizedBox(height: 20),
                if (comments.isEmpty)
                  Text("No comments yet. Be the first to comment!",
                      style: theme.textTheme.bodySmall),
                ...comments.map((c) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['text'], style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => c['likes']++),
                              icon: const Icon(Icons.thumb_up, size: 18),
                            ),
                            Text('${c['likes']}'),
                            IconButton(
                              onPressed: () => setState(() => c['dislikes']++),
                              icon: const Icon(Icons.thumb_down, size: 18),
                            ),
                            Text('${c['dislikes']}'),
                          ],
                        )
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
