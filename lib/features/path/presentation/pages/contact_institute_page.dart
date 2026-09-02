import 'package:flutter/material.dart';

class ContactInstitutePage extends StatelessWidget {
  const ContactInstitutePage({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Contacto con el instituto')),
    body: const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Espacio para integrar los canales de contacto institucionales',
      ),
    ),
  );
}
