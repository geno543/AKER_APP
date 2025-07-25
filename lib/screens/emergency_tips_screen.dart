import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class EmergencyTipsScreen extends StatelessWidget {
  const EmergencyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'title': 'Injured Animal',
        'description': 'Approach slowly and calmly. Do not touch with bare hands.',
        'icon': Icons.healing,
      },
      {
        'title': 'Aggressive Animal',
        'description': 'Keep distance. Call animal control immediately.',
        'icon': Icons.warning,
      },
      {
        'title': 'Sick Animal',
        'description': 'Observe symptoms. Contact veterinarian or rescue.',
        'icon': Icons.medical_services,
      },
      {
        'title': 'Lost Pet',
        'description': 'Check for ID tags. Post on social media and local groups.',
        'icon': Icons.pets,
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('Emergency Tips'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightGrey.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.grey.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: AppTheme.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tip['description'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.grey,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}