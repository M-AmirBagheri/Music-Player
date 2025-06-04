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
          backgroundColor: Colors.grey.shade900,
          title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                ),
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
        backgroundColor: Colors.grey.shade900,
        title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete your account?', style: TextStyle(color: Colors.white70)),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.person, color: Colors.white, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: -10,
                    child: IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt, color: Colors.purpleAccent),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(username, style: const TextStyle(color: Colors.white, fontSize: 20)),
            Text(email, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
              child: const Text("Edit Profile"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Balance", style: TextStyle(color: Colors.white, fontSize: 18)),
                Text("\$${balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _goToPayment("Increase Credit"),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text("Increase Credit"),
            ),
            const SizedBox(height: 20),
            const Text("Subscription", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 6),
            Text(subscription, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ToggleButtons(
              isSelected: List.generate(3, (index) => index == selectedPlan),
              onPressed: (index) {
                setState(() => selectedPlan = index);
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Colors.purpleAccent,
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
                backgroundColor: Colors.purpleAccent,
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