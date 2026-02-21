import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../ui/app_theme.dart';
import '../../widgets/mini_player_bar.dart';
import 'album_page.dart';
import 'services/media_store_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _media = MediaStoreService();
  Future<List<AlbumModel>>? _future;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final granted = await _media.requestPermission();
    if (!granted) {
      setState(() => _future = Future.value([]));
      return;
    }

    setState(() {
      _future = _media.getAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _init,
          )
        ],
      ),
      bottomNavigationBar: const MiniPlayerBar(),
      body: FutureBuilder<List<AlbumModel>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final albums = snap.data!;
          if (albums.isEmpty) {
            return const Center(child: Text('No albums found'));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: albums.length,
              itemBuilder: (context, i) {
                final album = albums[i];

                final artist = (album.artist ?? '').trim();
                final artistLabel =
                    artist.isEmpty || artist.toLowerCase() == '<unknown>'
                        ? 'Unknown artist'
                        : artist;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AlbumPage(album: album),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                color: AppTheme.surface2,
                                child: QueryArtworkWidget(
                                  id: album.id,
                                  type: ArtworkType.ALBUM,
                                  artworkFit: BoxFit.cover,
                                  artworkBorder: BorderRadius.zero,
                                  nullArtworkWidget: _fallbackArtwork(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                                  album.album,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
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
      child: const Icon(
        Icons.music_note,
        size: 56,
        color: AppTheme.text,
      ),
    );
  }
}