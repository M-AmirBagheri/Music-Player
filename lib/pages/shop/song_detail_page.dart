import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/favorites_service.dart';
import '../../services/audio_manager.dart';

class SongDetailPage extends StatefulWidget {
  final SongModel song;

  const SongDetailPage({super.key, required this.song});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> with SingleTickerProviderStateMixin {
  final audioManager = AudioManager.instance;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late SongModel _currentSong;
  late Widget _artworkWidget;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffleModeEnabled = false;

  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _currentSong = widget.song;
    _artworkWidget = _buildArtwork(_currentSong);

    audioManager.player.currentIndexStream.listen((index) {
      final source = audioManager.player.audioSource;
      if (index != null && source is ConcatenatingAudioSource && index < source.children.length) {
        final audioSource = source.children[index];
        if (audioSource is UriAudioSource && audioSource.tag is SongModel) {
          setState(() {
            _currentSong = audioSource.tag as SongModel;
            _artworkWidget = _buildArtwork(_currentSong);
          });
        }
      }
    });

    audioManager.player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });

    audioManager.player.positionStream.listen((p) {
      setState(() => _position = p);
    });

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildArtwork(SongModel song) {
    return QueryArtworkWidget(
      id: song.id,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white, size: 100),
        ),
      ),
    );
  }

  void _toggleRepeatMode() {
    setState(() {
      _loopMode = _loopMode == LoopMode.off ? LoopMode.one : LoopMode.off;
      audioManager.player.setLoopMode(_loopMode);
    });
  }

  void _toggleShuffleMode() async {
    _isShuffleModeEnabled = !_isShuffleModeEnabled;
    await audioManager.player.setShuffleModeEnabled(_isShuffleModeEnabled);
    setState(() {});
  }

  void _toggleFavorite() {
    setState(() {
      FavoritesService.instance.toggleFavorite(_currentSong);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = FavoritesService.instance.isFavorite(_currentSong.id);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: BackButton(color: Colors.white),
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
            const SizedBox(width: 1),
            IconButton(icon: const Icon(Icons.equalizer, color: Colors.white), onPressed: () {}),
            const SizedBox(width: 1),
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
            const SizedBox(width: 1),
          ],
        ),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Color(0xFF121212),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _gradientAnimation,
              builder: (context, child) {
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color.lerp(
                          const Color(0xFF7F00FF).withOpacity(0.08),
                          const Color(0xFF4A00E0).withOpacity(0.12),
                          _gradientAnimation.value,
                        )!,
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
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _artworkWidget,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _currentSong.title,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentSong.artist ?? 'Unknown Artist',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(Icons.queue_music, color: Colors.white),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.purpleAccent : Colors.white,
                          ),
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
                      onChanged: (value) {
                        final newPosition = Duration(seconds: value.toInt());
                        audioManager.player.seek(newPosition);
                      },
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
                        IconButton(
                          icon: Icon(Icons.shuffle, color: _isShuffleModeEnabled ? Colors.purpleAccent : Colors.white),
                          onPressed: _toggleShuffleMode,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                          onPressed: () => audioManager.player.seekToPrevious(),
                        ),
                        IconButton(
                          icon: Icon(
                            audioManager.player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 64,
                          ),
                          onPressed: () {
                            audioManager.player.playing ? audioManager.player.pause() : audioManager.player.play();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                          onPressed: () => audioManager.player.seekToNext(),
                        ),
                        IconButton(
                          icon: Icon(
                            _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                            color: _loopMode == LoopMode.one ? Colors.purpleAccent : Colors.white,
                          ),
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
      ),
    );
  }
}
