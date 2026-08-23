import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jeevan/widgets/connectivity/offline_banner.dart';

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    final isOffline = connectivityAsync.maybeWhen(
      data: (results) => results.contains(ConnectivityResult.none),
      orElse: () => false,
    );

    return Scaffold(
      body: Column(
        children: [
          OfflineBanner(isOffline: isOffline),
          Expanded(child: child),
        ],
      ),
    );
  }
}
