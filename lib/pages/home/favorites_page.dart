import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/audio_manager.dart';
import '../../services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final AudioManager _audioManager = AudioManager.instance;

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = FavoritesService.instance.getFavorites();
    final currentSong = _audioManager.currentSong;

    if (favoriteSongs.isEmpty) {
      return const Center(child: Text('No favorites yet.'));
    }

    return ListView.separated(
      itemCount: favoriteSongs.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.shade400,
        indent: 72,
        endIndent: 12,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final song = favoriteSongs[index];
        final isCurrent = currentSong?.id == song.id;

        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(Icons.music_note),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrent
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).textTheme.bodyLarge!.color,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            song.artist ?? 'Unknown Artist',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.6),
            ),
          ),
          onTap: () async {
            _audioManager.setPlaylist(favoriteSongs);
            await _audioManager.playAtIndex(index);
            setState(() {});
          },
        );
      },
    );
  }
}
