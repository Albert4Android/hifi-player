import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../ui/app_theme.dart';
import '../../audio/player_controller.dart';
import '../../widgets/mini_player_bar.dart';
import 'services/media_store_service.dart';

class AlbumPage extends StatefulWidget {
  final AlbumModel album;

  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final _media = MediaStoreService();
  Future<List<SongModel>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _media.getSongsFromAlbum(widget.album.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final artist = (widget.album.artist ?? '').trim();
    final artistLabel =
        artist.isEmpty || artist.toLowerCase() == '<unknown>' ? 'Unknown artist' : artist;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.album),
      ),
      bottomNavigationBar: const MiniPlayerBar(),
      body: FutureBuilder<List<SongModel>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final songs = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            color: AppTheme.surface2,
                            child: QueryArtworkWidget(
                              id: widget.album.id,
                              type: ArtworkType.ALBUM,
                              artworkFit: BoxFit.cover,
                              artworkBorder: BorderRadius.zero,
                              nullArtworkWidget: _fallbackArtwork(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        artistLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDim,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.album.album,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${songs.length} tracks',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: songs.isEmpty
                                  ? null
                                  : () async {
                                      await PlayerController.I.playAlbum(
                                        album: widget.album,
                                        songs: songs,
                                        startIndex: 0,
                                      );
                                    },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: songs.isEmpty
                                  ? null
                                  : () async {
                                      final start = (songs.length <= 1)
                                          ? 0
                                          : (DateTime.now().microsecondsSinceEpoch % songs.length);
                                      await PlayerController.I.playAlbum(
                                        album: widget.album,
                                        songs: songs,
                                        startIndex: start,
                                      );
                                    },
                              icon: const Icon(Icons.shuffle),
                              label: const Text('Shuffle'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(songs.length, (i) {
                final s = songs[i];
                final trackNo = s.track;
                final title = s.title;

                return Column(
                  children: [
                    ListTile(
                      leading: Text(
                        trackNo == null ? '${i + 1}' : '$trackNo',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textDim),
                      ),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        (s.artist ?? '').isEmpty ? artistLabel : (s.artist ?? artistLabel),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await PlayerController.I.playAlbum(
                          album: widget.album,
                          songs: songs,
                          startIndex: i,
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  static Widget _fallbackArtwork() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.music_note, size: 56, color: AppTheme.text),
    );
  }
}