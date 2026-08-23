import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/constants/stream_config.dart';

/// Provider for the active Rover live stream URL.
class RoverStreamUrlNotifier extends StateNotifier<String> {
  RoverStreamUrlNotifier() : super(StreamConfig.roverCameraStreamUrl);

  void updateUrl(String newUrl) {
    if (newUrl.trim().isNotEmpty) {
      state = newUrl.trim();
    }
  }

  void resetToDefault() {
    state = StreamConfig.roverCameraStreamUrl;
  }
}

final roverStreamUrlProvider = StateNotifierProvider<RoverStreamUrlNotifier, String>((ref) {
  return RoverStreamUrlNotifier();
});
