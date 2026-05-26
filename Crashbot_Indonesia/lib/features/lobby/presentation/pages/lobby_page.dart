import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';
import 'package:my_flutter_app/features/lobby/presentation/widgets/lobby_top_bar.dart';
import 'package:my_flutter_app/features/lobby/presentation/widgets/lobby_sidebar.dart';
import 'package:my_flutter_app/features/lobby/presentation/widgets/lobby_center_arena.dart';
import 'package:my_flutter_app/features/lobby/presentation/widgets/lobby_leaderboard.dart';
import 'package:my_flutter_app/features/lobby/presentation/widgets/moving_background_painter.dart';

/// Main lobby page — the home screen after authentication.
/// Orchestrates realtime battery/connectivity/ping monitoring
/// and delegates UI to extracted sub-widgets.
class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> with TickerProviderStateMixin {
  String _selectedTab = 'GUIDE';
  final int _gems = 79;

  // Animations
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _backgroundController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _floatAnimation;

  // Realtime: Battery
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  Timer? _batteryTimer;
  StreamSubscription<BatteryState>? _batterySubscription;

  // Realtime: Connectivity
  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.wifi];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Realtime: Ping
  int _lobbyPingMs = 0;
  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initAnimations();
    _initBattery();
    _initConnectivity();
    _initPing();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _backgroundController.dispose();
    _batteryTimer?.cancel();
    _batterySubscription?.cancel();
    _connectivitySubscription?.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }

  // ─── Animation Setup ───

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  // ─── Battery Monitoring ───

  Future<void> _initBattery() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;
      if (mounted) setState(() {});

      _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
        if (mounted) {
          setState(() => _batteryState = state);
          _battery.batteryLevel.then((level) {
            if (mounted) setState(() => _batteryLevel = level);
          });
        }
      });

      _batteryTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _pollBatteryLevel(),
      );
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
      if (mounted) setState(() => _batteryLevel = -1);
    }
  }

  Future<void> _pollBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
          _batteryState = state;
        });
      }
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
    }
  }

  // ─── Connectivity Monitoring ───

  Future<void> _initConnectivity() async {
    try {
      _connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) setState(() {});

      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        result,
      ) {
        if (mounted) setState(() => _connectivityResult = result);
      });
    } on Exception catch (e, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stackTrace),
      );
      if (mounted) {
        setState(() => _connectivityResult = [ConnectivityResult.none]);
      }
    }
  }

  // ─── Ping Monitoring ───

  Future<void> _initPing() async {
    await _performPing();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _performPing(),
    );
  }

  Future<void> _performPing() async {
    if (_connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) setState(() => _lobbyPingMs = 0);
      return;
    }
    try {
      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 2),
      );
      stopwatch.stop();
      socket.destroy();
      if (mounted) {
        setState(() => _lobbyPingMs = stopwatch.elapsedMilliseconds);
      }
    } on Exception catch (_) {
      if (mounted) setState(() => _lobbyPingMs = 999);
    }
  }

  // ─── Battery & Signal Helpers ───

  IconData get _batteryIcon {
    if (_batteryState == BatteryState.charging) {
      return Icons.battery_charging_full;
    }
    if (_batteryLevel < 0) return Icons.battery_unknown;
    if (_batteryLevel > 80) return Icons.battery_full;
    if (_batteryLevel > 60) return Icons.battery_5_bar;
    if (_batteryLevel > 40) return Icons.battery_4_bar;
    if (_batteryLevel > 20) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  String get _batteryText {
    if (_batteryLevel < 0) return '??%';
    return '$_batteryLevel%';
  }

  IconData get _signalIcon {
    if (_connectivityResult.contains(ConnectivityResult.wifi)) {
      return Icons.wifi;
    }
    if (_connectivityResult.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_alt;
    }
    if (_connectivityResult.contains(ConnectivityResult.ethernet)) {
      return Icons.lan;
    }
    if (_connectivityResult.contains(ConnectivityResult.none)) {
      return Icons.signal_wifi_off;
    }
    return Icons.signal_cellular_alt;
  }

  Color get _signalColor {
    if (_connectivityResult.contains(ConnectivityResult.none) ||
        _lobbyPingMs == 999) {
      return AppColors.dangerRed;
    }
    if (_lobbyPingMs > 0 && _lobbyPingMs <= 100) {
      return AppColors.successGreen;
    }
    if (_lobbyPingMs > 100 && _lobbyPingMs <= 200) {
      return AppColors.warningYellow;
    }
    if (_lobbyPingMs > 200) return AppColors.dangerRed;
    return AppColors.successGreen;
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [_buildBackground(), _buildMainLayout()]),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return CustomPaint(
            painter: MovingBackgroundPainter(_backgroundController.value),
          );
        },
      ),
    );
  }

  Widget _buildMainLayout() {
    return Column(
      children: [
        const SizedBox(height: AppSizes.spacingSm),
        LobbyTopBar(
          gems: _gems,
          batteryLevel: _batteryLevel,
          batteryIcon: _batteryIcon,
          batteryColor: AppColors.batteryGreen,
          batteryText: _batteryText,
          signalIcon: _signalIcon,
          signalColor: _signalColor,
          pingMs: _lobbyPingMs,
        ),
        Expanded(
          child: Row(
            children: [
              LobbySidebar(
                selectedTab: _selectedTab,
                onTabChanged: (tab) => setState(() => _selectedTab = tab),
              ),
              Expanded(
                child: LobbyCenterArena(
                  pulseAnimation: _pulseAnimation,
                  floatAnimation: _floatAnimation,
                ),
              ),
              const LobbyLeaderboard(),
            ],
          ),
        ),
      ],
    );
  }
}
