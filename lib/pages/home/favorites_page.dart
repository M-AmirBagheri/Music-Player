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
  late List<SongModel> favorites;

  @override
  void initState() {
    super.initState();
    favorites = FavoritesService.instance.getFavorites();

    // گوش دادن به تغییر آهنگ فعلی برای به‌روزرسانی لیست
    audioManager.player.currentIndexStream.listen((index) {
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

    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final song = favorites[index];
        final isCurrent =
            audioManager.currentSong?.id == song.id &&
                audioManager.currentPlaylist == favorites;

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

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SongDetailPage(),
              ),
            );
          },
        );
      },
    );
  }
}
