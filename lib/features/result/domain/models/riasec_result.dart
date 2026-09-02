import '../../../../core/constants/riasec_constants.dart';
class RiasecResult { final Map<RiasecType,int> scores; const RiasecResult(this.scores); double percentage(RiasecType t)=>(scores[t]??0)/45*100; List<RiasecType> get ordered=>RiasecType.values.toList()..sort((a,b)=>(scores[b]??0).compareTo(scores[a]??0)); String get hollandCode=>ordered.take(3).map((x)=>x.code).join(); }
