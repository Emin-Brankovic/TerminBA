import 'package:flutter/material.dart';
import 'package:terminba_admin_desktop/layouts/master_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(title: 'Dashboard', 
    child: Padding(padding: const EdgeInsets.all(20.0),
    child:SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 100,
            children: [
              Expanded(child: _reportCard("Total Users", "1250", Icons.person)),
              Expanded(child: _reportCard("Active Facilities", "85",  Icons.location_city)),
              Expanded(child: _reportCard("Reservations", "320", Icons.event_available)),
            ],
          ),

          // Additional dashboard content can go here

        ],
      ),
    ),
    ),
    );
  }


  Widget _reportCard(String title, String value, IconData iconData) {
    return Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: Colors.grey.shade300, width: 1), // Light border
  ),
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData, 
          color: Colors.greenAccent.shade700, 
          size: 40,
        ),
        const SizedBox(height: 12),
        // The Label
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // The Value
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    ),
  ),
);
  }


}