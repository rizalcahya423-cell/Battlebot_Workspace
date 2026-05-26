import 'package:flutter/material.dart';

import 'package:my_flutter_app/core/constants/app_colors.dart';
import 'package:my_flutter_app/core/constants/app_sizes.dart';

/// Left sidebar navigation for the lobby screen.
/// Displays menu items: Shop, Inventory, Guide, Pengaturan.
class LobbySidebar extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const LobbySidebar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  static const List<(String, IconData, String)> _menuItems = [
    ('SHOP', Icons.shopping_cart_outlined, 'Shop'),
    ('INVENTORY', Icons.inventory_2_outlined, 'Inventory'),
    ('GUIDE', Icons.menu_book_outlined, 'Guide'),
    ('PENGATURAN', Icons.settings_outlined, 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _menuItems
            .map(
              (item) => _SidebarItem(
                id: item.$1,
                icon: item.$2,
                label: item.$3,
                isActive: selectedTab == item.$1,
                onTap: () => onTabChanged(item.$1),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: AppSizes.sidebarItemWidth,
        margin: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isActive
                ? AppColors.accentBlue.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.accentBlue : Colors.white38,
              size: 28.0, // Perbesar ukuran ikon sidebar agar lebih menonjol
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white38,
                fontSize: AppSizes.fontSm, // Sedikit sesuaikan ukuran teks
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
