import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AvatarCustomizationPage extends StatefulWidget {
  const AvatarCustomizationPage({super.key});
  @override
  State<AvatarCustomizationPage> createState() => _AvatarCustomizationPageState();
}

class _AvatarCustomizationPageState extends State<AvatarCustomizationPage> {
  String hair = 'Corto';
  String outfit = 'Casual';
  String accessory = 'Ninguno';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Personaliza tu avatar')),
    body: Column(children: [
      Expanded(child: Center(child: CircleAvatar(radius: 105, child: Icon(Icons.person, size: 150)))),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          DropdownButtonFormField(value: hair, decoration: const InputDecoration(labelText: 'Cabello'), items: const ['Corto','Largo','Ondulado'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged:(v)=>setState(()=>hair=v!)),
          const SizedBox(height: 12),
          DropdownButtonFormField(value: outfit, decoration: const InputDecoration(labelText: 'Ropa'), items: const ['Casual','Formal','Deportivo'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(), onChanged:(v)=>setState(()=>outfit=v!)),
          const SizedBox(height: 12),
          FilledButton(onPressed: ()=>context.pop(), child: const Text('Guardar cambios')),
        ]),
      )
    ]),
  );
}
