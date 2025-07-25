import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/favorites_service.dart';
import '../shop/song_detail_page.dart'; // مسیر song_detail_page را تنظیم کن

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final AudioPlayer _player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesService.instance.getFavorites();

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
        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(song.artist ?? 'Unknown Artist', style: const TextStyle(color: Colors.grey)),
          onTap: () async {
            await _player.setAudioSource(
              ConcatenatingAudioSource(
                children: favorites
                    .map((s) => AudioSource.uri(Uri.parse(s.uri!), tag: s))
                    .toList(),
              ),
              initialIndex: index,
            );
            await _player.play();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SongDetailPage(
                  song: song,
                  player: _player,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
