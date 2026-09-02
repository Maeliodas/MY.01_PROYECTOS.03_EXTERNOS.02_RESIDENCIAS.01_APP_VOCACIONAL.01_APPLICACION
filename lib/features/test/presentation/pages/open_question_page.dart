import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/widgets/primary_button.dart';

class OpenQuestionPage extends StatefulWidget {
  const OpenQuestionPage({super.key});
  @override
  State<OpenQuestionPage> createState() => _S();
}

class _S extends State<OpenQuestionPage> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Una última pregunta')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            '¿Hay alguna carrera, profesión o área de estudio que te interese actualmente?',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: text,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tu respuesta es opcional',
            ),
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Continuar',
            onPressed: () async {
              final id = GoRouterState.of(
                context,
              ).uri.queryParameters['session'];
              if (id != null) {
                final d = await AppDatabase.instance.database;
                await d.update(
                  Tables.testSessions,
                  {'openResponse': text.text.trim()},
                  where: 'id=?',
                  whereArgs: [id],
                );
              }
              if (c.mounted) c.go('/result/unlocked?session=$id');
            },
          ),
        ],
      ),
    ),
  );
}
