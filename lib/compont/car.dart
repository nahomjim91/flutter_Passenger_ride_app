import 'package:flutter/material.dart';

class CarOption {
  final String image;
  final String typeService;
  final double price;

  CarOption({
    required this.image,
    required this.typeService,
    required this.price,
  });
}

class CarSelectionWidget extends StatefulWidget {
  final bool isDetails;
  final Function(String) whichCar;
  final String currntCarType;

  const CarSelectionWidget({
    this.isDetails = false,
    required this.whichCar,
    required this.currntCarType,
  });

  @override
  State<CarSelectionWidget> createState() => _CarSelectionWidgetState();
}

class _CarSelectionWidgetState extends State<CarSelectionWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.isDetails ? 0.9 : 0.3,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<CarOption> cars = [
    CarOption(
      image: 'assets/images/economy.png',
      typeService: 'Economy',
      price: 170,
    ),
    CarOption(
      image: 'assets/images/premium.png',
      typeService: 'Luxury',
      price: 210,
    ),
    CarOption(
      image: 'assets/images/family.png',
      typeService: 'Family',
      price: 250,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isDetails) {
      return SizedBox(
        height: 300,
        child: PageView.builder(
          controller: _pageController,
          itemCount: cars.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DetailedCarView(
                car: cars[index],
                onTap: widget.whichCar,
                isSelected: widget.currntCarType.toLowerCase() ==
                    cars[index].typeService.toLowerCase(),
              ),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        height: 120, // Add fixed height to prevent overflow
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: cars.length,
          itemBuilder: (context, index) {
            return CarCard(
              onTap: widget.whichCar,
              image: cars[index].image,
              typeService: cars[index].typeService,
              price: cars[index].price,
              isSelected: widget.currntCarType.toLowerCase() ==
                  cars[index].typeService.toLowerCase(),
            );
          },
        ),
      );
    }
  }
}

class CarCard extends StatelessWidget {
  final String image;
  final String typeService;
  final double price;
  final bool isSelected;
  final Function(String) onTap;

  const CarCard({
    Key? key,
    required this.onTap,
    required this.image,
    required this.typeService,
    required this.price,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(typeService.toLowerCase()), // Fixed the onTap handler
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color.fromARGB(255, 204, 49, 14))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              height: 60,
              width: 110,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeService,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Br${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedCarView extends StatelessWidget {
  final CarOption car;
  final bool isSelected;
  final Function(String) onTap;

  const DetailedCarView({
    required this.car,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(car.typeService.toLowerCase()),
      child: Container(
        width: MediaQuery.of(context).size.width - 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(
                  color: const Color.fromARGB(255, 204, 49, 14), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  car.typeService,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '~Br${car.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Image.asset(
              car.image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.contain,
            ),
            const Text(
              '3 min',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
