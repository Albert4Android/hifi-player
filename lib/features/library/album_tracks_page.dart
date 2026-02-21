import 'package:flutter/material.dart';
import 'models/album_folder.dart';

class AlbumTracksPage extends StatelessWidget {
  final AlbumFolder album;

  const AlbumTracksPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: album.tracks.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final fullPath = album.tracks[index];
          final name = _fileName(fullPath);

          return ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
            // NIE pokazujemy ścieżki (Twoje wymaganie).
            onTap: () {
              // W kolejnym kroku podepniemy tu odtwarzanie i kolejkę.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Play: w następnym kroku.')),
              );
            },
          );
        },
      ),
    );
  }

  String _fileName(String path) {
    final p = path.replaceAll('\\', '/');
    final i = p.lastIndexOf('/');
    if (i < 0) return p;
    return p.substring(i + 1);
  }
}
