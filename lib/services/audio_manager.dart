import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager instance = AudioManager._internal();

  final AudioPlayer player = AudioPlayer();
  List<SongModel> _playlist = [];
  SongModel? _currentSong;

  AudioManager._internal() {
    player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _playlist.length) {
        _currentSong = _playlist[index];
        notifyListeners();
      }
    });

    player.playingStream.listen((_) {
      notifyListeners();
    });
  }

  SongModel? get currentSong => _currentSong;
  List<SongModel> get currentPlaylist => _playlist;

  void setPlaylist(List<SongModel> songs) {
    _playlist = songs;
    final audioSources = songs
        .map((s) => AudioSource.uri(Uri.parse(s.uri!), tag: s))
        .toList();
    player.setAudioSource(ConcatenatingAudioSource(children: audioSources));
  }

  Future<void> playAtIndex(int index) async {
    if (_playlist.isEmpty || index >= _playlist.length) return;

    final audioSources = _playlist
        .map((s) => AudioSource.uri(Uri.parse(s.uri!), tag: s))
        .toList();

    await player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
      initialIndex: index,
    );
    _currentSong = _playlist[index];
    await player.play();
    notifyListeners();
  }

  void play() {
    player.play();
    notifyListeners();
  }

  void pause() {
    player.pause();
    notifyListeners();
  }
}
