import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final songsFutureProvider = FutureProvider.autoDispose<List<SongInfo>>((ref) {
  return FlutterAudioQuery().getSongs(sortType: SongSortType.RECENT_YEAR);
});

final currentSongProvider = StateProvider<SongInfo?>((ref) {
  return null;
});

final audioPlayerProvider = Provider.autoDispose<AudioPlayer>((ref) {
    final player = AudioPlayer();
    return player;
});

final currentProgressProvider = StateProvider<Duration>((ref) {
    return Duration(seconds: 0);
});

