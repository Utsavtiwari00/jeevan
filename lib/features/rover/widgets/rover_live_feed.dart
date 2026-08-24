import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jeevan/application/rover/rover_stream_provider.dart';
import 'package:jeevan/core/constants/stream_config.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/widgets/status/status_badge.dart';

enum StreamProtocol { webrtcWhep, webBrowser }

class RoverLiveFeed extends ConsumerStatefulWidget {
  const RoverLiveFeed({super.key});

  @override
  ConsumerState<RoverLiveFeed> createState() => _RoverLiveFeedState();
}

class _RoverLiveFeedState extends ConsumerState<RoverLiveFeed> {
  StreamProtocol _protocol = StreamProtocol.webrtcWhep;

  // WebRTC WHEP state
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  String? _sessionLocation;

  // WebView state
  WebViewController? _webViewController;

  bool _isLive = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String _currentStreamUrl = '';

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    try {
      await _remoteRenderer.initialize();
    } catch (_) {}
    _currentStreamUrl = ref.read(roverStreamUrlProvider);
    _connectFeed(_currentStreamUrl);
  }

  @override
  void dispose() {
    _disconnectWhep();
    try {
      _remoteRenderer.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _disconnectWhep() {
    if (_sessionLocation != null && _currentStreamUrl.isNotEmpty) {
      try {
        final deleteUri = Uri.parse(_sessionLocation!.startsWith('http')
            ? _sessionLocation!
            : Uri.parse(_currentStreamUrl).resolve(_sessionLocation!).toString());
        http.delete(deleteUri);
      } catch (_) {}
      _sessionLocation = null;
    }

    _peerConnection?.close();
    _peerConnection?.dispose();
    _peerConnection = null;
    try {
      _remoteRenderer.srcObject = null;
    } catch (_) {}
  }

  Future<void> _connectFeed(String rawUrl) async {
    _disconnectWhep();

    setState(() {
      _isLoading = true;
      _isLive = false;
      _hasError = false;
      _errorMessage = null;
      _currentStreamUrl = rawUrl;
    });

    if (_protocol == StreamProtocol.webrtcWhep) {
      await _connectWhep(rawUrl);
    } else {
      _connectWebView(rawUrl);
    }
  }

  String _normalizeWhepUrl(String rawUrl) {
    String url = rawUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    // Automatically append /whep if missing for MediaMTX WebRTC port 8889
    if (!url.endsWith('/whep') && !url.contains('.m3u8') && url.contains(':8889')) {
      url = '$url/whep';
    }
    return url;
  }

  String _normalizeWebUrl(String rawUrl) {
    String url = rawUrl.trim();
    // For browser view, remove /whep if present so it loads the MediaMTX web player
    if (url.endsWith('/whep')) {
      url = url.substring(0, url.length - 5);
    }
    return url;
  }

  String _preferH264Codec(String sdp) {
    final lines = sdp.split('\r\n');
    final mVideoIndex = lines.indexWhere((l) => l.startsWith('m=video'));
    if (mVideoIndex == -1) return sdp;

    String? h264Pt;
    for (final line in lines) {
      if (line.startsWith('a=rtpmap:') && line.toLowerCase().contains('h264/90000')) {
        final colonIdx = line.indexOf(':');
        final spaceIdx = line.indexOf(' ');
        if (colonIdx != -1 && spaceIdx != -1) {
          h264Pt = line.substring(colonIdx + 1, spaceIdx);
          break;
        }
      }
    }

    if (h264Pt == null) return sdp;

    final mVideo = lines[mVideoIndex];
    final parts = mVideo.split(' ');
    if (parts.length > 3) {
      final header = parts.sublist(0, 3);
      final codecs = parts.sublist(3);
      codecs.remove(h264Pt);
      codecs.insert(0, h264Pt);
      lines[mVideoIndex] = '${header.join(' ')} ${codecs.join(' ')}';
    }

    return lines.join('\r\n');
  }

  Future<void> _connectWhep(String rawUrl) async {
    final whepUrl = _normalizeWhepUrl(rawUrl);

    try {
      // Local connection: omit external STUN servers to avoid high-latency NAT traversal on local Wi-Fi
      final Map<String, dynamic> configuration = {
        'iceServers': <Map<String, dynamic>>[],
        'sdpSemantics': 'unified-plan',
        'bundlePolicy': 'max-bundle',
        'rtcpMuxPolicy': 'require',
      };

      final Map<String, dynamic> offerConstraints = {
        'mandatory': {
          'OfferToReceiveVideo': true,
          'OfferToReceiveAudio': false,
        },
        'optional': [
          {'googCpuOveruseDetection': false},
          {'googSuspendBelowMinBitrate': false},
        ],
      };

      _peerConnection = await createPeerConnection(configuration, offerConstraints);

      await _peerConnection!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'video') {
          if (event.streams.isNotEmpty) {
            _remoteRenderer.srcObject = event.streams[0];
          }
          if (mounted) {
            setState(() {
              _isLive = true;
              _isLoading = false;
              _hasError = false;
            });
          }
        }
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteRenderer.srcObject = stream;
        if (mounted) {
          setState(() {
            _isLive = true;
            _isLoading = false;
            _hasError = false;
          });
        }
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        if (mounted) {
          if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
            setState(() {
              _isLive = true;
              _isLoading = false;
              _hasError = false;
            });
          } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
            setState(() {
              _isLive = false;
              _hasError = true;
              _errorMessage = 'WebRTC peer connection failed';
            });
          }
        }
      };

      // Create Local SDP Offer
      final RTCSessionDescription offer = await _peerConnection!.createOffer(offerConstraints);
      final optimizedSdp = _preferH264Codec(offer.sdp ?? '');
      await _peerConnection!.setLocalDescription(RTCSessionDescription(optimizedSdp, offer.type));

      // Quick local ICE candidate gathering
      if (_peerConnection!.iceGatheringState != RTCIceGatheringState.RTCIceGatheringStateComplete) {
        await Future.any([
          Future.delayed(const Duration(milliseconds: 200)),
          _waitForIceGathering(_peerConnection!),
        ]);
      }

      final localDesc = await _peerConnection!.getLocalDescription();
      final sdpOffer = localDesc?.sdp ?? optimizedSdp;

      // Send SDP Offer to MediaMTX WHEP Endpoint
      final response = await http.post(
        Uri.parse(whepUrl),
        headers: {
          'Content-Type': 'application/sdp',
          'Accept': 'application/sdp',
        },
        body: sdpOffer,
      ).timeout(Duration(seconds: StreamConfig.connectionTimeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final answerSdp = response.body;
        final answer = RTCSessionDescription(answerSdp, 'answer');
        await _peerConnection!.setRemoteDescription(answer);

        _sessionLocation = response.headers['location'];
      } else {
        throw Exception('MediaMTX WHEP responded with HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _waitForIceGathering(RTCPeerConnection pc) async {
    if (pc.iceGatheringState == RTCIceGatheringState.RTCIceGatheringStateComplete) return;
    final completer = Completer<void>();
    pc.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !completer.isCompleted) {
        completer.complete();
      }
    };
    return completer.future;
  }

  void _connectWebView(String rawUrl) {
    final webUrl = _normalizeWebUrl(rawUrl);

    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String u) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String u) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _isLive = true;
                  _hasError = false;
                });
              }
            },
            onWebResourceError: (WebResourceError err) {
              if (err.isForMainFrame ?? true) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                  });
                }
              }
            },
          ),
        );

      controller.loadRequest(Uri.parse(webUrl));
      _webViewController = controller;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _showEditUrlDialog(BuildContext context) {
    final textController = TextEditingController(text: ref.read(roverStreamUrlProvider));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Stream Configuration', style: AppTypography.headlineSmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediaMTX Stream Link:',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'http://192.168.1.50:8889/cam/whep',
                    filled: true,
                    fillColor: AppColors.paperBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                  ),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Player Engine:',
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: () {
                    setDialogState(() => _protocol = StreamProtocol.webrtcWhep);
                    setState(() => _protocol = StreamProtocol.webrtcWhep);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _protocol == StreamProtocol.webrtcWhep
                          ? AppColors.accentGreenLight
                          : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _protocol == StreamProtocol.webrtcWhep
                            ? AppColors.accentGreen
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _protocol == StreamProtocol.webrtcWhep
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _protocol == StreamProtocol.webrtcWhep
                              ? AppColors.accentGreen
                              : AppColors.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Native WebRTC (WHEP)',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Direct hardware-decoded WebRTC stream',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  onTap: () {
                    setDialogState(() => _protocol = StreamProtocol.webBrowser);
                    setState(() => _protocol = StreamProtocol.webBrowser);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _protocol == StreamProtocol.webBrowser
                          ? AppColors.accentGreenLight
                          : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _protocol == StreamProtocol.webBrowser
                            ? AppColors.accentGreen
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _protocol == StreamProtocol.webBrowser
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: _protocol == StreamProtocol.webBrowser
                              ? AppColors.accentGreen
                              : AppColors.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In-App Browser Mode',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Renders identical view to phone browser',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(roverStreamUrlProvider.notifier).resetToDefault();
                final defaultUrl = ref.read(roverStreamUrlProvider);
                Navigator.pop(ctx);
                _connectFeed(defaultUrl);
              },
              child: Text('Reset', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                final newUrl = textController.text.trim();
                if (newUrl.isNotEmpty) {
                  ref.read(roverStreamUrlProvider.notifier).updateUrl(newUrl);
                  Navigator.pop(ctx);
                  _connectFeed(newUrl);
                }
              },
              child: Text('Connect', style: AppTypography.labelLarge.copyWith(color: AppColors.accentGreen)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Rover Camera Live Feed'),
          ),
          body: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildVideoSurface(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSurface() {
    if (_protocol == StreamProtocol.webrtcWhep) {
      return RTCVideoView(
        _remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: false,
        filterQuality: FilterQuality.low,
      );
    } else if (_webViewController != null) {
      return WebViewWidget(controller: _webViewController!);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(roverStreamUrlProvider, (previous, next) {
      if (next != _currentStreamUrl) {
        _connectFeed(next);
      }
    });

    final streamUrl = ref.watch(roverStreamUrlProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar (Overflow-safe with Expanded title)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.videocam_outlined, color: AppColors.charcoalSoil, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _protocol == StreamProtocol.webrtcWhep ? 'Live Cam (WebRTC)' : 'Live Cam (Browser)',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (_isLive && !_hasError)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.criticalRed.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.criticalRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.criticalRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_isLoading)
                  const StatusBadge(label: 'CONNECTING...', severity: StatusBadgeSeverity.warning)
                else
                  const StatusBadge(label: 'OFFLINE', severity: StatusBadgeSeverity.neutral),
                const SizedBox(width: 2),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Stream Settings',
                  onPressed: () => _showEditUrlDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Video Viewport
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.md),
              bottomRight: Radius.circular(AppRadius.md),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video View
                    _buildVideoSurface(),

                    // Loading State
                    if (_isLoading)
                      Container(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                                strokeWidth: 2.5,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Connecting to MediaMTX...',
                                style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 2),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Text(
                                  _protocol == StreamProtocol.webrtcWhep ? _normalizeWhepUrl(streamUrl) : _normalizeWebUrl(streamUrl),
                                  style: AppTypography.caption.copyWith(color: Colors.white38, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Offline / Error State
                    if (_hasError && !_isLoading)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_off_outlined, color: Colors.white38, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                'Stream Standby',
                                style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _errorMessage ?? 'Ensure phone & RPi are on the same Wi-Fi.',
                                style: AppTypography.caption.copyWith(color: Colors.white60, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white30),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    ),
                                    icon: const Icon(Icons.refresh, size: 14),
                                    label: const Text('Reconnect', style: TextStyle(fontSize: 11)),
                                    onPressed: () => _connectFeed(streamUrl),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.accentGreen,
                                      side: const BorderSide(color: AppColors.accentGreen),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    ),
                                    icon: const Icon(Icons.edit, size: 14),
                                    label: const Text('Edit URL', style: TextStyle(fontSize: 11)),
                                    onPressed: () => _showEditUrlDialog(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Controls overlay (when live)
                    if (_isLive && !_hasError)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                              tooltip: 'Reconnect',
                              onPressed: () => _connectFeed(streamUrl),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                              icon: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                              tooltip: 'Fullscreen',
                              onPressed: () => _showFullscreen(context),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
