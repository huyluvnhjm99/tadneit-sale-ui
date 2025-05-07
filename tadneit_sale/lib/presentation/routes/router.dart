import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/providers/login_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  //final loginState = ref.read(loginProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // final isLoggedIn = loginState.isLoggedIn;
      // final isLoading = loginState.isLoading;
      // final isLoginRoute = state.matchedLocation == '/login';
      //
      // // Don't redirect while loading
      // if (isLoading) return null;
      //
      // // Only redirect if trying to access protected routes while not logged in
      // // or if trying to access login page while logged in
      //
      // // Home page is accessible to everyone, no redirects needed
      // if (state.matchedLocation == '/') return null;
      //
      // // If accessing login page while logged in, redirect to home
      // if (isLoggedIn && isLoginRoute) return '/';

      // For protected routes, check authentication
      final requiresAuth = _requiresAuth(state.matchedLocation);
      //if (requiresAuth && !isLoggedIn) return '/login';

      // No redirection needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // You can add more routes here
      // Define protected routes
      // GoRoute(
      //   path: '/profile',
      //   builder: (context, state) => const ProfileScreen(),
      // ),
      // GoRoute(
      //   path: '/orders',
      //   builder: (context, state) => const OrdersScreen(),
      // ),
    ],
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

// Helper function to determine if a route requires authentication
bool _requiresAuth(String path) {
  // List of paths that require authentication
  final protectedPaths = [
    '/profile',
    '/orders',
    // Add more protected paths here
  ];

  return protectedPaths.any((route) => path.startsWith(route));
}