import 'dart:io';

import 'package:ct312h_project/ui/shared/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../widgets/bottom_navigation.dart';
import '../screens.dart';

class Profile extends StatefulWidget {
  static const routeName = '/profile';
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUserDetails();
    setState(() => _user = user);
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    try {
      final imageFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        final updatedUser = _user?.copyWith(avatar: File(imageFile.path));
        if (updatedUser != null) {
          final result = await _authService.updateUser(updatedUser);
          if (result != null) {
            setState(() => _user = result);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, 'An error when updating avatar!');
      }
    }
  }

  void _showEditUserDialog() {
    final nameController = TextEditingController(text: _user?.name);
    final descriptionController =
        TextEditingController(text: _user?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit information',
            style: TextStyle(fontFamily: 'Lato')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              style: TextStyle(color: Colors.black),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final updatedUser = _user?.copyWith(
                name: nameController.text,
                description: descriptionController.text,
              );
              if (updatedUser != null) {
                final result = await _authService.updateUser(updatedUser);
                if (result != null) {
                  setState(() => _user = result);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    context.read<AuthManager>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_user!.imageUrl),
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt,
                              size: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Email: ${_user!.email}',
                            style: const TextStyle(fontSize: 18)),
                        Text('Name: ${_user!.name ?? 'Not updated'}',
                            style: const TextStyle(fontSize: 18)),
                        Text(
                            'Description: ${_user!.description ?? 'Not updated'}',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: _showEditUserDialog,
                            child: const Text('Edit information')),
                        ElevatedButton(
                            onPressed: _logout, child: const Text('Logout')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNav(currentIndex: 4),
    );
  }
}
