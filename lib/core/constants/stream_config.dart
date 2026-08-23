/// Configuration for the Rover MediaMTX WebRTC WHEP Camera Stream.
///
/// ============================================================================
/// 📍 EDIT YOUR MEDIAMTX WHEP STREAM URL HERE:
/// ============================================================================
/// MediaMTX serves WebRTC via the standard WHEP endpoint on port 8889:
/// Format: 'http://<RPI_IP>:8889/<STREAM_NAME>/whep'
/// Example: 'http://192.168.1.50:8889/cam/whep'
///
class StreamConfig {
  StreamConfig._();

  /// 🔴 CHANGE THIS URL TO YOUR RASPBERRY PI MEDIAMTX WHEP URL:
  static const String roverCameraStreamUrl = 'http://192.168.1.50:8889/cam/whep';

  /// Stream description shown in UI
  static const String streamTitle = 'Rover Live Cam (WebRTC WHEP)';
  
  /// Connection timeout in seconds
  static const int connectionTimeoutSeconds = 10;
}
