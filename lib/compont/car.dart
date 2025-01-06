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

  CarSelectionWidget({this.isDetails = false});
  @override
  State<CarSelectionWidget> createState() => _CarSelectionWidgetState();
}

class _CarSelectionWidgetState extends State<CarSelectionWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.isDetails
          ? 0.9
          : 0.3, // Show more of next/previous cards in compact view
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
      typeService: 'Premium',
      price: 210,
    ),
    CarOption(
      image: 'assets/images/family.png',
      typeService: 'family',
      price: 250,
    ),
  ];

  Widget build(BuildContext context) {
    if (widget.isDetails) {
      return SizedBox(
        height: 300, // Adjust based on your needs
        child: PageView.builder(
          controller: _pageController,
          itemCount: cars.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: DetailedCarView(car: cars[index]),
            );
          },
        ),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cars
              .map((car) => CarCard(
                    image: car.image,
                    typeService: car.typeService,
                    price: car.price,
                  ))
              .toList(),
        ),
      );
    }
  }
}

class CarCard extends StatefulWidget {
  final String image;
  final String typeService;
  final double price;

  const CarCard({
    Key? key,
    required this.image,
    required this.typeService,
    required this.price,
  }) : super(key: key);

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            widget.image,
            height: 70,
            width: 110,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.typeService,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Br${widget.price.toStringAsFixed(0)}',
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
    );
  }
}

class DetailedCarView extends StatelessWidget {
  final CarOption car;

  const DetailedCarView({required this.car});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 2,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '~Br${car.price}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Image.asset(
            car.image,
            width: double.infinity,
            height: 200,
            fit: BoxFit.contain,
          ),
          Text(
            '3 min',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
