import 'package:flutter/material.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Discounts',
              style: TextStyle(
                color: Color.fromARGB(255, 33, 31, 31),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // const SizedBox(
          //   height: 20,
          // ),
          _buildClickableItem(
            icon: Icons.local_activity_outlined,
            label: 'Enter promo code',
          ),
          SingleChildScrollView(
              child: Column(
            children: [],
          ))
        ]));
  }

  Widget _buildClickableItem({
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        // Handle the tap event
        print('Tapped on $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[500]),
                const SizedBox(width: 20),
                Text(label),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }
}
