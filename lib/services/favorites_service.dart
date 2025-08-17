import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesService {
  FavoritesService._privateConstructor();
  static final FavoritesService _instance = FavoritesService._privateConstructor();
  static FavoritesService get instance => _instance;

  final Map<int, SongModel> _favorites = {};
  List<SongModel> _allSongs = [];

  void setAllSongs(List<SongModel> songs) {
    _allSongs = songs;
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_ids') ?? [];

    _favorites.clear();
    for (var id in ids) {
      final int songId = int.tryParse(id) ?? -1;
      final song = _allSongs.firstWhere(
            (s) => s.id == songId,
        orElse: () => SongModel({}),
      );
      if (song.data.isNotEmpty) {
        _favorites[songId] = song;
      }
    }
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (_favorites.containsKey(song.id)) {
      _favorites.remove(song.id);
    } else {
      _favorites[song.id] = song;
    }
    await _saveToPrefs();
  }

  bool isFavorite(int id) => _favorites.containsKey(id);

  List<SongModel> getFavorites() => _favorites.values.toList();

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _favorites.keys.map((id) => id.toString()).toList();
    await prefs.setStringList('favorite_ids', ids);
  }
}
