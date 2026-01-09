import 'package:flutter/material.dart';
import 'package:more_experts/core/constants/app_colors.dart';

class SpotlightNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SpotlightNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(Icons.home_outlined, 'Home'),
      _NavItem(Icons.work_outline, 'Services'),
      _NavItem(Icons.chat_bubble_outline, 'Chat'),
      _NavItem(Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromRGBO(27, 114, 181, 1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected ? Colors.white : AppColors.mediaGray,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!isSelected) // Show label only when not selected, or always? Image showed label on inactive.
                    // Actually, generic modern designs often show label on active or all.
                    // Let's show label always for clarity, but maybe style differently.
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.black : AppColors.mediaGray,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  if (isSelected) // To keep height consistent if we hide label on selection, but let's just keep label hidden on selection for that "floating bubble" look if that's what the image implied.
                    // Let's stick to a clean look: Icon is highlighted.
                    const SizedBox(
                        height:
                            14), // Spacer to replace text height approximately
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
