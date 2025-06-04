import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/features/home/widgets/home_category_item_view/home_category_item_view.dart';
import 'package:tadneit_sale/features/home/widgets/home_category_selection.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/api_error_handler.dart';
import '../../../features/auth/providers/login_provider.dart';
import '../../admin/providers/category_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        if (ref.read(categoryProvider).categories.isEmpty) {
          ref.read(categoryProvider.notifier).fetchCategories();
        }
      } on ApiException catch (e) {
        if (mounted) {
          ApiErrorHandler.showErrorSnackBar(context, e.message);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginState loginState = ref.read(loginProvider);
    final bool isLoggedIn = loginState.isLoggedIn;
    final CategoryState categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sondiennuoc.vn'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Open Filter dialog
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Open Cart
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(4.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HomeCategorySelection(categoryState: categoryState),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isLoggedIn ? 'Welcome Back!' : 'Welcome to Our App!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PLACE HOLDER for SALE Project\n'
                        'PLACE HOLDER for SALE Project',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              HomeCategoryItemView(categoryState.categories),
              const SizedBox(height: 20),

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
            children: <Widget>[
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
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
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text(
              'You need to login to access this feature. Would you like to login now?',
            ),
            actions: <Widget>[
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
}