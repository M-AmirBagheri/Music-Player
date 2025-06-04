import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/favorites_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
        );
      },
    );
  }
}