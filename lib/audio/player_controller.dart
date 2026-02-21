import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum HiFiRepeatMode { off, one, all }

class PlayerController {
  PlayerController._();
  static final PlayerController I = PlayerController._();

  final AudioPlayer _player = AudioPlayer();

  AlbumModel? _currentAlbum;
  List<SongModel> _queue = [];

  final ValueNotifier<bool> shuffleEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<HiFiRepeatMode> repeatMode =
      ValueNotifier<HiFiRepeatMode>(HiFiRepeatMode.off);

  AlbumModel? get currentAlbum => _currentAlbum;
  List<SongModel> get queue => List.unmodifiable(_queue);

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;

  bool get hasNext => _player.hasNext;
  bool get hasPrevious => _player.hasPrevious;

  SongModel? get currentSong {
    final idx = _player.currentIndex;
    if (idx == null) return null;
    if (idx < 0 || idx >= _queue.length) return null;
    return _queue[idx];
  }

  Future<void> playAlbum({
    required AlbumModel album,
    required List<SongModel> songs,
    int startIndex = 0,
  }) async {
    _currentAlbum = album;

    final filtered = <SongModel>[];
    final children = <AudioSource>[];

    for (final s in songs) {
      final u = (s.uri ?? '').trim();
      if (u.isEmpty) continue;
      filtered.add(s);
      children.add(AudioSource.uri(Uri.parse(u), tag: s));
    }

    _queue = filtered;

    if (children.isEmpty) {
      await _player.stop();
      return;
    }

    final source = ConcatenatingAudioSource(children: children);
    final safeIndex = startIndex.clamp(0, children.length - 1);

    await _player.setAudioSource(source, initialIndex: safeIndex);

    await _applyShuffle(shuffleEnabled.value);
    await _applyRepeat(repeatMode.value);

    await _player.play();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> seekToIndex(int index) => _player.seek(Duration.zero, index: index);

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  /// Alias dla kompatybilności (mini-player już woła previous()).
  Future<void> previous() => previousSmart();

  /// Klasyczne zachowanie "Previous":
  /// - jeśli jesteś >2s w utworze: cofka do 00:00
  /// - jeśli <=2s: przejście do poprzedniego (jeśli istnieje)
  Future<void> previousSmart() async {
    final pos = _player.position;
    if (pos > const Duration(seconds: 2)) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> setShuffle(bool enabled) async {
    shuffleEnabled.value = enabled;
    await _applyShuffle(enabled);
  }

  Future<void> cycleRepeat() async {
    final cur = repeatMode.value;
    final next = switch (cur) {
      HiFiRepeatMode.off => HiFiRepeatMode.all,
      HiFiRepeatMode.all => HiFiRepeatMode.one,
      HiFiRepeatMode.one => HiFiRepeatMode.off,
    };
    repeatMode.value = next;
    await _applyRepeat(next);
  }

  Future<void> _applyShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _player.shuffle();
    }
  }

  Future<void> _applyRepeat(HiFiRepeatMode mode) async {
    final loop = switch (mode) {
      HiFiRepeatMode.off => LoopMode.off,
      HiFiRepeatMode.one => LoopMode.one,
      HiFiRepeatMode.all => LoopMode.all,
    };
    await _player.setLoopMode(loop);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}