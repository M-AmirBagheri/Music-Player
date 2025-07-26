import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/favorites_service.dart';
import '../../services/audio_manager.dart';

class SongDetailPage extends StatefulWidget {
  const SongDetailPage({super.key});

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager.instance;
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
    _currentSong = _audioManager.currentSong!;

    _audioManager.player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _audioManager.currentPlaylist.length) {
        setState(() {
          _currentSong = _audioManager.currentPlaylist[index];
          _artworkWidget = _buildArtwork(_currentSong);
        });
      }
    });

    _audioManager.player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });

    _audioManager.player.positionStream.listen((p) {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _artworkWidget = _buildArtwork(_currentSong);
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
        color: Theme.of(context).colorScheme.surface,
        child: const Center(
          child: Icon(Icons.music_note, size: 100),
        ),
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
          leading: BackButton(color: Theme.of(context).iconTheme.color),
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            IconButton(icon: const Icon(Icons.equalizer), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.surface,
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
                          Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                          Theme.of(context).colorScheme.primary.withOpacity(0.12),
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
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentSong.artist ?? 'Unknown Artist',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(Icons.queue_music),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Theme.of(context).colorScheme.secondary : null,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        const Icon(Icons.add),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                      onChanged: (value) {
                        final newPosition = Duration(seconds: value.toInt());
                        _audioManager.player.seek(newPosition);
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                      inactiveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position), style: Theme.of(context).textTheme.bodySmall),
                        Text(_formatDuration(_duration), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shuffle, color: _isShuffleModeEnabled ? Theme.of(context).colorScheme.secondary : null),
                          onPressed: _toggleShuffleMode,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous, size: 32),
                          onPressed: () => _audioManager.player.seekToPrevious(),
                        ),
                        IconButton(
                          icon: Icon(
                            _audioManager.player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            size: 64,
                          ),
                          onPressed: () {
                            _audioManager.player.playing ? _audioManager.pause() : _audioManager.play();
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, size: 32),
                          onPressed: () => _audioManager.player.seekToNext(),
                        ),
                        IconButton(
                          icon: Icon(
                            _loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                            color: _loopMode == LoopMode.one ? Theme.of(context).colorScheme.secondary : null,
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
