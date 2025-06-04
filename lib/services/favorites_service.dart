import 'package:on_audio_query/on_audio_query.dart';

class FavoritesService {
  FavoritesService._privateConstructor();
  static final FavoritesService _instance = FavoritesService._privateConstructor();
  static FavoritesService get instance => _instance;

  final Map<int, SongModel> _favorites = {};

  void toggleFavorite(SongModel song) {
    if (_favorites.containsKey(song.id)) {
      _favorites.remove(song.id);
    } else {
      _favorites[song.id] = song;
    }
  }

  bool isFavorite(int id) => _favorites.containsKey(id);

  List<SongModel> getFavorites() => _favorites.values.toList();
}
