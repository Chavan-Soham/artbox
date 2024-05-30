import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bggs.jpg',
              fit: BoxFit.fill,
            ),
          ),
          // Close button at the top right corner
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(CupertinoIcons.clear, color: Color.fromARGB(255, 128, 56, 1)),
              ),
            ),
          ),
          // Pricing options and buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        // Handle button press
                      },
                      color: CupertinoColors.activeBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: const Column(
                        children: [
                          Text('Basic: \$9.99/month', style: TextStyle(fontSize: 18)),
                          Text('(Few Images, Very Less Storage)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      onPressed: () {
                        // Handle button press
                      },
                      color: CupertinoColors.activeGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: const Column(
                        children: [
                          Text('Premium: \$39.99/month', style: TextStyle(fontSize: 18)),
                          Text('(Good Images, Good Storage)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      onPressed: () {
                        // Handle button press
                      },
                      color: CupertinoColors.systemPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: const Column(
                        children: [
                          Text('Pro: \$69.99/month', style: TextStyle(fontSize: 18)),
                          Text('(More Images, More Storage)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
