import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/careers_data.dart';
import '../../../../core/widgets/result_card.dart';

class CareerRankingPage extends ConsumerWidget {
  const CareerRankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking de Carreras')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: CareersData.ittuxCareers.length,
        itemBuilder: (context, index) {
          final career = CareersData.ittuxCareers[index];
          return ResultCard(
            careerName: career.name,
            affinityPercentage: 85.0 - (index * 5),
            demandTag: career.demandTag,
            onTap: () {},
          );
        },
      ),
    );
  }
}
