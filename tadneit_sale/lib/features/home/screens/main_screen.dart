import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/features/auth/providers/login_provider.dart';
import 'package:tadneit_sale/features/auth/screens/login_screen.dart';
import 'package:tadneit_sale/features/auth/screens/profile_screen.dart';
import '../providers/bottom_navigation_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selectedIndex = ref.watch(bottomNavigationProvider);
    final bool isLoggedIn = ref.watch(loginProvider).isLoggedIn;

    Widget getScreenForIndex(int index) {
      switch (index) {
        case 0:
          return const HomeScreen();
        case 1:
          return const HomeScreen();
        case 2:
          return const HomeScreen();
        case 3:
          return isLoggedIn ? const ProfileScreen() : const LoginScreen();
        default:
          return const HomeScreen();
      }
    }

    return Scaffold(
      body: getScreenForIndex(selectedIndex),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}