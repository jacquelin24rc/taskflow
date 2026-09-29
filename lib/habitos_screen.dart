import 'package:flutter/material.dart';

class HabitosScreen extends StatelessWidget {
  const HabitosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hábitos'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis hábitos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('Leer 20 minutos'),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('Hacer ejercicio'),
            ),
          ],
        ),
      ),
    );
  }
}