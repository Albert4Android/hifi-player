import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../audio/player_controller.dart';
import '../features/player/now_playing_page.dart';
import '../ui/app_theme.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: PlayerController.I.currentIndexStream,
      builder: (context, _) {
        final song = PlayerController.I.currentSong;
        if (song == null) return const SizedBox.shrink();

        final title = song.title;
        final artist = (song.artist ?? '').trim();
        final artistLabel =
            artist.isEmpty || artist.toLowerCase() == '<unknown>' ? 'Unknown artist' : artist;

        return SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: Material(
            color: AppTheme.surface,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Container(
                          color: AppTheme.surface2,
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            artworkFit: BoxFit.cover,
                            artworkBorder: BorderRadius.zero,
                            nullArtworkWidget: _fallback(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artistLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.textDim),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Kontrolki transportu (klasycznie: prev, play/pause, stop, next)
                    IconButton(
                      tooltip: 'Previous',
                      onPressed: PlayerController.I.hasPrevious ? PlayerController.I.previous : null,
                      icon: const Icon(Icons.skip_previous),
                    ),

                    StreamBuilder<bool>(
                      stream: PlayerController.I.playingStream,
                      builder: (context, snap) {
                        final playing = snap.data ?? false;
                        return IconButton(
                          tooltip: playing ? 'Pause' : 'Play',
                          onPressed: () =>
                              playing ? PlayerController.I.pause() : PlayerController.I.play(),
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        );
                      },
                    ),

                    IconButton(
                      tooltip: 'Stop',
                      onPressed: PlayerController.I.stop,
                      icon: const Icon(Icons.stop),
                    ),

                    IconButton(
                      tooltip: 'Next',
                      onPressed: PlayerController.I.hasNext ? PlayerController.I.next : null,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _fallback() {
    return Container(
      color: AppTheme.surface2,
      alignment: Alignment.center,
      child: const Icon(Icons.music_note, color: AppTheme.text),
    );
  }
}