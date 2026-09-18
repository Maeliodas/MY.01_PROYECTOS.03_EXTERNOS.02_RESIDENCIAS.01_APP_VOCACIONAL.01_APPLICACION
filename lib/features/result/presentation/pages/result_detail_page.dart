import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_notice_dialog.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/result_provider.dart';

class ResultDetailPage extends ConsumerWidget {
  final String? careerId;
  const ResultDetailPage({super.key, this.careerId});

  static const _names = <String, String>{
    'R': 'Realista', 'I': 'Investigador', 'A': 'Artístico',
    'S': 'Social', 'E': 'Emprendedor', 'C': 'Convencional',
  };

  Map<String, double> _student(dynamic riasec) => {
    'R': riasec.scoreR / 50 * 100, 'I': riasec.scoreI / 50 * 100,
    'A': riasec.scoreA / 50 * 100, 'S': riasec.scoreS / 50 * 100,
    'E': riasec.scoreE / 50 * 100, 'C': riasec.scoreC / 50 * 100,
  };

  String _explanation(CareerCatalog career, Map<String, double> student) {
    final dims = ['R','I','A','S','E','C'];
    final ranked = [...dims]..sort((a,b) {
      final av = (student[a] ?? 0) * ((career.weights[a] ?? 0) / 10);
      final bv = (student[b] ?? 0) * ((career.weights[b] ?? 0) / 10);
      return bv.compareTo(av);
    });
    final a = _names[ranked[0]]!;
    final b = _names[ranked[1]]!;
    return 'Esta carrera aparece entre tus recomendaciones porque tus intereses de tipo $a y $b presentan una correspondencia importante con el perfil RIASEC configurado para ${career.name}. La afinidad considera tus seis dimensiones y la congruencia de tu código Holland; la pregunta abierta no modifica este porcentaje.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(latestResultProvider);
    final careersAsync = ref.watch(careersCatalogProvider);
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Detalle de carrera')),
      body: SafeArea(
        top: false,
        child: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('No fue posible cargar el detalle.')),
        data: (data) {
          if (data == null) return const Center(child: Text('Sin resultado disponible.'));
          final match = data.ranking.firstWhere((x) => x.careerId == careerId, orElse: () => data.topCareer);
          final careers = careersAsync.valueOrNull ?? const <CareerCatalog>[];
          final found = careers.where((x) => x.id == match.careerId).toList();
          if (found.isEmpty) return const Center(child: Text('No se encontró la información de la carrera.'));
          final career = found.first;
          final student = _student(data.riasec);
          return ListView(
            padding: EdgeInsets.fromLTRB(22, 8, 22, 32 + MediaQuery.viewPaddingOf(context).bottom),
            children: [
              Text(career.department.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: AppColors.primary)),
              const SizedBox(height: 8),
              Text(match.name, style: const TextStyle(fontSize: 30, height: 1.05, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha:.12), borderRadius: BorderRadius.circular(18)), child: Text('${match.affinityPercentage.round()}% de afinidad', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary))),
                const SizedBox(width: 8),
                Text('Perfil ${career.hollandCode}', style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
              const SizedBox(height: 18),
              Text(career.description, style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 20),
              _Card(title: '¿Por qué corresponde contigo?', icon: Icons.psychology_alt_rounded, child: Text(_explanation(career, student), style: const TextStyle(fontSize: 15, height: 1.5))),
              const SizedBox(height: 16),
              _Card(
                title: 'Gráfico de afinidad RIASEC',
                icon: Icons.radar_rounded,
                child: Column(
                  children: [
                    const Row(children:[_Legend(color: AppColors.primary,label:'Tu perfil'), SizedBox(width:18), _Legend(color: Color(0xFF1B396A),label:'Carrera')]),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 270,
                      child: CustomPaint(
                        painter: _RiasecRadarPainter(
                          student: student,
                          career: {for (final d in ['R','I','A','S','E','C']) d: ((career.weights[d] ?? 0) / 10 * 100)},
                          gridColor: Theme.of(context).colorScheme.outlineVariant,
                          labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('La figura compara las seis dimensiones RIASEC sin alterar el cálculo de afinidad.', style: TextStyle(fontSize: 12, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Card(title: 'Comparación RIASEC', icon: Icons.analytics_rounded, child: Column(children: [
                const Row(children:[_Legend(color: AppColors.primary,label:'Tu perfil'), SizedBox(width:18), _Legend(color: Color(0xFF1B396A),label:'Carrera')]),
                const SizedBox(height:16),
                ...['R','I','A','S','E','C'].map((d) => _CompareBar(label: '${_names[d]} ($d)', student: student[d] ?? 0, career: ((career.weights[d] ?? 0) / 10 * 100))),
              ])),
              const SizedBox(height: 18),
              if (career.websiteUrl.trim().isNotEmpty)
                FilledButton.icon(
                  onPressed: () => launchUrl(Uri.parse(career.websiteUrl), mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded), label: const Text('Consultar página oficial TecNM'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => showAppNoticeDialog(context, icon: Icons.language_rounded, title: 'Página no disponible', content: const Text('La página oficial de esta carrera todavía no está disponible.', textAlign: TextAlign.center)),
                  icon: const Icon(Icons.language_rounded), label: const Text('Página oficial no disponible'),
                ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _Card({required this.title, required this.icon, required this.child});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Row(children:[Icon(icon,color:AppColors.primary),const SizedBox(width:9),Expanded(child:Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)))]),const SizedBox(height:14),child]));
}
class _Legend extends StatelessWidget { final Color color; final String label; const _Legend({required this.color,required this.label}); @override Widget build(BuildContext context)=>Row(children:[Container(width:10,height:10,decoration:BoxDecoration(color:color,shape:BoxShape.circle)),const SizedBox(width:5),Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))]); }
class _CompareBar extends StatelessWidget {
  final String label; final double student; final double career;
  const _CompareBar({required this.label,required this.student,required this.career});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:6),_line(student,AppColors.primary),const SizedBox(height:4),_line(career,const Color(0xFF1B396A))]));
  Widget _line(double value,Color color)=>Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(7),child:LinearProgressIndicator(value:(value/100).clamp(0,1),minHeight:8,backgroundColor:color.withValues(alpha:.12),valueColor:AlwaysStoppedAnimation(color)))),const SizedBox(width:8),SizedBox(width:34,child:Text('${value.round()}%',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800)))]);
}


class _RiasecRadarPainter extends CustomPainter {
  final Map<String, double> student;
  final Map<String, double> career;
  final Color gridColor;
  final Color labelColor;
  const _RiasecRadarPainter({required this.student, required this.career, required this.gridColor, required this.labelColor});

  static const dims = ['R', 'I', 'A', 'S', 'E', 'C'];

  Offset _point(Offset center, double radius, int index, [double factor = 1]) {
    final angle = -math.pi / 2 + index * (2 * math.pi / dims.length);
    return Offset(center.dx + math.cos(angle) * radius * factor, center.dy + math.sin(angle) * radius * factor);
  }

  Path _polygon(Offset center, double radius, List<double> values) {
    final path = Path();
    for (var i = 0; i < dims.length; i++) {
      final p = _point(center, radius, i, (values[i] / 100).clamp(0.0, 1.0));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radius = math.min(size.width, size.height) * .34;
    final grid = Paint()..color = gridColor..style = PaintingStyle.stroke..strokeWidth = 1;
    for (final level in [.25, .5, .75, 1.0]) {
      final path = Path();
      for (var i = 0; i < dims.length; i++) {
        final p = _point(center, radius * level, i);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path..close(), grid);
    }
    for (var i = 0; i < dims.length; i++) {
      canvas.drawLine(center, _point(center, radius, i), grid);
    }

    void drawProfile(List<double> values, Color color) {
      final path = _polygon(center, radius, values);
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: .15)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.4);
      for (var i = 0; i < dims.length; i++) {
        final p = _point(center, radius, i, (values[i] / 100).clamp(0.0, 1.0));
        canvas.drawCircle(p, 3.5, Paint()..color = color);
      }
    }
    drawProfile(dims.map((d) => student[d] ?? 0).toList(), AppColors.primary);
    drawProfile(dims.map((d) => career[d] ?? 0).toList(), const Color(0xFF1B396A));

    for (var i = 0; i < dims.length; i++) {
      final p = _point(center, radius + 20, i);
      final tp = TextPainter(text: TextSpan(text: dims[i], style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RiasecRadarPainter oldDelegate) => oldDelegate.student != student || oldDelegate.career != career || oldDelegate.gridColor != gridColor || oldDelegate.labelColor != labelColor;
}
