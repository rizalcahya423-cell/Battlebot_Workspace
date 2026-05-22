import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_routes.dart';

void main() {
  test('AppRoutes should contain all expected routes', () {
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.lobby, '/lobby');
    expect(AppRoutes.remote, '/remote');
  });

  test('AppColors should have distinct primary colors', () {
    expect(AppColors.primaryBlue, isNot(equals(AppColors.dangerRed)));
    expect(AppColors.successGreen, isNot(equals(AppColors.warningYellow)));
  });
}
