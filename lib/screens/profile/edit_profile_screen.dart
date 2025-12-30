import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/forms/styled_text_field.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../config/theme.dart';

/// Edit profile screen for updating user profile information.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _locationController = TextEditingController();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool _hasChanges = false;
  String? _newPhotoPath;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName;
      _locationController.text = user.location ?? '';
      _currentPhotoUrl = user.photoUrl;
    }

    _displayNameController.addListener(_onFormChanged);
    _locationController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      final hasTextChanges =
          _displayNameController.text != user.displayName ||
              _locationController.text != (user.location ?? '');
      setState(() {
        _hasChanges = hasTextChanges || _newPhotoPath != null;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Edit Profile',
      showBackButton: true,
      showBottomNav: false,
      showProfileInAppBar: false,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;

          if (user == null) {
            return const LoadingIndicator();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Photo
                  Center(
                    child: Stack(
                      children: [
                        _buildAvatar(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildPhotoEditButton(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Display Name Field
                  Text(
                    'Display Name',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  StyledTextField(
                    controller: _displayNameController,
                    hintText: 'Enter your display name',
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Display name is required';
                      }
                      if (value.length < 2) {
                        return 'Display name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Location Field
                  Text(
                    'Location (Optional)',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  StyledTextField(
                    controller: _locationController,
                    hintText: 'City, Country',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 24),

                  // Email (Read-only)
                  Text(
                    'Email',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  StyledTextField(
                    controller: TextEditingController(text: user.email),
                    enabled: false,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email cannot be changed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  PrimaryButton(
                    text: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _hasChanges ? _saveProfile : null,
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final theme = Theme.of(context);
    const radius = 60.0;

    Widget avatarContent;

    if (_newPhotoPath != null) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(_newPhotoPath!)),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      );
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(_currentPhotoUrl!),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      );
    } else {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: radius,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return avatarContent;
  }

  Widget _buildPhotoEditButton() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.camera_alt,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_currentPhotoUrl != null || _newPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: BoldaskColors.error),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: BoldaskColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _newPhotoPath = null;
                    _currentPhotoUrl = null;
                    _hasChanges = true;
                  });
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _newPhotoPath = pickedFile.path;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? photoUrl = _currentPhotoUrl;

      // Upload new photo if selected
      if (_newPhotoPath != null) {
        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.userId!;
        photoUrl = await _storageService.uploadProfilePhotoFile(
          userId,
          File(_newPhotoPath!),
        );
      }

      // Update profile
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.updateProfile(
        displayName: _displayNameController.text.trim(),
        photoUrl: photoUrl,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Failed to update profile'),
              backgroundColor: BoldaskColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: BoldaskColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
