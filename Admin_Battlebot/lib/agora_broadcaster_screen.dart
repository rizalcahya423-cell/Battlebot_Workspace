import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'agora_config.dart';

class AgoraBroadcasterScreen extends StatefulWidget {
  const AgoraBroadcasterScreen({super.key});

  @override
  State<AgoraBroadcasterScreen> createState() => _AgoraBroadcasterScreenState();
}

class _AgoraBroadcasterScreenState extends State<AgoraBroadcasterScreen> {
  late RtcEngine _engine;
  bool _isJoined = false;
  String _statusText = "Menyiapkan Kamera...";
  bool _isError = false;

  // Camera Selection State
  List<VideoDeviceInfo> _cameras = [];
  String? _selectedCameraId;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // 1. Minta izin Kamera (di Windows biasanya langsung diizinkan)
      await [Permission.camera].request();

      // 2. Buat RtcEngine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // 3. Register callbacks
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("local user \${connection.localUid} joined");
            setState(() {
              _isJoined = true;
              _statusText = "Live Streaming Aktif!";
            });
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("AGORA ERROR FIRED: err=\$err, msg=\$msg");
            setState(() {
              _isError = true;
              _statusText = "Error Code: \$err | Msg: \$msg";
            });
          },
        ),
      );

      // 4. Konfigurasi Khusus Broadcaster (Pengirim Kamera)
      await _engine.enableVideo();
      await _engine.disableAudio(); // KITA MATIKAN AUDIO KARENA HANYA BUTUH GAMBAR

      // Dapatkan daftar kamera setelah enableVideo
      await _fetchCameras();

      // Kualitas video untuk RC Car (fokus pada latency rendah)
      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 30,
          bitrate: 800, // Kbps
          degradationPreference: DegradationPreference.maintainFramerate,
        ),
      );

      await _engine.startPreview();

      // 5. Join Channel
      await _engine.joinChannel(
        token: AgoraConfig.token, // Kosongkan jika setting project tanpa certificate
        channelId: AgoraConfig.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: false,
          autoSubscribeAudio: false,
          publishCameraTrack: true,
          publishMicrophoneTrack: false, // Tanpa audio
        ),
      );
    } catch (e) {
      setState(() {
        _isError = true;
        _statusText = "Gagal memulai kamera: \$e";
      });
    }
  }

  Future<void> _fetchCameras() async {
    try {
      final deviceManager = _engine.getVideoDeviceManager();
      final cameras = await deviceManager.enumerateVideoDevices();
      
      setState(() {
        _cameras = cameras;
        if (_cameras.isNotEmpty) {
          // Secara default Agora memakai kamera pertama
          _selectedCameraId = _cameras.first.deviceId;
        }
      });
      
      debugPrint("Kamera terdeteksi: \${_cameras.length}");
      for (var cam in _cameras) {
        debugPrint(" - \${cam.deviceName} (ID: \${cam.deviceId})");
      }
    } catch (e) {
      debugPrint("Gagal mengambil daftar kamera: \$e");
    }
  }

  Future<void> _switchCamera(String? deviceId) async {
    if (deviceId == null) return;
    try {
      await _engine.getVideoDeviceManager().setDevice(deviceId);
      setState(() {
        _selectedCameraId = deviceId;
      });
      debugPrint("Kamera diganti ke: \$deviceId");
    } catch (e) {
      debugPrint("Gagal mengganti kamera: \$e");
    }
  }

  @override
  void dispose() {
    _leaveChannel();
    super.dispose();
  }

  Future<void> _leaveChannel() async {
    try {
      await _engine.stopPreview();
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {
      debugPrint("Error saat dispose: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Admin Battlebot', style: TextStyle(color: Colors.white)),
        actions: [
          // DROPDOWN UNTUK MEMILIH KAMERA
          if (_cameras.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  value: _selectedCameraId,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _switchCamera,
                  items: _cameras.map((VideoDeviceInfo cam) {
                    return DropdownMenuItem<String>(
                      value: cam.deviceId,
                      child: Text(
                        cam.deviceName ?? 'Kamera Unknown',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Tampilkan preview kamera kita sendiri (local)
          Center(
            child: _isJoined
                ? AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),

          // Status bar di bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: _isError 
                  ? Colors.red.withOpacity(0.8) 
                  : (_isJoined ? Colors.green.withOpacity(0.8) : Colors.black54),
              child: Text(
                _statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Indikator "Broadcasting" kecil di pojok
          if (_isJoined)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "LIVE SENDING",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
