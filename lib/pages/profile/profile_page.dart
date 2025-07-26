import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../payment/payment_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final _picker = ImagePicker();

  String username = 'aras_music_user';
  String email = 'user@example.com';
  String subscription = 'Standard';
  double balance = 0;

  int selectedPlan = 0;
  final List<String> plans = ['Monthly', '3 Months', 'Yearly'];

  void _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController(text: username);
        final emailController = TextEditingController(text: email);
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  username = nameController.text.trim();
                  email = emailController.text.trim();
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _goToPayment(String purpose) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          song: {'title': purpose, 'artist': 'System', 'price': 'Custom'},
        ),
      ),
    );

    if (result != null && result is double) {
      setState(() {
        balance += result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your credit has been updated.")),
      );
    }
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Account deleted."),
              ));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: -10,
                    child: IconButton(
                      onPressed: _pickImage,
                      icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.secondary),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(username, style: Theme.of(context).textTheme.titleMedium),
            Text(email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Balance", style: TextStyle(fontSize: 18)),
                Text("\$${balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _goToPayment("Increase Credit"),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text("Increase Credit"),
            ),
            const SizedBox(height: 20),
            const Text("Subscription", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(subscription, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected: List.generate(3, (index) => index == selectedPlan),
              onPressed: (index) {
                setState(() => selectedPlan = index);
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).colorScheme.secondary,
              color: Colors.white70,
              children: plans.map((plan) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(plan),
              )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _goToPayment("Get Premium (${plans[selectedPlan]})"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: const Text("Get Premium"),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: _deleteAccount,
              child: const Text("Delete Account", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
