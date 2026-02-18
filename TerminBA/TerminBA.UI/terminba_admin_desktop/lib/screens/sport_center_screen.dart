import 'package:flutter/material.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';
import 'package:terminba_admin_desktop/widgets/sport_center_card.dart';

class SportCenterScreen extends StatefulWidget {
  const SportCenterScreen({super.key});

  @override
  State<SportCenterScreen> createState() => _SportCenterScreenState();
}

class _SportCenterScreenState extends State<SportCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Sport Center',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildSearch(), _buildResult()],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // Implement search logic here
            },
            child: Text("Add Sport Center"),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 500,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search sport centers...",
                        suffixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Implement search logic here
                    },
                    child: Text("Search"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    var screenWidth = MediaQuery.of(context).size.width;
    int itemCount = 4;
    if (screenWidth < 1000) {
      setState(() {
        itemCount = 2; // Mobile
      });
    } else if (screenWidth < 1400) {
      setState(() {
        itemCount = 3;
      });
      // Tablet
    } else {
      setState(() {
        itemCount = 4;
      }); // Large desktop/ Small desktop
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemCount,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 11, // Example number of items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FacilityCard(),
          );
        },
      ),
    );
  }
}
