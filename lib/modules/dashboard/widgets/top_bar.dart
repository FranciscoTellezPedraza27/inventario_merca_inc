import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 22)),
          Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 10),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_avatar.png'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
