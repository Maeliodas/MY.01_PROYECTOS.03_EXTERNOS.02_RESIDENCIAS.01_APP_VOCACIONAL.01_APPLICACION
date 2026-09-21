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

  static const _skills = <String, String>{
    'R': 'practicidad, trabajo técnico y resolución concreta de problemas',
    'I': 'análisis, investigación, razonamiento lógico y curiosidad',
    'A': 'creatividad, expresión, innovación y pensamiento original',
    'S': 'comunicación, empatía, colaboración y orientación a las personas',
    'E': 'liderazgo, iniciativa, persuasión y toma de decisiones',
    'C': 'organización, precisión, planeación y manejo estructurado de información',
  };

  Map<String, double> _student(dynamic riasec) => {
    'R': riasec.scoreR / 50 * 100, 'I': riasec.scoreI / 50 * 100,
    'A': riasec.scoreA / 50 * 100, 'S': riasec.scoreS / 50 * 100,
    'E': riasec.scoreE / 50 * 100, 'C': riasec.scoreC / 50 * 100,
  };

  List<String> _rankedDimensions(Map<String, double> student) {
    final dims = ['R', 'I', 'A', 'S', 'E', 'C'];
    return [...dims]..sort((a, b) => (student[b] ?? 0).compareTo(student[a] ?? 0));
  }

  String _explanation(CareerCatalog career, Map<String, double> student) {
    final dims = ['R','I','A','S','E','C'];
    final ranked = [...dims]..sort((a,b) {
      final av = (student[a] ?? 0) * ((career.weights[a] ?? 0) / 10);
      final bv = (student[b] ?? 0) * ((career.weights[b] ?? 0) / 10);
      return bv.compareTo(av);
    });
    final first = ranked[0];
    final second = ranked[1];
    return 'Tu perfil muestra una combinación especialmente compatible con ${career.name}. '
        'Destacan las dimensiones ${_names[first]} y ${_names[second]}, relacionadas con ${_skills[first]} y ${_skills[second]}. '
        'Estas características coinciden con las áreas que esta carrera prioriza dentro del modelo RIASEC. '
        'La afinidad final compara tus seis dimensiones con el perfil definido para la carrera y considera la congruencia de tu código Holland. '
        'Tómalo como una guía para explorar tus intereses, habilidades y opciones académicas con mayor profundidad.';
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
            final rankedStudent = _rankedDimensions(student);
            final strongest = rankedStudent.first;
            final strongestValue = student[strongest] ?? 0;
            final topSkills = rankedStudent.take(3).map((d) => _names[d]!).toList();
            final topDimensions = rankedStudent.take(3).toList();

            return ListView(
              padding: EdgeInsets.fromLTRB(22, 8, 22, 32 + MediaQuery.viewPaddingOf(context).bottom),
              children: [
                _CareerHeroCard(
                  career: career,
                  affinity: match.affinityPercentage,
                  profile: data.riasec.hollandCode,
                  skills: topSkills,
                ),
                const SizedBox(height: 16),
                _DominantProfileCard(
                  code: strongest,
                  name: _names[strongest]!,
                  value: strongestValue,
                  skillText: _skills[strongest]!,
                ),
                const SizedBox(height: 22),
                const _SectionTitle(icon: Icons.insights_rounded, title: 'Desglose de competencias'),
                const SizedBox(height: 12),
                _CompetencyCard(dimensions: topDimensions, student: student),
                const SizedBox(height: 22),
                _WhyMatchCard(
                  career: career,
                  first: rankedStudent[0],
                  second: rankedStudent[1],
                  explanation: _explanation(career, student),
                ),
                const SizedBox(height: 22),
                const _SectionTitle(icon: Icons.radar_rounded, title: 'Tu mapa RIASEC'),
                const SizedBox(height: 12),
                _Card(
                  title: 'Mapa de tu perfil',
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

class _CareerHeroCard extends StatelessWidget {
  final CareerCatalog career;
  final double affinity;
  final String profile;
  final List<String> skills;
  const _CareerHeroCard({required this.career, required this.affinity, required this.profile, required this.skills});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.primary.withValues(alpha: .22)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .055), blurRadius: 18, offset: const Offset(0, 8))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 58, height: 58, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(18)), child: Icon(_careerIcon(career.department), color: AppColors.primary, size: 31)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('COMPATIBILIDAD MÁXIMA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.05, color: AppColors.primary)),
          const SizedBox(height: 3),
          Text(career.department, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF66746A))),
          const SizedBox(height: 5),
          Text(career.name, style: const TextStyle(fontSize: 25, height: 1.08, fontWeight: FontWeight.w900)),
        ])),
      ]),
      const SizedBox(height: 18),
      Row(children: [
        const Expanded(child: Text('Afinidad vocacional', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF465048)))),
        Text('${affinity.round()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (affinity / 100).clamp(0, 1), minHeight: 9, backgroundColor: AppColors.primary.withValues(alpha: .12), valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _InfoChip(icon: Icons.auto_awesome_rounded, label: '${affinity.round()}% de afinidad'),
        _InfoChip(icon: Icons.psychology_rounded, label: 'Perfil $profile'),
        ...skills.map((s) => _InfoChip(icon: Icons.check_circle_outline_rounded, label: s)),
      ]),
      const SizedBox(height: 15),
      Text(career.description, style: TextStyle(fontSize: 14.5, height: 1.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label;
  const _InfoChip({required this.icon, required this.label});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(16)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: AppColors.primary), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))]),
  );
}

class _DominantProfileCard extends StatelessWidget {
  final String code; final String name; final double value; final String skillText;
  const _DominantProfileCard({required this.code, required this.name, required this.value, required this.skillText});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(26)),
    child: Row(children: [
      SizedBox(width: 92, height: 92, child: Stack(alignment: Alignment.center, children: [
        SizedBox(width: 82, height: 82, child: CircularProgressIndicator(value: (value / 100).clamp(0, 1), strokeWidth: 9, backgroundColor: AppColors.primary.withValues(alpha: .13), valueColor: const AlwaysStoppedAnimation(AppColors.primary), strokeCap: StrokeCap.round)),
        Column(mainAxisSize: MainAxisSize.min, children: [Text('${value.round()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary))]),
      ])),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('PERFIL CON MAYOR PORCENTAJE', style: TextStyle(fontSize: 10, letterSpacing: .9, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 5),
        Text('Perfil $name', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('Refleja fortalezas relacionadas con $skillText.', style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ])),
    ]),
  );
}

class _Card extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _Card({required this.title, required this.icon, required this.child});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Row(children:[Icon(icon,color:AppColors.primary),const SizedBox(width:9),Expanded(child:Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)))]),const SizedBox(height:14),child]));
}

IconData _careerIcon(String department) {
  final d = department.toLowerCase();
  if (d.contains('sistemas') || d.contains('comput')) return Icons.computer_rounded;
  if (d.contains('química') || d.contains('quimica')) return Icons.science_rounded;
  if (d.contains('tierra') || d.contains('civil') || d.contains('arquitect')) return Icons.architecture_rounded;
  if (d.contains('eléctr') || d.contains('electr')) return Icons.bolt_rounded;
  if (d.contains('metal') || d.contains('mec')) return Icons.precision_manufacturing_rounded;
  if (d.contains('administr') || d.contains('econ')) return Icons.business_center_rounded;
  return Icons.school_rounded;
}

class _SectionTitle extends StatelessWidget {
  final IconData icon; final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.primary, size: 23), const SizedBox(width: 8),
    Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))),
  ]);
}

class _CompetencyCard extends StatelessWidget {
  final List<String> dimensions; final Map<String,double> student;
  const _CompetencyCard({required this.dimensions, required this.student});
  static const names = {'R':'Realista','I':'Investigador','A':'Artístico','S':'Social','E':'Emprendedor','C':'Convencional'};
  static const colors = {'R':Color(0xFFEF7C3A),'I':Color(0xFF45A8D8),'A':Color(0xFFE85A9C),'S':Color(0xFF2E8B3C),'E':Color(0xFFE0A11B),'C':Color(0xFFA866E5)};
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(26), border: Border.all(color: const Color(0xFFD8DED3))),
    child: Column(children: dimensions.map((d) {
      final value = student[d] ?? 0; final color = colors[d] ?? AppColors.primary;
      return Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(children: [
        Row(children: [Expanded(child: Text(names[d] ?? d, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))), Text('${value.round()}%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (value/100).clamp(0,1), minHeight: 8, backgroundColor: color.withValues(alpha:.12), valueColor: AlwaysStoppedAnimation(color))),
      ]));
    }).toList()),
  );
}

class _WhyMatchCard extends StatelessWidget {
  final CareerCatalog career;
  final String first;
  final String second;
  final String explanation;

  const _WhyMatchCard({
    required this.career,
    required this.first,
    required this.second,
    required this.explanation,
  });

  static const names = {
    'R': 'Realista',
    'I': 'Investigador',
    'A': 'Artístico',
    'S': 'Social',
    'E': 'Emprendedor',
    'C': 'Convencional',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_circle_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¿Por qué esto te corresponde?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReasonChip(names[first] ?? first),
              _ReasonChip(names[second] ?? second),
              _ReasonChip(career.department),
              _ReasonChip(career.hollandCode),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String text;
  const _ReasonChip(this.text);

  @override
  Widget build(BuildContext context) {
    Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: dark ? .22 : .09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: dark ? const Color(0xFF8BE5A8) : const Color(0xFF28753A),
        ),
      ),
    );
  }
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
      final p = _point(center, radius, i, (values[i] / 100).clamp(0, 1));
      if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
    }
    return path..close();
  }
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radius = math.min(size.width, size.height) * .35;
    final grid = Paint()..color = gridColor..style = PaintingStyle.stroke..strokeWidth = 1;
    for (final factor in [.25, .5, .75, 1.0]) {
      final path = Path();
      for (var i = 0; i < dims.length; i++) {
        final p = _point(center, radius, i, factor);
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      canvas.drawPath(path..close(), grid);
    }
    for (var i = 0; i < dims.length; i++) {
      canvas.drawLine(center, _point(center, radius, i), grid);
    }
    void drawValues(Map<String,double> map, Color color) {
      final values = dims.map((d) => map[d] ?? 0).toList();
      final path = _polygon(center, radius, values);
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: .15)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.4);
    }
    drawValues(career, const Color(0xFF1B396A));
    drawValues(student, AppColors.primary);
    for (var i = 0; i < dims.length; i++) {
      final p = _point(center, radius + 22, i);
      final tp = TextPainter(text: TextSpan(text: dims[i], style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - tp.height / 2));
    }
  }
  @override bool shouldRepaint(covariant _RiasecRadarPainter oldDelegate) => oldDelegate.student != student || oldDelegate.career != career || oldDelegate.gridColor != gridColor || oldDelegate.labelColor != labelColor;
}
