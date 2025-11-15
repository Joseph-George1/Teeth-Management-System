
import 'package:thotha_mobile_app/core/routing/app_router.dart';
import 'package:thotha_mobile_app/doc_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('App should load successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(DocApp(
      appRouter: AppRouter(),
    ));
    
    // Verify that the app starts up and displays the initial route
    // (This will depend on what your initial route is set to)
    // For example, if your initial route is the splash screen:
    // expect(find.byType(SplashScreen), findsOneWidget);
    
    // Add more specific test cases based on your app's behavior
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
