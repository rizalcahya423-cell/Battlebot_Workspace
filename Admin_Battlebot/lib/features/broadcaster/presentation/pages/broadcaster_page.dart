import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rc_camera_server/core/constants/app_colors.dart';
import 'package:rc_camera_server/core/constants/app_sizes.dart';
import 'package:rc_camera_server/data/config/agora_config.dart';

/// Admin broadcaster page — streams local camera via Agora to remote viewers.
class BroadcasterPage extends StatefulWidget {
  const BroadcasterPage({super.key});

  @override
  State<BroadcasterPage> createState() => _BroadcasterPageState();
}

class _BroadcasterPageState extends State<BroadcasterPage> {
  late RtcEngine _engine;
  bool _isJoined = false;
  String _statusText = 'Menyiapkan Kamera...';
  bool _isError = false;

  List<VideoDeviceInfo> _cameras = [];
  String? _selectedCameraId;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _leaveChannel();
    super.dispose();
  }

  Future<void> _initAgora() async {
    try {
      await [Permission.camera].request();

      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        const RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: _onJoinSuccess,
          onError: _onAgoraError,
        ),
      );

      await _engine.enableVideo();
      await _engine.disableAudio();
      await _fetchCameras();
      await _configureVideoEncoder();
      await _engine.startPreview();
      await _joinChannel();
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
      if (mounted) {
        setState(() {
          _isError = true;
          _statusText = 'Gagal memulai kamera: $e';
        });
      }
    }
  }

  void _onJoinSuccess(RtcConnection connection, int elapsed) {
    if (mounted) {
      setState(() {
        _isJoined = true;
        _statusText = 'Live Streaming Aktif!';
      });
    }
  }

  void _onAgoraError(ErrorCodeType err, String msg) {
    if (mounted) {
      setState(() {
        _isError = true;
        _statusText = 'Error Code: $err | Msg: $msg';
      });
    }
  }

  Future<void> _fetchCameras() async {
    try {
      final deviceManager = _engine.getVideoDeviceManager();
      final cameras = await deviceManager.enumerateVideoDevices();

      if (mounted) {
        setState(() {
          _cameras = cameras;
          if (_cameras.isNotEmpty) {
            _selectedCameraId = _cameras.first.deviceId;
          }
        });
      }
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }

  Future<void> _configureVideoEncoder() async {
    await _engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 1280, height: 720),
        frameRate: 30,
        bitrate: 0,
        degradationPreference: DegradationPreference.maintainFramerate,
        mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
      ),
    );
  }

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: AgoraConfig.token,
      channelId: AgoraConfig.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: false,
        autoSubscribeAudio: false,
        publishCameraTrack: true,
        publishMicrophoneTrack: false,
      ),
    );
  }

  Future<void> _switchCamera(String? deviceId) async {
    if (deviceId == null) return;
    try {
      await _engine.getVideoDeviceManager().setDevice(deviceId);
      if (mounted) setState(() => _selectedCameraId = deviceId);
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }

  Future<void> _leaveChannel() async {
    try {
      await _engine.stopPreview();
      await _engine.leaveChannel();
      await _engine.release();
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text(
          'Admin Battlebot',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_cameras.isNotEmpty)
            _CameraSelector(
              cameras: _cameras,
              selectedCameraId: _selectedCameraId,
              onChanged: _switchCamera,
            ),
        ],
      ),
      body: Stack(
        children: [
          _CameraPreview(isJoined: _isJoined, engine: _engine),
          _StatusBar(
            statusText: _statusText,
            isError: _isError,
            isJoined: _isJoined,
          ),
          if (_isJoined) const _LiveIndicator(),
        ],
      ),
    );
  }
}

// ─── Sub-widgets (satu class per widget, §3.1) ───

class _CameraSelector extends StatelessWidget {
  final List<VideoDeviceInfo> cameras;
  final String? selectedCameraId;
  final ValueChanged<String?> onChanged;

  const _CameraSelector({
    required this.cameras,
    required this.selectedCameraId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXl),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.grey[900],
          value: selectedCameraId,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          items: cameras.map((VideoDeviceInfo cam) {
            return DropdownMenuItem<String>(
              value: cam.deviceId,
              child: Text(
                cam.deviceName ?? 'Kamera Unknown',
                style: const TextStyle(fontSize: AppSizes.fontMd),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  final bool isJoined;
  final RtcEngine engine;

  const _CameraPreview({required this.isJoined, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isJoined
          ? AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(
                  uid: 0,
                  mirrorMode: VideoMirrorModeType.videoMirrorModeDisabled,
                ),
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String statusText;
  final bool isError;
  final bool isJoined;

  const _StatusBar({
    required this.statusText,
    required this.isError,
    required this.isJoined,
  });

  Color get _backgroundColor {
    if (isError) return AppColors.liveRed.withValues(alpha: 0.8);
    if (isJoined) return AppColors.successGreen.withValues(alpha: 0.8);
    return Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingLg),
        color: _backgroundColor,
        child: Text(
          statusText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontLg,
          ),
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSizes.spacingXl,
      right: AppSizes.spacingXl,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingLg,
          vertical: AppSizes.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.liveRed,
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fiber_manual_record,
              color: Colors.white,
              size: AppSizes.iconSm,
            ),
            SizedBox(width: AppSizes.spacingSm),
            Text(
              'LIVE SENDING',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
