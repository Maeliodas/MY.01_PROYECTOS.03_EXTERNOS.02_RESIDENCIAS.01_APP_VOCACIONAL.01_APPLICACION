import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state.dart';

class TestHistoryPage extends ConsumerStatefulWidget {
  const TestHistoryPage({super.key});

  @override
  ConsumerState<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends ConsumerState<TestHistoryPage> {
  List<Map<String, dynamic>> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = await AppDatabase.instance.database;
    final results = await db.query(
      DbTables.testResults,
      orderBy: 'created_at DESC',
    );

    setState(() {
      _historyItems = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tests'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _historyItems.isEmpty
              ? const EmptyState(
                  message: 'Aún no has completado ningún test vocacional.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    final item = _historyItems[index];
                    final date = DateTime.tryParse(item['created_at'] ?? '') ??
                        DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          item['top_career_name'] ?? 'Carrera no disponible',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Código Holland: ${item['holland_code']}'),
                            Text('Fecha: ${AppDateUtils.formatFullDate(date)}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreenLight
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(item['top_career_affinity'] as num).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
