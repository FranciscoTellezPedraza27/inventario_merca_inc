import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class TopBar extends StatelessWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 22)),
          Row(
            children: [
              // Ícono de notificaciones
              IconButton(
                icon: Icon(
                  Remix.notification_3_line,
                  color: Colors.grey[800],
                  size: 24,
                ),
                onPressed: () {
                  // Lógica de notificaciones
                },
              ),
              const SizedBox(width: 10),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/user_avatar.png'),
              ),
            ],
          )
        ],
      ),
    );
  }
}