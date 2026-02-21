import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerController {
  PlayerController._();
  static final PlayerController I = PlayerController._();

  final AudioPlayer player = AudioPlayer();

  int? _currentAlbumId;
  List<SongModel> _currentQueue = const [];

  int? get currentAlbumId => _currentAlbumId;
  List<SongModel> get currentQueue => _currentQueue;

  Future<void> playAlbum({
    required int albumId,
    required List<SongModel> songs,
    int startIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    _currentAlbumId = albumId;
    _currentQueue = songs;

    // Konwertujemy SongModel -> AudioSource (lokalne pliki)
    final sources = songs.map((s) {
      // `s.uri` zwykle jest content://... (MediaStore) – to jest OK.
      final uri = s.uri;
      if (uri == null || uri.isEmpty) {
        // Jeżeli trafi się pusty URI, pomijamy (bez crasha).
        return null;
      }
      return AudioSource.uri(
        Uri.parse(uri),
        tag: s,
      );
    }).whereType<AudioSource>().toList();

    if (sources.isEmpty) return;

    final playlist = ConcatenatingAudioSource(children: sources);

    await player.setAudioSource(
      playlist,
      initialIndex: startIndex.clamp(0, sources.length - 1),
      initialPosition: Duration.zero,
    );

    await player.play();
  }

  Future<void> playSongInAlbum({
    required int albumId,
    required List<SongModel> songs,
    required int songId,
  }) async {
    final index = songs.indexWhere((s) => s.id == songId);
    await playAlbum(albumId: albumId, songs: songs, startIndex: index < 0 ? 0 : index);
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> dispose() async {
    await player.dispose();
  }
}
