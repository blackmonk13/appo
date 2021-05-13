import 'dart:io';

import 'package:appo/constants.dart';
import 'package:appo/providers/common.dart';
import 'package:appo/providers/music_p.dart';
import 'package:appo/widgets/play_pause.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:hexcolor/hexcolor.dart';

class APlayer extends ConsumerWidget {
  const APlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final timePassed = watch(timeProvider);
    final currentSong = watch(currentSongProvider);
    final myMusic = watch(songsFutureProvider);
    final mplayer = watch(audioPlayerProvider);
    final currentProgress = watch(currentProgressProvider);
    final movePos = watch(positionProvider);
    return Scaffold(
      backgroundColor: lavender,
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 240,
              child: AnimatedOpacity(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                opacity: movePos.state ? 1 : 0,
                child: Container(
                  // color: Colors.red,
                  width: MediaQuery.of(context).size.width * .9,
                  height: 320,
                  child: Column(
                    children: [
                      myMusic.when(
                        data: (songList) {
                          songList = songList
                              .where((element) => element.isMusic ?? false)
                              .toList();
                          try {
                            if (currentSong.state == null) {
                              currentSong.state = songList.first;
                            }
                          } catch (e) {}

                          return Expanded(
                            child: ListView.builder(
                              itemCount: songList.length,
                              itemBuilder: (BuildContext context, int index) {
                                SongInfo song = songList[index];

                                Widget artwork = getArtwork(song);
                                return Card(
                                  elevation: 0,
                                  color: lavender,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: artwork,
                                    ),
                                    title: Text(song.title!),
                                    subtitle: Text(song.artist!),
                                    onTap: () async {
                                      currentSong.state = song;
                                      var duration = await mplayer
                                          .setFilePath(song.filePath!);
                                      mplayer.positionStream.listen(
                                        (position) {
                                          // final oldState = currentProgress.state;
                                          currentProgress.state = position;
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => CircularProgressIndicator(),
                        error: (e, s) => Text("Error"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              top: movePos.state ? -250 : -40,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              child: GestureDetector(
                onVerticalDragStart: (dragDetails) {
                  movePos.state = !movePos.state;
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(300),
                      bottomRight: Radius.circular(300),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HexColor("#09203f"),
                          HexColor("#537895"),
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * .7,
                    height: MediaQuery.of(context).size.height * .75,
                    child: getArtwork(currentSong.state, shim: true),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {},
              ),
            ),
            Positioned(
              top: 20,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.menu_rounded),
                onPressed: () {},
              ),
            ),
            AnimatedPositioned(
              top: movePos.state
                  ? MediaQuery.of(context).size.height * -.03
                  : MediaQuery.of(context).size.height * .3,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              child: AnimatedOpacity(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                opacity: movePos.state ? 0 : 1,
                child: GestureDetector(
                  onVerticalDragStart: (dragDetails) {
                    movePos.state = !movePos.state;
                  },
                  child: SleekCircularSlider(
                    min: 0,
                    max: getMaxDuration(currentSong.state),
                    initialValue: currentProgress.state.inSeconds.toDouble(),
                    appearance: CircularSliderAppearance(
                      startAngle: 160,
                      angleRange: 140,
                      counterClockwise: true,
                      size: MediaQuery.of(context).size.width * .8,
                      customWidths: CustomSliderWidths(
                        trackWidth: 4,
                        progressBarWidth: 6,
                        handlerSize: 10,
                      ),
                      customColors: CustomSliderColors(
                        progressBarColor: Colors.black,
                        trackColor: lightGray,
                        dotColor: Colors.black,
                      ),
                      infoProperties: InfoProperties(
                        topLabelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 25.00,
                            fontWeight: FontWeight.w400),
                        topLabelText: currentSong.state != null
                            ? currentSong.state!.title
                            : null,
                        bottomLabelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w100),
                        bottomLabelText: printDuration(currentProgress.state),
                        mainLabelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w300),
                        modifier: (double value) {
                          String ssongtitle = currentSong.state!.artist ?? '';
                          return ssongtitle;
                        },
                      ),
                    ),
                    onChange: (double value) => {timePassed.state = value},
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              bottom: movePos.state ? 10 : 30,
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: Icon(Icons.shuffle_rounded), onPressed: () {}),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 3,
                          child: SizedBox(
                            height: movePos.state ? 30 : 40,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 0),
                                icon: Icon(Icons.fast_rewind_rounded),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 3,
                          child: SizedBox(
                            height: movePos.state ? 30 : 40,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 0),
                                icon: Icon(Icons.fast_forward_rounded),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                        PlayPause(mplayer: mplayer),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.repeat_rounded), onPressed: () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getArtwork(SongInfo? song, {bool shim = false}) {
    Widget artwork = Icon(Icons.music_note_rounded);
    if (shim) {
      artwork = Shimmer.fromColors(
        child: Icon(
          Icons.music_note_rounded,
          size: 150,
        ),
        baseColor: HexColor("#09203f"),
        highlightColor: HexColor("#537895"),
        period: Duration(seconds: 10),
      );
    }
    if (song != null) {
      if (song.albumArtwork != null) {
        File fleart = File(song.albumArtwork!);
        if (fleart.existsSync()) {
          artwork = Image.file(
            fleart,
            fit: BoxFit.cover,
          );
        }
      }
    }
    return artwork;
  }

  double getMaxDuration(SongInfo? currentSong) {
    return Duration(
            milliseconds: int.parse(
                currentSong != null ? getDuration(currentSong) : "100"))
        .inSeconds
        .toDouble();
  }
}

String printDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String getDuration(SongInfo? csong) {
  String defDur = "100";
  if (csong!.duration != null) {
    defDur = csong.duration!;
  }
  return defDur;
}
