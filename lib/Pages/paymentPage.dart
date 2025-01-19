import 'package:flutter/material.dart';
import 'package:ride_app/passenger.dart';

class PaymentMethod extends StatefulWidget {
  Passenger passenger;
  Function(Passenger) updater;
  PaymentMethod({Key? key, required this.passenger, required this.updater})
      : super(key: key);

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  late String selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.passenger.payment_method; // Default selected method
  }

  void changeMethod(String method) {
    setState(() {
      selectedMethod = method.toLowerCase();
    });
  }

  void done() {
    Passenger tempPassenger = widget.passenger;
    tempPassenger.payment_method = selectedMethod;
    widget.updater(tempPassenger);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment methods'),
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
                      backgroundColor: Color(0xFFFF4533),
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => done(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, String iconPath) {
    return InkWell(
      onTap: () => changeMethod(title),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(8),
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
                    style: TextStyle(
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

            // if (selectedMethod == title)
            Icon(
              Icons.circle,
              color: selectedMethod == title ||
                      selectedMethod == title.toLowerCase()
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
