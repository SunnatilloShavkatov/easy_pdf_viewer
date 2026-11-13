// Regenerates lib/src/bindings/easy_pdf_viewer_darwin.g.dart and the Objective-C wrapper
// darwin/easy_pdf_viewer/Sources/easy_pdf_viewer_c/easy_pdf_viewer_darwin.m from easy_pdf_viewer_api.h.
// Run from the package root: `dart run tool/ffigen.dart`.
import 'dart:io';

import 'package:ffigen/ffigen.dart';

Future<void> main() async {
  final Uri packageRoot = Platform.script.resolve('../');
  final Uri cSources = packageRoot.resolve('darwin/easy_pdf_viewer/Sources/easy_pdf_viewer_c/');
  await FfiGenerator(
    output: Output(
      dart: DartOutput(path: packageRoot.resolve('lib/src/bindings/easy_pdf_viewer_darwin.g.dart')),
      objectiveCFile: cSources.resolve('easy_pdf_viewer_darwin.m'),
    ),
    objectiveC: const ObjectiveC(),
    input: Input(entryPoints: <Uri>[cSources.resolve('easy_pdf_viewer_api.h')]),
    visitors: <Visitor>[
      Visitor(
        objCInterface: (node) {
          if (node.originalName == 'EasyPdfViewerApi') {
            node.isIncluded = true;
          }
        },
      ),
    ],
  ).generate();
  _sortPackageImports(File.fromUri(packageRoot.resolve('lib/src/bindings/easy_pdf_viewer_darwin.g.dart')));
}

// ffigen emits `ffi` before `objective_c`; the repo's import order (arch-guard) wants alphabetical.
void _sortPackageImports(File file) {
  final List<String> lines = file.readAsLinesSync();
  final List<String> out = <String>[];
  int i = 0;
  while (i < lines.length) {
    if (!lines[i].startsWith("import 'package:")) {
      out.add(lines[i++]);
      continue;
    }
    final List<String> block = <String>[];
    while (i < lines.length && lines[i].startsWith("import 'package:")) {
      block.add(lines[i++]);
    }
    block.sort();
    out.addAll(block);
  }
  file.writeAsStringSync('${out.join('\n')}\n');
}
