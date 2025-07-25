import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/audio_manager.dart';
import '../../services/favorites_service.dart';

class SongDetailPage extends StatefulWidget {
  final SongModel song;

  const SongDetailPage({super.key, required this.song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager.instance;

  late SongModel _currentSong;
  late Widget _artworkWidget;
  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffleModeEnabled = false;

  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.song;
    _artworkWidget = _buildArtwork(_currentSong);

    final player = _audioManager.player;

    // Update current song on index change
    _indexSubscription = player.currentIndexStream.listen((index) {
      final source = player.audioSource;
      if (index != null && source is ConcatenatingAudioSource && index < source.length) {
        final tag = (source.children[index] as UriAudioSource).tag;
        if (tag is SongModel) {
          setState(() {
            _currentSong = tag;
            _artworkWidget = _buildArtwork(_currentSong);
          });
        }
      }
    });

    _durationSubscription = player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });

    _positionSubscription = player.positionStream.listen((p) {
      setState(() => _position = p);
    });

    _animationController = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _indexSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  Widget _buildArtwork(SongModel song) {
    return QueryArtworkWidget(
      id: song.id,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: Container(
        color: Colors.grey.shade800,
        child: const Center(child: Icon(Icons.music_note, color: Colors.white, size: 100)),
      ),
    );
  }

  void _toggleRepeatMode() {
    setState(() {
      _loopMode = _loopMode == LoopMode.off ? LoopMode.one : LoopMode.off;
      _audioManager.player.setLoopMode(_loopMode);
    });
  }

  void _toggleShuffleMode() async {
    _isShuffleModeEnabled = !_isShuffleModeEnabled;
    await _audioManager.player.setShuffleModeEnabled(_isShuffleModeEnabled);
    setState(() {});
  }

  void _toggleFavorite() {
    FavoritesService.instance.toggleFavorite(_currentSong);
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final player = _audioManager.player;
    final isFavorite = FavoritesService.instance.isFavorite(_currentSong.id);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        elevation: 0,
        actions: const [
          Icon(Icons.share, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.equalizer, color: Colors.white),
          SizedBox(width: 8),
          Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Color.lerp(Colors.purple.withOpacity(0.08), Colors.deepPurple.withOpacity(0.12), _gradientAnimation.value)!,
                    ],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  SizedBox(height: 250, width: 250, child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _artworkWidget)),
                  const SizedBox(height: 20),
                  Text(_currentSong.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(_currentSong.artist ?? 'Unknown Artist', style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(Icons.queue_music, color: Colors.white),
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.purpleAccent : Colors.white),
                        onPressed: _toggleFavorite,
                      ),
                      const Icon(Icons.add, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                    onChanged: (value) => player.seek(Duration(seconds: value.toInt())),
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.white24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position), style: const TextStyle(color: Colors.white70)),
                      Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(icon: Icon(Icons.shuffle, color: _isShuffleModeEnabled ? Colors.purpleAccent : Colors.white), onPressed: _toggleShuffleMode),
                      IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32), onPressed: () => player.seekToPrevious()),
                      IconButton(
                        icon: Icon(player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 64),
                        onPressed: () => setState(() => player.playing ? player.pause() : player.play()),
                      ),
                      IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 32), onPressed: () => player.seekToNext()),
                      IconButton(
                        icon: Icon(_loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                            color: _loopMode == LoopMode.one ? Colors.purpleAccent : Colors.white),
                        onPressed: _toggleRepeatMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
