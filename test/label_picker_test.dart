import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eli_contacts/features/contacts/presentation/label_picker.dart';

void main() {
  testWidgets('Les cercles se cumulent et les noms équivalents ne se dupliquent pas', (
    tester,
  ) async {
    var selected = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (context, setState) => LabelPicker(
          title: 'Cercles', inputLabel: 'Nouveau cercle',
          selected: selected, suggestions: const ['Famille', 'Amis'],
          onChanged: (value) => setState(() => selected = value),
        )),
      ),
    ));
    await tester.tap(find.text('Famille'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amis'));
    await tester.pumpAndSettle();
    expect(selected, ['Famille', 'Amis']);
    await tester.enterText(find.byType(TextField), ' famille ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(selected, ['Famille', 'Amis']);
    await tester.enterText(find.byType(TextField), '  Équipe   Jardin  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(selected, ['Famille', 'Amis', 'Équipe Jardin']);
    await tester.tap(find.text('Famille'));
    await tester.pumpAndSettle();
    expect(selected, ['Amis', 'Équipe Jardin']);
  });
}
