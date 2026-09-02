import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../result/presentation/providers/result_provider.dart';

final historyProvider = FutureProvider(
  (ref) => ref.read(resultDataSourceProvider).history(),
);

class TestHistoryPage extends ConsumerWidget {
  const TestHistoryPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef r) {
    final h = r.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de tests')),
      body: h.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (x) => x.isEmpty
            ? const Center(child: Text('Todavía no tienes tests realizados'))
            : ListView.builder(
                itemCount: x.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.assessment_outlined),
                  title: Text('Código Holland: ${x[i]['hollandCode']}'),
                  subtitle: Text(
                    AppDateUtils.display(x[i]['createdAt'] as String),
                  ),
                ),
              ),
      ),
    );
  }
}
