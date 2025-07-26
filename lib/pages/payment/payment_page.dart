import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> song;

  const PaymentPage({super.key, required this.song});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final String validPin = "1234";
  String? errorText;
  bool paymentSuccess = false;

  void _pay() {
    final card = _cardController.text.trim();
    final pin = _pinController.text.trim();
    final amountStr = _amountController.text.trim();

    if (card.length != 16 || int.tryParse(card) == null) {
      setState(() => errorText = "Card number must be 16 digits.");
      return;
    }

    if (pin != validPin) {
      setState(() => errorText = "Incorrect PIN.");
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      setState(() => errorText = "Invalid payment amount.");
      return;
    }

    setState(() {
      errorText = null;
      paymentSuccess = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context, amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.song['title'],
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Card Number (16 digits)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("PIN"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Amount (e.g. 5.00)"),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(errorText!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Pay"),
            ),
            if (paymentSuccess)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  "✅ Payment successful!",
                  style: TextStyle(color: Colors.greenAccent),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodySmall,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _pinController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
