import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Assume this package is available
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  // REMOVED: TextEditingController _bioController;
  late TextEditingController _bioController; // Retain declaration structure
  String? _currentImageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    // NOTE: Accessing fields from the User object
    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
    _bioController = TextEditingController(
      text: user.bio ?? '',
    ); // Initialize but remove usage
    _currentImageBase64 = user.profileImageBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- Image Handling Logic ---

  Future<void> _pickImage(ImageSource source) async {
    final appState = Provider.of<AppState>(context, listen: false);

    appState.setImageProcessing(true); // Start loading indicator

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        // Step 1: Read and potentially compress the file
        final bytes = await pickedFile.readAsBytes();

        // Check size (1MB limit)
        if (bytes.lengthInBytes > 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image too large. Max 1MB allowed.')),
          );
          appState.setImageProcessing(false);
          return;
        }

        // Step 2: Convert to Base64
        setState(() {
          _currentImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    } finally {
      appState.setImageProcessing(false); // Stop loading indicator
    }
  }

  void _removePhoto() {
    setState(() {
      _currentImageBase64 = null;
    });
  }

  // --- UI Components ---

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                // FIX: Add Navigator.pop for clean closing before async operation starts
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_currentImageBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _saveChanges() {
    // NOTE: Bio is removed from the save process.
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.saveProfile(
        fullName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        bio: _bioController
            .text, // Retain parameter value, but input field is gone
        profileImageBase64: _currentImageBase64,
      );
      // Navigation is handled inside saveProfile
    }
  }

  // --- Avatar Display (FIXED: Accepts theme parameter) ---
  // This helper method is part of the State class scope
  Widget _buildProfileAvatar(AppState appState, ThemeData theme) {
    if (appState.isImageProcessing) {
      return CircleAvatar(
        radius: 60,
        // Using theme surface for the loading background
        backgroundColor: theme.colorScheme.surface,
        child: const CircularProgressIndicator(),
      );
    }

    if (_currentImageBase64 != null && _currentImageBase64!.isNotEmpty) {
      // Decode Base64 string to display image
      final imageBytes = base64Decode(_currentImageBase64!);
      return CircleAvatar(radius: 60, backgroundImage: MemoryImage(imageBytes));
    }

    // Default icon avatar
    return CircleAvatar(
      radius: 60,
      backgroundColor: theme.colorScheme.primary.withAlpha(26),
      child: Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Define theme and appState here to ensure they are in scope for all functions
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: appState.navigateBack, // Cancel button alternative
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Profile Picture Section ---
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // FIX: Pass theme to the avatar builder
                  _buildProfileAvatar(appState, theme),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () => _showImagePickerOptions(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Form Fields ---

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // REMOVED: Bio / About TextFormField (to meet user requirement)
              /*
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio / About You',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              */
              const SizedBox(height: 32),

              // --- Action Buttons ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: appState.navigateBack,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
