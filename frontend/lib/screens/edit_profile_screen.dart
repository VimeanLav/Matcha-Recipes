import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'auth_gate_screen.dart';
import '../services/storage_service.dart';
import '../services/supabase_user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
    required this.profile,
  });

  final User user;
  final UserProfileModel? profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  final _authService = AuthService();
  final _userService = SupabaseUserService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  Uint8List? _avatarBytes;
  String _avatarContentType = 'image/jpeg';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.user.displayName ?? '';
    _usernameController.text = widget.profile?.username ?? '';
    _bioController.text = widget.profile?.bio ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _avatarBytes = bytes;
      _avatarContentType = file.mimeType ?? 'image/jpeg';
    });
  }

  Future<void> _save() async {
    if (_submitting) return;

    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (fullName.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and username are required.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      String avatarUrl = widget.profile?.avatarUrl ?? '';
      if (_avatarBytes != null) {
        avatarUrl = await _storageService.uploadProfileAvatar(
          uid: widget.user.uid,
          bytes: _avatarBytes!,
          contentType: _avatarContentType,
        );
      }

      await widget.user.updateDisplayName(fullName);
      await _userService.upsertProfile(
        id: widget.user.uid,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final avatarUrl = widget.profile?.avatarUrl ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Edit profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _submitting ? null : _save,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF557A45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFDDE8CF),
                    backgroundImage: _avatarBytes != null
                        ? MemoryImage(_avatarBytes!)
                        : (avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null) as ImageProvider<Object>?,
                    child: (avatarUrl.isEmpty && _avatarBytes == null)
                        ? Text(
                            _fullNameController.text.isEmpty
                                ? 'U'
                                : _fullNameController.text
                                    .substring(0, 1)
                                    .toUpperCase(),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  InkWell(
                    onTap: _pickAvatar,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF557A45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ProfileField(
                label: 'Full name',
                controller: _fullNameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 18),
              _ProfileField(
                label: 'Username',
                controller: _usernameController,
                prefixText: '@',
              ),
              const SizedBox(height: 18),
              _ProfileField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    backgroundColor: const Color(0xFF557A45),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_submitting ? 'Saving...' : 'Save changes'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Sign out and return to the auth gate (login screen).
                    await _authService.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const AuthGateScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    foregroundColor: const Color(0xFFCC4444),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 1,
    this.prefixText,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5E7),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon:
                  icon == null ? null : Icon(icon, color: Color(0xFF6B7A60)),
              prefixText: prefixText,
              prefixStyle: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF6B7A60),
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}
