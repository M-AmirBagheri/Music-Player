import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/shop/music_shop_page.dart';
import '../pages/auth/login_page.dart';
import '../services/auth_service.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destination;

    switch (index) {
      case 0:
        destination = const HomePage();
        break;
      case 1:
        if (!AuthService().isLoggedIn) {
          destination = const LoginPage();
        } else {
          destination = const MusicShopPage();
        }
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    return BottomNavigationBar(
      backgroundColor: bottomNavTheme.backgroundColor,
      selectedItemColor: bottomNavTheme.selectedItemColor ?? colorScheme.secondary,
      unselectedItemColor: bottomNavTheme.unselectedItemColor ?? theme.unselectedWidgetColor,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Shop'),
      ],
    );
  }
}
