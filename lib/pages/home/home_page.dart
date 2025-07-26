import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../services/audio_manager.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../profile/profile_page.dart';
import '../profile/settings_page.dart';
import '../shop/song_detail_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _audioQuery = OnAudioQuery();
  final _searchController = TextEditingController();
  final _tabScrollController = ScrollController();
  final AudioManager _audioManager = AudioManager.instance;

  List<SongModel> _allSongs = [];
  bool _showSearch = false;
  bool _sortByName = true;

  late TabController _tabController;

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
      setState(() => _allSongs = songs);
    });

    _audioManager.addListener(_onAudioChange);
  }

  void _onAudioChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _audioManager.removeListener(_onAudioChange);
    _tabController.dispose();
    _searchController.dispose();
    _tabScrollController.dispose();
    super.dispose();
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Sort by Name"),
            onTap: () {
              setState(() => _sortByName = true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Sort by Time"),
            onTap: () {
              setState(() => _sortByName = false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Stack(
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
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Positioned(
          left: 0,
          top: 2,
          child: IconButton(icon: const Icon(Icons.unfold_more), onPressed: _showSortOptions),
        ),
      ],
    );
  }

  Widget _buildSongList() {
    final songs = _getFilteredSongs();
    final currentSong = _audioManager.currentSong;

    return ListView.separated(
      itemCount: songs.length,
      separatorBuilder: (context, index) => const Divider(indent: 72, endIndent: 12, height: 1),
      itemBuilder: (context, index) {
        final song = songs[index];
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
              color: isCurrent ? Theme.of(context).colorScheme.secondary : Theme.of(context).textTheme.bodyLarge!.color,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(song.artist ?? 'Unknown Artist'),
          onTap: () async {
            _audioManager.setPlaylist(songs);
            await _audioManager.playAtIndex(index);
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
        leading: const Icon(Icons.download_done),
        title: Text(downloaded[index]),
      ),
    );
  }

  Widget _buildAlbumsList() {
    final albums = List.generate(4, (i) => 'Album ${i + 1}');
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.album),
        title: Text(albums[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _audioManager.currentSong;
    final player = _audioManager.player;

    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentSong != null)
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
                    id: currentSong.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const Icon(Icons.music_note),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SongDetailPage()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentSong.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentSong.artist ?? 'Unknown Artist',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () => player.seekToPrevious(),
                  ),
                  IconButton(
                    icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      player.playing ? player.pause() : player.play();
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () => player.seekToNext(),
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
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: const [
                        TextSpan(
                          text: 'HICH ',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Music',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => setState(() => _showSearch = !_showSearch),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
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
                  decoration: InputDecoration(
                    hintText: 'Search music...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            _buildTabs(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
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
}
