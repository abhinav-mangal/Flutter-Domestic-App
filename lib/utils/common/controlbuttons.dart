import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      // color: Colors.red,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // IconButton(
          //   icon: const Icon(Icons.volume_up),
          //   onPressed: () {
          //     showSliderDialog(
          //       context: context,
          //       title: "Adjust volume",
          //       divisions: 10,
          //       min: 0.0,
          //       max: 1.0,
          //       stream: player.volumeStream,
          //       onChanged: player.setVolume,
          //     );
          //   },
          // ),
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
              ),
              onPressed: player.hasPrevious ? player.seekToPrevious : null,
            ),
          ),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(0),
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(
                    Icons.pause,
                    color: Colors.white,
                  ),
                  onPressed: player.pause,
                );
              } else {
                return SizedBox(width: 0);
                // return IconButton(
                //   icon: const Icon(Icons.replay),
                //   iconSize: 64.0,
                //   onPressed: () => player.seek(Duration.zero,
                //       index: player.effectiveIndices!.first),
                // );
              }
            },
          ),
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: Colors.white,
              ),
              onPressed: player.hasNext ? player.seekToNext : null,
            ),
          ),
          // StreamBuilder<double>(
          //   stream: player.speedStream,
          //   builder: (context, snapshot) => IconButton(
          //     icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
          //         style: const TextStyle(fontWeight: FontWeight.bold)),
          //     onPressed: () {
          //       showSliderDialog(
          //         context: context,
          //         title: "Adjust speed",
          //         divisions: 10,
          //         min: 0.5,
          //         max: 1.5,
          //         stream: player.speedStream,
          //         onChanged: player.setSpeed,
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
