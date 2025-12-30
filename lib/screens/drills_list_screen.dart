import 'package:flutter/material.dart';
import '../screens/drill_session_screen.dart';

class DrillsListScreen extends StatelessWidget {
  const DrillsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of drills with their animation paths
    final List<Map<String, String>> drills = [
      {
        'name': 'Dribbling Drill',
        'animation': 'assets/animations/dribbling.json',
        'description': 'Practice ball control with dribbling exercises'
      },
      {
        'name': 'Shooting Drill',
        'animation': 'assets/animations/shooting.json',
        'description': 'Improve your shooting accuracy'
      },
      {
        'name': 'Passing Drill',
        'animation': 'assets/animations/passing.json',
        'description': 'Perfect your passing technique'
      },
      {
        'name': 'Defending Drill',
        'animation': 'assets/animations/defending.json',
        'description': 'Learn defensive positioning'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Sessions'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: drills.length,
        itemBuilder: (context, index) {
          final drill = drills[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                drill['name']!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  drill['description']!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrillSessionScreen(
                      drillName: drill['name']!,
                      animationAssetPath: drill['animation']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}