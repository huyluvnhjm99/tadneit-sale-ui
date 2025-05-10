import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tadneit_sale/core/constants/enums.dart';
import 'package:tadneit_sale/data/models/auth/user_profile.dart';
import 'package:tadneit_sale/features/auth/providers/profile_provider.dart';
import '../../../core/utils/language_service.dart';
import '../providers/bottom_navigation_provider.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selectedIndex = ref.watch(bottomNavigationProvider);
    final UserProfileDTO? profile = ref.watch(userProfileProvider);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (int index) {
        ref.read(bottomNavigationProvider.notifier).setIndex(index);
      },
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: LanguageService.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: LanguageService.translate('search'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications),
          label: LanguageService.translate('notifications'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: LanguageService.translate('profile'),
        ),
        if (profile != null && (SaleUserRole.MANAGER == profile.role || SaleUserRole.ADMINISTRATOR == profile.role))
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: LanguageService.translate('admin'),
          ),
      ],
    );
  }
}