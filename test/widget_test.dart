import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rebuy/main.dart';

void main() {
  testWidgets('Splash screen shows ReBuy logo', (tester) async {
    await tester.pumpWidget(const RebuyApp());
    expect(find.text('ReBuy'), findsOneWidget);

    // Let the splash timer complete so it doesn't leak.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('Login screen renders title and fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/login': (_) => const AuthScreen(mode: AuthMode.login),
          '/signup': (_) => const AuthScreen(mode: AuthMode.signup),
          '/dashboard': (_) => const Scaffold(),
        },
        initialRoute: '/login',
      ),
    );

    final title = find.byKey(const ValueKey('auth_title'));
    expect(title, findsOneWidget);
    expect((tester.widget(title) as Text).data, 'Log in');
    expect(find.byKey(const ValueKey('email_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('password_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('full_name_field')), findsNothing);
  });
}
