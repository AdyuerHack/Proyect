// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proyect/main.dart';
import 'package:proyect/services/gemini_service.dart'; // Importa GeminiService para la prueba

// Crea una clase de servicio Gemini "dummy" para usar en las pruebas.
// Esto evita la necesidad de una clave API real en las pruebas unitarias.
class MockGeminiService extends GeminiService {
  MockGeminiService() : super(apiKey: 'dummy_api_key_for_test');

  @override
  Future<String> generarRespuesta(String prompt) async {
    // Puedes devolver una respuesta de prueba o simular un comportamiento.
    return 'Respuesta de prueba de la IA para: $prompt';
  }
}


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Construye nuestra aplicación y dispara un frame.
    // Proporciona una instancia de MockGeminiService al MyApp.
    await tester.pumpWidget(MyApp(geminiService: MockGeminiService())); // <--- CAMBIO AQUÍ

    // Verifica que nuestro contador empieza en 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Toca el icono '+' y dispara un frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifica que nuestro contador ha incrementado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}