import 'package:flutter/material.dart';

class RegistracijaScreen extends StatelessWidget {
  const RegistracijaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registracija Screen"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          "Dobrodošli na Registracija Screen!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
