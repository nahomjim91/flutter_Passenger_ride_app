import 'package:flutter/material.dart';

class SubItemsPage extends StatelessWidget {
  final String title;
  final List<String> items;

  const SubItemsPage({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle navigation to specific issue page
              // You can add more specific pages here
            },
          );
        },
      ),
    );
  }
}

class SupportServicePage extends StatelessWidget {
  const SupportServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Support service'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Additional questions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(
                  context,
                  'Technical issues',
                  [
                    'Account or sig-in issues',
                    'Issue with promo code',
                    'Bank card issues',
                    'Issue with ride report',
                    'Other issues'
                  ],
                ),
                _buildListTile(
                  context,
                  'Financial issues',
                  [
                    'Ride never took place',
                    'I was charged twice/extra',
                    'Price charged',
                    'Unrecognized change',
                    'Other'
                  ],
                ),
                _buildListTile(
                  context,
                  'Driver or vehicle feedback',
                  [
                    'Issue with driver',
                    'Issue with car',
                    'Rides with children',
                    'Rides with pets',
                    'Positive feedback',
                    'Other'
                  ],
                ),
                _buildListTile(
                  context,
                  'Safety',
                  [
                    'I was in traffic accident',
                    'Dangerous driving or traffic violation',
                    'I felt unsafe'
                  ],
                ),
                _buildListTile(
                  context,
                  'Lost items',
                  ['Phone', 'Other'],
                ),
                _buildListTile(
                  context,
                  'FAQ',
                  [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, String title, List<String> subItems) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        print('Tapped on $title');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubItemsPage(title: title, items: subItems),
          ),
        );
      },
    );
  }
}
