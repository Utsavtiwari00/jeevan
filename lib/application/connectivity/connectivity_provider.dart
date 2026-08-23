import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityStatusProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((event) => event.first);
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStatusProvider).value;
  return connectivity == ConnectivityResult.none;
});

final lastSyncedProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
