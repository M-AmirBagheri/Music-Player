
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../profile/settings_page.dart';
import '../profile/profile_page.dart';
import 'favorites_page.dart';
import '../shop/song_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  late TabController _tabController;
  final ScrollController _tabScrollController = ScrollController();
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  SongModel? _currentSong;

  List<SongModel> _allSongs = [];
  bool _sortByName = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      double screenWidth = MediaQuery.of(context).size.width;
      double offset = (_tabController.index * 100.0) - screenWidth / 2 + 50;
      _tabScrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });

    _audioQuery.permissionsStatus().then((status) async {
      if (!status) await _audioQuery.permissionsRequest();
      final songs = await _audioQuery.querySongs();
      setState(() {
        _allSongs = songs;
      });
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < _allSongs.length) {
        setState(() {
          _currentSong = _allSongs[index];
        });
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Sort by Name", style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _sortByName = true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Sort by Time", style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _sortByName = false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<SongModel> _getFilteredSongs() {
    List<SongModel> songs = [..._allSongs];
    if (_sortByName) {
      songs.sort((a, b) => a.title.compareTo(b.title));
    } else {
      songs.sort((a, b) => b.dateAdded!.compareTo(a.dateAdded!));
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      songs = songs.where((song) => song.title.toLowerCase().contains(query)).toList();
    }
    return songs;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    _searchController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentSong != null)
            Container(
              margin: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  QueryArtworkWidget(
                    id: _currentSong!.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SongDetailPage(song: _currentSong!, player: _audioPlayer),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentSong!.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _currentSong!.artist ?? 'Unknown Artist',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: () => _audioPlayer.seekToPrevious(),
                  ),
                  IconButton(
                    icon: Icon(_audioPlayer.playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    onPressed: () {
                      _audioPlayer.playing ? _audioPlayer.pause() : _audioPlayer.play();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: () => _audioPlayer.seekToNext(),
                  ),
                ],
              ),
            ),
          const BottomNavBar(currentIndex: 0),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Lato'),
                      children: [
                        TextSpan(text: 'ARAS ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(text: 'Music', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () => setState(() => _showSearch = !_showSearch),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'settings') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                          } else if (value == 'profile') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'settings', child: Text('Settings')),
                          PopupMenuItem(value: 'profile', child: Text('Profile')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search music...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            Stack(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(left: 48),
                  child: ListView(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    children: List.generate(_tabController.length, (index) {
                      final isSelected = _tabController.index == index;
                      final labels = ['Local Musics', 'Downloaded', 'Favorites', 'Albums'];
                      return GestureDetector(
                        onTap: () => setState(() => _tabController.animateTo(index)),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            labels[index],
                            style: TextStyle(color: isSelected ? Colors.purpleAccent : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 2,
                  child: IconButton(icon: const Icon(Icons.unfold_more, color: Colors.white), onPressed: _showSortOptions),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSongList(),
                    _buildDownloadedMusics(),
                    const FavoritesPage(),
                    _buildAlbumsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList() {
    final songs = _getFilteredSongs();
    return ListView.separated(
      itemCount: songs.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.white12,
        indent: 72,
        endIndent: 12,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrent = _currentSong?.id == song.id;

        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white),
          ),
          title: Text(
            song.title,
            style: TextStyle(color: isCurrent ? Colors.purpleAccent : Colors.white, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
          ),
          subtitle: Text(song.artist ?? 'Unknown Artist', style: const TextStyle(color: Colors.grey)),
          onTap: () async {
            _playlist.clear();
            _playlist.addAll(_getFilteredSongs().map((s) => AudioSource.uri(Uri.parse(s.uri!), tag: s)).toList());
            await _audioPlayer.setAudioSource(_playlist, initialIndex: index);
            _audioPlayer.play();
            setState(() {
              _currentSong = song;
            });
          },
        );
      },
    );
  }

  Widget _buildDownloadedMusics() {
    final downloaded = List.generate(4, (i) => 'Downloaded Music ${i + 1}');
    return ListView.builder(
      itemCount: downloaded.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.download_done, color: Colors.white),
        title: Text(downloaded[index], style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAlbumsList() {
    final albums = List.generate(4, (i) => 'Album ${i + 1}');
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.album, color: Colors.white),
        title: Text(albums[index], style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
