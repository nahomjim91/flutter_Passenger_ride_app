import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final Function(String) onPaymentMethodSelected;
  final String? defaultMethod;

  const PaymentMethodBottomSheet({
    Key? key,
    required this.onPaymentMethodSelected,
    this.defaultMethod,
  }) : super(key: key);

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.defaultMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Payment methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentOption(
            'telebirr',
            'Telebirr',
            'Pay with mobile money',
            'assets/images/telebirr_icon.png',
          ),
          _buildPaymentOption(
            'awash',
            'Awash',
            'Pay with mobile money',
            'assets/images/awash_icon.png',
          ),
          _buildPaymentOption(
            'cash',
            'Cash',
            '',
            'assets/images/cash_icon.png',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_selectedMethod != null) {
                widget.onPaymentMethodSelected(_selectedMethod!);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5744),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String method,
    String title,
    String subtitle,
    String iconPath,
  ) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
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
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFFFF5744) : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFF5744) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

void showPaymentMethod(BuildContext context, fallbackFunction,
    {String? paymentOption}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: PaymentMethodBottomSheet(
        defaultMethod: paymentOption,
        onPaymentMethodSelected: (selectedMethod) {
          // Handle the selected payment method here
              fallbackFunction(selectedMethod);
          switch (selectedMethod) {
            case 'telebirr':
              // Handle Telebirr payment
              debugPrint('Telebirr payment selected');
              break;
            case 'awash':
              // Handle Awash payment
              debugPrint('Awash payment selected');
              break;
            case 'cash':
              // Handle Cash payment
              debugPrint('Cash payment selected');
              break;
          }
        },
      ),
    ),
  );
}
