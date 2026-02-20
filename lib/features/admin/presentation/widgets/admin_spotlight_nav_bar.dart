import 'package:flutter/material.dart';

class AdminSpotlightNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool hasUnread;

  const AdminSpotlightNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(Icons.dashboard_outlined, 'Dashboard'),
      _NavItem(Icons.people_outline, 'Users'),
      _NavItem(Icons.chat_bubble_outline, 'Chat'),
      _NavItem(Icons.notifications_none, 'Alerts'),
      _NavItem(Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark premium background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(
                              0.2) // Subtle highlight for dark theme
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade500,
                          size: 24,
                        ),
                        if (index == 1 &&
                            hasUnread &&
                            !isSelected) // Chat is at index 1 conceptually if order matches, here users is 1, chat is 2
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1E1E1E),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!isSelected)
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  if (isSelected) const SizedBox(height: 14),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem(this.icon, this.label);
}
