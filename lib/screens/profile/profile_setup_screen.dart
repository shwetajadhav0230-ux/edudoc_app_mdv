// lib/screens/profile/profile_setup_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../state/app_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Simplified Controllers (Only what's in your DB)
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _imageFile;
  String? _uploadedImageUrl; // Stores the Supabase URL

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Provider.of<AppState>(context, listen: false).currentUser;

      // ✅ Load existing data directly
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _uploadedImageUrl = user.profileImageUrl;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        // Automatically upload when image is picked
        await _uploadImageToSupabase();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _uploadImageToSupabase() async {
    if (_imageFile == null) return;
    final appState = Provider.of<AppState>(context, listen: false);

    setState(() => _isUploading = true);

    try {
      final userId = appState.currentUser.id;
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '$userId/profile_avatar';
      final filePath = fileName;

      // 1. Upload to Supabase Storage (Bucket must be named 'profiles' or 'profile-pictures')
      await Supabase.instance.client.storage
          .from('profile-pictures')
          .upload(
          fileName,
          _imageFile!,
          fileOptions: const FileOptions(upsert: true) // This now effectively replaces the file
      );

      // 2. Get Public URL
      final imageUrl = Supabase.instance.client.storage
          .from('profile-pictures')
          .getPublicUrl(filePath);

      setState(() {
        _uploadedImageUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _completeSetup() {
    if (_formKey.currentState!.validate()) {

      // ✅ Save only the fields present in your DB
      Provider.of<AppState>(context, listen: false).saveProfile(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text,
        phoneNumber: _phoneController.text.trim(),
        profileImageUrl: _uploadedImageUrl,
        bio: '', // Default empty
        // Passing null for fields removed from UI
        username: null,
        gender: null,
        dateOfBirth: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        automaticallyImplyLeading: false,
        actions: [
          // ✅ Uses the new Skip Logic from previous step
          TextButton(
            onPressed: () {
              // If you haven't added skipProfileSetup to AppState yet, use: appState.navigate(AppScreen.home);
              appState.skipProfileSetup();
            },
            child: const Text('Complete Later'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Let's get to know you!",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),

              // --- Avatar ---
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_uploadedImageUrl != null
                          ? NetworkImage(_uploadedImageUrl!) as ImageProvider
                          : null),
                      child: (_imageFile == null && _uploadedImageUrl == null)
                          ? Icon(Icons.person, size: 60, color: theme.colorScheme.primary)
                          : null,
                    ),
                    if (_isUploading)
                      const Positioned.fill(
                        child: CircularProgressIndicator(),
                      ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- Full Name (Single Field) ---
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person)
                ),
                validator: (v) => v!.isEmpty ? 'Full Name is required' : null,
              ),
              const SizedBox(height: 16),

              // --- Email (Read Only) ---
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email)
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),

              // --- Phone ---
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone)
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save & Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}