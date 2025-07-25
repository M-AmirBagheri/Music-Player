import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._();
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  List<SongModel> _currentPlaylist = [];

  AudioManager._();

  AudioPlayer get player => _player;
  SongModel? get currentSong => _player.sequenceState?.currentSource?.tag as SongModel?;
  List<SongModel> get currentPlaylist => _currentPlaylist;

  void setPlaylist(List<SongModel> songs) {
    if (_currentPlaylist == songs) return;
    _currentPlaylist = songs;
    _playlist.clear();
    _playlist.addAll(
      songs.map((s) => AudioSource.uri(Uri.parse(s.uri!), tag: s)).toList(),
    );
    _player.setAudioSource(_playlist);
  }

  Future<void> playAtIndex(int index) async {
    if (_player.audioSource != _playlist) {
      await _player.setAudioSource(_playlist, initialIndex: index);
    } else {
      await _player.seek(Duration.zero, index: index);
    }
    _player.play();
  }
}
