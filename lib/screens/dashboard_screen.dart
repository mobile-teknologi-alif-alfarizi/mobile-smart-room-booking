import 'package:flutter/material.dart';
import 'package:mobile_app/screens/booking_screen.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/notification_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart';
import 'package:mobile_app/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _slideDirection = 1;

  final List<Widget> _pages = const [
    HomeScreen(),
    BookingScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _slideDirection = index > _selectedIndex ? 1 : -1;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ...previousChildren,
                currentChild ?? const SizedBox.shrink(),
              ],
            );
          },
          transitionBuilder: (child, animation) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: Offset(_slideDirection.toDouble(), 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const itemCount = 4;
              final width = constraints.maxWidth;
              final itemWidth = width / itemCount;
              final indicatorWidth = itemWidth * 0.68;
              final indicatorLeft =
                  (itemWidth * _selectedIndex) +
                  (itemWidth - indicatorWidth) / 2;

              return SizedBox(
                height: 92,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: indicatorLeft,
                      top: 10,
                      child: Container(
                        width: indicatorWidth,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.26),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: [
                          _NavItem(
                            icon: Icons.home_rounded,
                            isSelected: _selectedIndex == 0,
                            onTap: () => _selectTab(0),
                          ),
                          _NavItem(
                            icon: Icons.calendar_month_rounded,
                            isSelected: _selectedIndex == 1,
                            onTap: () => _selectTab(1),
                          ),
                          _NavItem(
                            icon: Icons.notifications_rounded,
                            isSelected: _selectedIndex == 2,
                            onTap: () => _selectTab(2),
                          ),
                          _NavItem(
                            icon: Icons.person_rounded,
                            isSelected: _selectedIndex == 3,
                            onTap: () => _selectTab(3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? AppColors.white : AppColors.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Center(
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            offset: isSelected ? const Offset(0, -0.12) : Offset.zero,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              scale: isSelected ? 1.08 : 1.0,
              child: Icon(icon, size: 28, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
