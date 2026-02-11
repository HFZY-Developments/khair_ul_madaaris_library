import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khair_ul_madaaris_library/core/widgets/premium_dialogs.dart';

void main() {
  testWidgets('success dialog primary action closes only the dialog route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (routeContext) => Scaffold(
                            body: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Scanner Route'),
                                  ElevatedButton(
                                    onPressed: () {
                                      showPremiumSuccessDialog(
                                        routeContext,
                                        title: 'Done',
                                        message: 'Operation completed',
                                        icon: Icons.check_circle_rounded,
                                      );
                                    },
                                    child: const Text('Show Success'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Scanner Route'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Scanner Route'));
    await tester.pumpAndSettle();
    expect(find.text('Scanner Route'), findsOneWidget);

    await tester.tap(find.text('Show Success'));
    await tester.pumpAndSettle();
    expect(find.text('Operation completed'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Done'));
    await tester.pumpAndSettle();

    // The scanner route should still be active; only the dialog should close.
    expect(find.text('Scanner Route'), findsOneWidget);
    expect(find.text('Operation completed'), findsNothing);
  });
}
