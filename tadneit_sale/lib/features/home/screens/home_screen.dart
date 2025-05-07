import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/login_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get login state
    final loginState = ref.watch(loginProvider);
    final isLoggedIn = loginState.isLoggedIn;
    print("isLoggedIn: " + isLoggedIn.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondiennuoc.vn'),
        actions: [
          // Show login/logout button based on login state
          IconButton(
            icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
            onPressed: () {
              if (isLoggedIn) {
                _showLogoutDialog(context, ref);
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? 'Welcome Back!' : 'Welcome to Our App!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a demo Flutter application with Spring Boot backend integration.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Public features section
            Text(
              'Public Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Browse Products',
              description: 'View all available products in our catalog',
              icon: Icons.shopping_bag,
              onTap: () {
                // Navigate to public products page
                // This is public, no login required
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to Products')),
                );
                // context.push('/products');
              },
            ),

            _buildFeatureCard(
              context,
              title: 'About Us',
              description: 'Learn more about our company and mission',
              icon: Icons.info,
              onTap: () {
                // Navigate to about page
                // This is public, no login required
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to About Us')),
                );
                // context.push('/about');
              },
            ),

            const SizedBox(height: 24),

            // Protected features section
            Text(
              'Premium Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'My Profile',
              description: 'View and edit your profile information',
              icon: Icons.person,
              onTap: () {
                // Check if logged in
                if (isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to Profile')),
                  );
                  // context.push('/profile');
                } else {
                  _showLoginRequiredDialog(context);
                }
              },
            ),

            _buildFeatureCard(
              context,
              title: 'My Orders',
              description: 'Track and manage your orders',
              icon: Icons.shopping_cart,
              onTap: () {
                // Check if logged in
                if (isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to Orders')),
                  );
                  // context.push('/orders');
                } else {
                  _showLoginRequiredDialog(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
            'You need to login to access this feature. Would you like to login now?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(loginProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}