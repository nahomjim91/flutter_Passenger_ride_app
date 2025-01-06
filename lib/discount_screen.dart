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
              onclick: () => _openPromoCode(context)),
          const SingleChildScrollView(
              child: Column(
            children: [],
          ))
        ]));
  }

  Future _openPromoCode(BuildContext context) {
    TextEditingController promoCodeController = TextEditingController();
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Promo Code',
                style: TextStyle(
                  color: Color.fromARGB(255, 33, 31, 31),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: TextField(
                  controller: promoCodeController,
                  decoration: InputDecoration(
                      hintText: 'Enter promo code', focusColor: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    maximumSize: const Size(double.infinity, 150),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Activate'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget _buildClickableItem({
    required IconData icon,
    required String label,
    Future Function()? onclick, // Make onclick an optional function parameter
  }) {
    return InkWell(
      onTap: () {
        if (onclick != null) {
          onclick(); // Call the function if it's not null
        }
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
