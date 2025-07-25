import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  late final AudioPlayer player;
  List<SongModel> _playlist = [];
  SongModel? _currentSong;
  int? _currentIndex;

  AudioManager._internal() {
    player = AudioPlayer();
    player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _playlist.length) {
        _currentIndex = index;
        _currentSong = _playlist[index];
      }
    });
  }

  SongModel? get currentSong => _currentSong;
  List<SongModel> get currentPlaylist => _playlist;

  Future<void> setPlaylist(List<SongModel> songs, {int initialIndex = 0}) async {
    _playlist = songs;
    _currentIndex = initialIndex;
    _currentSong = songs[initialIndex];
    final audioSources = songs.map((s) => AudioSource.uri(Uri.parse(s.uri!), tag: s)).toList();
    final playlist = ConcatenatingAudioSource(children: audioSources);
    await player.setAudioSource(playlist, initialIndex: initialIndex);
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    _currentSong = _playlist[index];
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  void dispose() {
    player.dispose();
  }
}
