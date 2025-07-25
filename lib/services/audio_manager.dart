import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();

  factory AudioManager() => instance;

  AudioManager._internal();

  final AudioPlayer player = AudioPlayer();
  List<SongModel> currentPlaylist = [];

  void setPlaylist(List<SongModel> songs) {
    currentPlaylist = songs;
  }

  Future<void> playAtIndex(int index) async {
    final audioSources = currentPlaylist
        .map((song) => AudioSource.uri(Uri.parse(song.uri!), tag: song))
        .toList();

    await player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
      initialIndex: index,
    );

    await player.play();
  }

  SongModel? get currentSong {
    final index = player.currentIndex;
    if (index != null && index >= 0 && index < currentPlaylist.length) {
      return currentPlaylist[index];
    }
    return null;
  }
}
