import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tadneit_sale/data/models/auth/user_profile.dart';
import 'package:tadneit_sale/data/models/file/file.dart';
import 'package:tadneit_sale/data/providers/message_provider.dart';
import 'package:tadneit_sale/features/auth/providers/profile_provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/api_error_handler.dart';
import '../../../core/utils/file_handler/image_util.dart';
import '../../../core/utils/language_service.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/providers/api_service_provider.dart';
import '../../../presentation/widgets/common/confirmation_dialog.dart';
import '../providers/login_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? profileAvatar;
  bool _isEnableEditMode = false;
  bool _isSavingProfile = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _toggleEditMode() {
    setState(() {
      _isEnableEditMode = !_isEnableEditMode;
      profileAvatar = null;
    });
  }

  Future<void> _refresh() async {
    await ref.read(profileProvider.notifier).fetchProfile();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isSavingProfile = true;
        });

        FileDTO? uploadedAvatar;
        if (profileAvatar != null) {
          final ApiService apiService = ref.read(apiServiceProvider);
          uploadedAvatar = await apiService.uploadFile(
            profileAvatar!,
          );
        }

        await ref
            .read(profileProvider.notifier)
            .saveProfile(
              UserProfileDTO(
                fullName: _fullNameController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                avatar: uploadedAvatar
              ),
            );

        _toggleEditMode();
        if (mounted) {
          ApiErrorHandler.showSuccessSnackBar(context, null);
        }
      } on ApiException catch (e) {
        if (mounted) {
          ApiErrorHandler.showErrorSnackBar(context, e.message);
        }
      } finally {
        profileAvatar = null;
        setState(() {
          _isSavingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.watch here to ensure the widget rebuilds when profile changes
    final ProfileState currentProfileState = ref.watch(profileProvider);
    if (currentProfileState.profile != null) {
      _fullNameController.text = currentProfileState.profile?.fullName ?? '';
      _emailController.text = currentProfileState.profile?.email ?? '';
      _phoneController.text = currentProfileState.profile?.phone ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageService.translate('profile')),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: currentProfileState.isLoading ? null : _toggleEditMode,
            icon:
                _isEnableEditMode
                    ? const Icon(Icons.cancel, color: Colors.red)
                    : const Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child:
            currentProfileState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildProfileForm(currentProfileState),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildProfileForm(ProfileState profileState) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: DecorationImage(
                        opacity: _isEnableEditMode ? 0.4 : 1,
                        image: profileAvatar != null ? FileImage(profileAvatar!) : NetworkImage(profileState.profile?.avatarUrl ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _isEnableEditMode ?
                    Center(
                      child: Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo),
                            tooltip: "Add photo",
                            onPressed: () async {
                              final File? image = await pickImage(
                                context,
                                false,
                                500,
                              );
                              if (image != null) {
                                setState(() {
                                  profileAvatar = image;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            tooltip: "Take a photo",
                            onPressed: () async {
                              final File? image = await pickImage(
                                context,
                                true,
                                500,
                              );
                              if (image != null) {
                                setState(() {
                                  profileAvatar = image;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ) : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: LanguageService.translate('username'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
            ),
            enabled: false,
            initialValue: profileState.profile?.username,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: LanguageService.translate('password'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            enabled: false,
            initialValue: 'password',
          ),
          const SizedBox(height: 12),
          // Use controller instead of initialValue
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: LanguageService.translate('fullName'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.edit),
            ),
            enabled: _isEnableEditMode,
            textInputAction: TextInputAction.next,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().split(' ').length < 2) {
                return 'Please enter your first and last name';
              }
              if (value.length < 3 || value.length > 20) {
                return 'Name must be 3-20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: LanguageService.translate('email'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.edit),
            ),
            enabled: _isEnableEditMode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              final RegExp emailRegex = RegExp(
                r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              if (value.length < 6 || value.length > 20) {
                return 'email must be 6-20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: LanguageService.translate('phone'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.edit),
            ),
            enabled: _isEnableEditMode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Phone number must have at least 10 digits';
              }
              return null;
            },
          ),
          if (_isEnableEditMode) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isEnableEditMode ? _saveProfile : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSavingProfile ? const CircularProgressIndicator() :Text(
                LanguageService.translate('save'),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  LanguageService.translate('logout'),
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    ConfirmDialog.show(
      context,
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: LanguageService.translate('cancel'),
      onConfirm: () async {
        // Process logout after confirmation
        await ref.read(loginProvider.notifier).logout();
        ref.read(messageProvider.notifier).state = LanguageService.translate(
          'unauthorized',
        );
        if (mounted) {
          context.pop();
          context.push("/login");
        }
      },
    );
  }
}
