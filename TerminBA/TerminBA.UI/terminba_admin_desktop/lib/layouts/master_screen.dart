import 'package:flutter/material.dart';
import 'package:terminba_admin_desktop/screens/dashboard_screen.dart';
import 'package:terminba_admin_desktop/screens/user_management_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text(
                'TerminBA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _navItem("Dashboard", isSelected: widget.title == "Dashboard"),
                    _navDivider(),
                    _navItem("User Management", isSelected: widget.title == "User Management" ? true : false),
                    _navDivider(),
                    _navItem("Sport Centers", isSelected: widget.title == "Sport Centers"),
                    _navDivider(),
                    _navItem("Reference Data", isSelected: widget.title == "Reference Data"),
                  ],
                ),
              ),

              Row(
                children: [
                  const Text(
                    "Admin",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF5F7F9),
        child: widget.child,
      ),
    );
  }

  Widget _navItem(String title, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () {
          switch(title)
          {
            case "User Management":
              {
                // Navigate to User Management Screen
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserManagementScreen()));
              }
              break;
            case "Sport Centers":
              {
                // Navigate to Sport Centers Screen
              }
              break;
            case "Reference Data":
              {
                // Navigate to Reference Data Screen
              } 
              break;
            case "Dashboard":
            {
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
            }
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _navDivider() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}