import 'package:on_audio_query/on_audio_query.dart';

class MediaStoreService {
  final _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    return await _audioQuery.permissionsRequest();
  }

  Future<List<AlbumModel>> getAlbums() async {
    return await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }

  Future<List<SongModel>> getSongsFromAlbum(int albumId) async {
    // W tej wersji pluginu nie ma SongSortType.TRACK, więc:
    // - pobieramy listę bez TRACK sort
    // - sortujemy sami po polu track, a potem po tytule
    final songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID,
      albumId,
      sortType: SongSortType.TITLE, // bezpieczne i dostępne praktycznie zawsze
      orderType: OrderType.ASC_OR_SMALLER,
    );

    songs.sort((a, b) {
      final ta = a.track ?? 0;
      final tb = b.track ?? 0;
      if (ta != tb) return ta.compareTo(tb);
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return songs;
  }
}