import 'package:flutter_test/flutter_test.dart';

import 'package:rc_camera_server/core/constants/app_colors.dart';
import 'package:rc_camera_server/data/config/agora_config.dart';

void main() {
  test('AgoraConfig should have valid app ID', () {
    expect(AgoraConfig.appId.isNotEmpty, isTrue);
    expect(AgoraConfig.channelName, 'rc_car_arena');
  });

  test('AppColors should have distinct status colors', () {
    expect(AppColors.liveRed, isNot(equals(AppColors.successGreen)));
  });
}
