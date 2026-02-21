import 'dart:io';
import 'package:flutter/material.dart';
import '../../../ui/app_theme.dart';
import '../models/album_folder.dart';

class AlbumTile extends StatelessWidget {
  final AlbumFolder album;
  final VoidCallback onTap;

  const AlbumTile({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _CoverImage(path: album.coverImagePath),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                album.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${album.trackCount} tracks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? path;

  const _CoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return _fallback();
    }

    final file = File(path!);
    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    // Twardy, zawsze widoczny fallback:
    // - tło: surface2
    // - ramka: border
    // - ikona: text (jasna)
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