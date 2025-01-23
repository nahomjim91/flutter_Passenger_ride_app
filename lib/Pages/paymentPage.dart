import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_app/Auth/api_service.dart';
import 'package:ride_app/passenger.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({Key? key}) : super(key: key);

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  late String selectedMethod;

  @override
  void initState() {
    super.initState();
    // Initialize selected method from provider
    final passengerProvider = context.read<PassengerProvider>();
    selectedMethod = passengerProvider.passenger?.payment_method ?? 'cash';
  }

  void changeMethod(String method) {
    setState(() {
      selectedMethod = method.toLowerCase();
    });
  }

  void done() async {
    final passengerProvider = context.read<PassengerProvider>();
    if (passengerProvider.passenger != null) {
      final updatedPassenger = passengerProvider.passenger!;
      updatedPassenger.payment_method = selectedMethod;
      await ApiService().updatePassenger(passengerProvider.passenger!);
      passengerProvider.updatePassenger(updatedPassenger);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PassengerProvider>(
      builder: (context, passengerProvider, _) {
        if (passengerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (passengerProvider.passenger == null) {
          return const Center(child: Text('No passenger data available'));
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Payment methods'),
            elevation: 1,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Column(
                  children: [
                    _buildPaymentOption(
                      'Telebirr',
                      'Pay with mobile money',
                      'assets/images/telebirr_icon.png',
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOption(
                      'Awash',
                      'Pay with mobile money',
                      'assets/images/awash_icon.png',
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOption(
                      'Cash',
                      'Pay with mobile money',
                      'assets/images/cash_icon.png',
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4533),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: done,
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, String iconPath) {
    return InkWell(
      onTap: () => changeMethod(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.circle,
              color: selectedMethod == title.toLowerCase()
                  ? Colors.red
                  : Colors.grey[300],
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
