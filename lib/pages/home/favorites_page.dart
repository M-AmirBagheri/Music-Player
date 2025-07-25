import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/favorites_service.dart';
import '../../services/audio_manager.dart';
import '../shop/song_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final audioManager = AudioManager.instance;
  List<SongModel> favorites = [];

  @override
  void initState() {
    super.initState();
    favorites = FavoritesService.instance.getFavorites();

    // Listen to song change and playback state
    audioManager.player.currentIndexStream.listen((_) {
      setState(() {});
    });
    audioManager.player.playingStream.listen((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No favorite songs yet.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final currentSong = audioManager.currentSong;

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final song = favorites[index];
        final isCurrent = currentSong?.id == song.id;

        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrent ? Colors.purpleAccent : Colors.white,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            song.artist ?? 'Unknown Artist',
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () async {
            audioManager.setPlaylist(favorites);
            await audioManager.playAtIndex(index);

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SongDetailPage(),
                ),
              );
            }
          },
        );
      },
    );
  }
}
