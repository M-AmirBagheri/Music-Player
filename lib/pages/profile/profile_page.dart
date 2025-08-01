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

  String username = 'HICH_Music';
  String email = 'user@example.com';
  String subscription = 'Standard';
  double balance = 0;

  int selectedPlan = 0;
  final List<String> plans = ['Monthly', '3 Months', 'Yearly'];

  static const Color primaryPurple = Color(0xFF9C27B0);

  void _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _editProfile() {
    final nameController = TextEditingController(text: username);
    final emailController = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Username")),
            const SizedBox(height: 10),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
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
      ),
    );
  }

  void _goToPayment(String purpose) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(song: {'title': purpose, 'artist': 'System', 'price': 'Custom'}),
      ),
    );
    if (result != null && result is double) {
      setState(() => balance += result);
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account deleted.")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF1F1F1);
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // پروفایل با عکس انتخاب‌شده
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: primaryPurple,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  style: IconButton.styleFrom(
                    backgroundColor: primaryPurple,
                    shape: const CircleBorder(),
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(username, style: theme.textTheme.titleMedium?.copyWith(color: isDark ? Colors.white : Colors.black)),
            Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.grey[700])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _editProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),

            // Balance Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Balance", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text("${balance.toInt()} Toman", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _goToPayment("Increase Credit"),
                    icon: const Icon(Icons.add),
                    label: const Text("Increase Credit", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Subscription Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Subscription", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(subscription, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(3, (i) {
                      final isSelected = i == selectedPlan;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedPlan = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                plans[i],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _goToPayment("Get Premium (${plans[selectedPlan]})"),
                    icon: const Icon(Icons.star_border),
                    label: const Text("Get Premium", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
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
