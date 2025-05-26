import 'package:flutter/material.dart';

class AdminItemCard extends StatelessWidget {
  const AdminItemCard({
    super.key,
    required this.count,
    required this.callBackFunction,
    required this.label,
    required this.icon,
    required this.iconBgColor,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color iconBgColor;
  final Function() callBackFunction;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 160,
        minHeight: 160,
        maxHeight: 160,
      ),
      child: Card(
        child: InkWell(
          onTap: callBackFunction,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                const Positioned(right: 0, child: Icon(Icons.navigate_next_outlined)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: iconBgColor,
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(label),
                    const SizedBox(height: 8),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
