// File: lib/screens/buyer/buyer_main_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'browse_properties_screen.dart';
import 'buyer_account_screen.dart';
import 'scheduled_timeline_screen.dart';
import 'search_explore_screen.dart';

class BuyerMainScreen extends StatefulWidget {
  const BuyerMainScreen({super.key});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BrowsePropertiesScreen(),
    SearchExploreScreen(),
    ScheduledTimelineScreen(),
    BuyerAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkBackground,
          border: Border(top: BorderSide(color: Color(0xFF262626), width: 0.8)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppTheme.darkBackground,
          selectedItemColor: AppTheme.textPrimary,
          unselectedItemColor: const Color(0xFF6B6B6B),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _currentIndex == 0
                    ? BoxDecoration(
                        color: const Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: const Icon(Icons.home_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.home, color: AppTheme.textPrimary),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _currentIndex == 1
                    ? BoxDecoration(
                        color: const Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: const Icon(Icons.search),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.search, color: AppTheme.textPrimary),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _currentIndex == 2
                    ? BoxDecoration(
                        color: const Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: const Icon(Icons.calendar_month_outlined),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.calendar_month, color: AppTheme.textPrimary),
              ),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _currentIndex == 3
                    ? BoxDecoration(
                        color: const Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: const Icon(Icons.person_outline),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D3D3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: AppTheme.textPrimary),
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
