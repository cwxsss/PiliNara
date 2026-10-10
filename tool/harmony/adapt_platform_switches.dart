import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class V extends RecursiveAstVisitor<void> {
  final String source;
  final List<(int, String)> edits = [];
  V(this.source);
  bool platform(String t) =>
      t.contains('TargetPlatform.') ||
      (t.contains('.android') && t.contains('.iOS') && t.contains('.windows'));
  @override
  void visitSwitchStatement(SwitchStatement n) {
    super.visitSwitchStatement(n);
    if (!platform(n.toSource()) || n.members.any((m) => m is SwitchDefault))
      return;
    for (final m in n.members) {
      final h = source.substring(
        m.offset,
        m.statements.isEmpty ? m.end : m.statements.first.offset,
      );
      if (RegExp(r'(?:TargetPlatform)?\.android\b').hasMatch(h)) {
        final index = n.members.indexOf(m);
        var body = m.statements;
        for (var i = index + 1; body.isEmpty && i < n.members.length; i++) {
          body = n.members[i].statements;
        }
        if (body.isEmpty) {
          edits.add((n.rightBracket.offset, '\ndefault:\n  break;\n'));
          return;
        }
        final text = source.substring(body.first.offset, body.last.end);
        edits.add((n.rightBracket.offset, '\ndefault:\n' + text + '\n'));
        return;
      }
    }
  }

  @override
  void visitSwitchExpression(SwitchExpression n) {
    super.visitSwitchExpression(n);
    if (!platform(n.toSource()) ||
        n.cases.any((c) => c.guardedPattern.pattern is WildcardPattern))
      return;
    for (final c in n.cases) {
      if (RegExp(r'(?:TargetPlatform)?\.android\b')
          .hasMatch(c.guardedPattern.toSource())) {
        final e = source.substring(c.expression.offset, c.expression.end);
        final comma =
            source
                .substring(n.cases.last.end, n.rightBracket.offset)
                .contains(',')
            ? ''
            : ',';
        edits.add((n.rightBracket.offset, comma + '\n_ => ' + e + ',\n'));
        return;
      }
    }
  }
}

void main(List<String> args) {
  int count = 0;
  for (final folder in args) {
    final f = File(folder);
    final entities = f.existsSync()
        ? [f]
        : Directory(folder).listSync(recursive: true, followLinks: false);
    for (final entity in entities) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      var source = entity.readAsStringSync();
      final parsed = parseString(content: source, throwIfDiagnostics: false);
      final v = V(source);
      parsed.unit.accept(v);
      v.edits.sort((a, b) => b.$1.compareTo(a.$1));
      for (final edit in v.edits) {
        source =
            source.substring(0, edit.$1) + edit.$2 + source.substring(edit.$1);
      }
      if (v.edits.isNotEmpty) {
        final check = parseString(content: source, throwIfDiagnostics: false);
        final introduced = check.errors.where(
          (e) => !parsed.errors.any((old) => old.errorCode == e.errorCode),
        );
        if (introduced.isNotEmpty)
          throw StateError(entity.path + introduced.toString());
        entity.writeAsStringSync(source);
        count += v.edits.length;
        stdout.writeln(entity.path + ': ' + v.edits.length.toString());
      }
    }
  }
  stdout.writeln('Adapted ' + count.toString() + ' platform switches.');
}
