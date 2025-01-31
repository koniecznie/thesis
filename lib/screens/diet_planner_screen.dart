import 'package:flutter/material.dart';

class DietPlannerScreen extends StatelessWidget {
  const DietPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalendarz z podziałem na posiłki'),
      ),
      body: const Center(
        child: Text('Tu będzie kalendarz z podziałem na posiłki'),
      ),
    );
  }
}
