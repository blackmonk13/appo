import 'package:appo/constants.dart';
import 'package:appo/providers/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class APlayer extends ConsumerWidget {
  const APlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final timePassed = watch(timeProvider);
    return Scaffold(
      backgroundColor: lavender,
      body: Stack(
        alignment: AlignmentDirectional.centerStart,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * -.1,
            left: MediaQuery.of(context).size.width * .14,
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
                color: Colors.red,
                width: MediaQuery.of(context).size.width * .7,
                height: MediaQuery.of(context).size.height * .75,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * .03,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {},
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * .03,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.menu_rounded),
              onPressed: () {},
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * .3,
            left: MediaQuery.of(context).size.width * .1,
            child: SleekCircularSlider(
              min: 0,
              max: 100,
              initialValue: 42,
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
                      fontSize: 30.00,
                      fontWeight: FontWeight.w400),
                  topLabelText: 'Perception',
                  bottomLabelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                  bottomLabelText: timePassed.state != null ? printDuration(Duration(seconds: timePassed.state!.toInt())) : null,
                  mainLabelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w500),
                  modifier: (double value) {
                    final time =
                        printDuration(Duration(seconds: value.toInt()));
                    return 'NF';
                  },
                ),
              ),
              onChange: (double value) => {timePassed.state = value},
            ),
          ),
        ],
      ),
    );
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
