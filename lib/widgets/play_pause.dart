import 'package:appo/providers/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final playProvider = StateProvider<ButtonState>((ref) {
  return ButtonState.paused;
});

class PlayPause extends ConsumerWidget {
  const PlayPause({
    Key? key,
    required this.mplayer,
  }) : super(key: key);

  final AudioPlayer mplayer;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final playState = watch(playProvider);
    final movePos = watch(positionProvider);
    mplayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playState.state = ButtonState.loading;
      } else if (!isPlaying) {
        playState.state = ButtonState.paused;
      } else {
        playState.state = ButtonState.playing;
      }
    });
    return Card(
      color: Colors.black,
      shape: CircleBorder(),
      child: IconButton(
        iconSize: movePos.state
                  ? 40
                  : 60,
        icon: playState.state == ButtonState.playing
            ? Icon(
                Icons.pause_rounded,
                color: Colors.white,
              )
            : playState.state == ButtonState.paused
                ? Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  )
                : CircularProgressIndicator(),
        onPressed: () {
          if (playState.state == ButtonState.playing) {
            mplayer.pause();
          } else if (playState.state == ButtonState.paused) {
            mplayer.play();
          }
        },
      ),
    );
  }
}

enum ButtonState {
  loading,
  paused,
  playing,
}
