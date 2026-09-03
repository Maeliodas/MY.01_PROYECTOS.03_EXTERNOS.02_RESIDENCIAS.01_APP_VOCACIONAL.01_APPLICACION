import 'package:flutter_test/flutter_test.dart';
// Cambia 'app_vocacional' por el nombre de tu paquete en pubspec.yaml
import 'package:app_vocacional/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Reemplaza App() por AppVocacional() o el nombre real de tu MaterialApp
    await tester.pumpWidget(const AppVocacional());
  });
}
