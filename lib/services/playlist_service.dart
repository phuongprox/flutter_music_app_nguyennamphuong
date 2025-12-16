import 'package:on_audio_query/on_audio_query.dart' as oq;
import '../models/song_model.dart';

class PlaylistService {
  final oq.OnAudioQuery _audioQuery = oq.OnAudioQuery();
  Future<List<SongModel>> getAllSongs() async {
    try {
      final List<oq.SongModel> audioList = await _audioQuery.querySongs(
        sortType: oq.SongSortType.TITLE,
        orderType: oq.OrderType.ASC_OR_SMALLER,
        uriType: oq.UriType.EXTERNAL,
        ignoreCase: true,
      );

      return audioList.map((audio) => SongModel.fromAudioQuery(audio)).toList();
    } catch (e) {
      throw Exception('Failed to load songs from device: $e');
    }
  }

  Future<List<SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  Future<List<SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();

    return allSongs.where((song) {
      final titleMatch = song.title.toLowerCase().contains(lowerQuery);
      final artistMatch = song.artist.toLowerCase().contains(lowerQuery);
      final albumMatch =
          song.album?.toLowerCase().contains(lowerQuery) ?? false;

      return titleMatch || artistMatch || albumMatch;
    }).toList();
  }
}
