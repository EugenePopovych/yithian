// tool/gen_structure.dart
//
// Generates docs/structure.md with:
//  1) A docs index (flat list of *file names* from /docs, recursive)
//  2) A public-API overview of the code under lib/ (includes private type names)
//
// Usage:
//   dart run tool/gen_structure.dart
// Optional args:
//   --out=docs/structure.md   Change output path
//   --lib=lib                 Change scanned source dir
//   --docs=docs               Change docs dir to scan
//
// Requirements (add as dev dependency):
//   dart pub add --dev analyzer

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

const String scriptVersion = "0.1";

Future<void> main(List<String> args) async {
  final now = DateTime.now();
  final projectRoot = Directory.current.absolute.path;
  final libDir = _argValue(args, 'lib') ?? 'lib';
  final docsDir = _argValue(args, 'docs') ?? 'docs';
  final outPath = _argValue(args, 'out') ?? 'docs/structure.md';

  final libAbs = FileSystemEntity.isDirectorySync(libDir)
      ? Directory(libDir).absolute.path
      : Directory('lib').absolute.path;

  final docsAbs = FileSystemEntity.isDirectorySync(docsDir)
      ? Directory(docsDir).absolute.path
      : Directory('docs').absolute.path;

  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);

  final excludedSuffixes = <String>{
    '.g.dart',
    '.freezed.dart',
    '.gr.dart',
    '.chopper.dart',
    '.mocks.dart',
    '.gen.dart',
    '.pb.dart',
    '.pbenum.dart',
    '.pbjson.dart',
    '.graphql.dart',
    '.gql.dart',
    '.swagger.dart',
  };

  // ---------- Gather docs (filenames only, recursive, .md) ----------
  final docsIndex = _scanDocs(docsAbs);

  // ---------- Analyze lib/ ----------
  final contexts = AnalysisContextCollection(includedPaths: [projectRoot]);
  final buffer = StringBuffer();

  buffer.writeln('# Project Structure');
  buffer.writeln();
  buffer.writeln(
      '- Generated at: ${now.toIso8601String()}  \n- Generator: gen_structure.dart v$scriptVersion');
  buffer.writeln('- Root: `${_rel(projectRoot, projectRoot)}`');
  buffer.writeln('- Scanned code: `${_rel(libAbs, projectRoot)}`');
  buffer.writeln('- Scanned docs: `${_rel(docsAbs, projectRoot)}`');
  buffer.writeln();
  buffer.writeln('> This document lists **public APIs** found under `lib/` and the available **docs**.');
  buffer.writeln('> Private types are shown by name *(private)*; private members and generated files are skipped.');
  buffer.writeln();

  // ---------- Docs Section (always shown) ----------
  buffer.writeln('## Documentation (docs)');
  buffer.writeln();
  if (!docsIndex.exists) {
    buffer.writeln('_No `docs/` directory found._');
    buffer.writeln();
  } else if (docsIndex.files.isEmpty) {
    buffer.writeln('_No Markdown files were found under `docs/`._');
    buffer.writeln();
  } else {
    for (final name in docsIndex.files) {
      buffer.writeln('- $name');
    }
    buffer.writeln();
  }

  final perFile = <String, _FileDoc>{};
  final libAbsNorm = _norm(libAbs);

  for (final ctx in contexts.contexts) {
    final session = ctx.currentSession;

    final files = ctx.contextRoot.analyzedFiles().where((raw) {
      final pFs = _toFsPath(raw);
      final isDart = pFs.endsWith('.dart');
      final isExcluded = excludedSuffixes.any((suf) => pFs.endsWith(suf));
      final isUnderLib = _underDir(pFs, libAbsNorm);
      return isDart && isUnderLib && !isExcluded;
    }).toList()
      ..sort();

    for (final raw in files) {
      final path = _toFsPath(raw);
      final result = await session.getResolvedUnit(path);
      if (result is! ResolvedUnitResult) continue;

      final lib = result.libraryElement;
      if (lib == null) continue;

      // Get the unit element for this file.
      CompilationUnitElement? unitElem = result.unit.declaredElement;
      if (unitElem == null) {
        final normPath = _norm(path);
        for (final unit in lib.units) {
          if (_norm(unit.source.fullName) == normPath) {
            unitElem = unit;
            break;
          }
        }
      }
      if (unitElem == null) continue;

      // Collect imports from AST
      final imports = <String>[];
      for (final d in result.unit.directives) {
        if (d is ImportDirective) {
          final v = d.uri.stringValue;
          if (v != null && v.isNotEmpty) imports.add(v);
        }
      }

      final fileRel = _rel(path, projectRoot);
      final doc = perFile.putIfAbsent(
        fileRel,
        () => _FileDoc(
          path: fileRel,
          libraryName: lib.name,
          imports: imports.toSet().toList(),
        ),
      );

      // ===== Types (include private by name only) =====

      // Type aliases
      for (final ta in unitElem.typeAliases) {
        if (_isPrivate(ta.displayName)) {
          doc.typeAliases.add('`typedef ${ta.displayName}` *(private)*');
        } else {
          doc.typeAliases.add(_typeAliasSig(ta));
        }
      }

      // Enums
      for (final en in unitElem.enums) {
        if (_isPrivate(en.displayName)) {
          doc.enums.add('`enum ${en.displayName}` *(private)*');
        } else {
          doc.enums.add(_enumInfo(en));
        }
      }

      // Mixins
      for (final mx in unitElem.mixins) {
        if (_isPrivate(mx.displayName)) {
          doc.mixins.add('`mixin ${mx.displayName}` *(private)*');
        } else {
          doc.mixins.add(_mixinInfo(mx));
        }
      }

      // Extensions
      for (final ex in unitElem.extensions) {
        if (_isPrivate(ex.displayName)) {
          final onType = ex.extendedType.getDisplayString(withNullability: true);
          final name = ex.displayName.isEmpty ? '(unnamed)' : ex.displayName;
          doc.extensions.add('`extension $name on $onType` *(private)*');
        } else {
          doc.extensions.add(_extensionInfo(ex));
        }
      }

      // Classes
      for (final cl in unitElem.classes) {
        if (_isPrivate(cl.displayName)) {
          doc.classes.add('`class ${cl.displayName}` *(private)*');
        } else {
          doc.classes.add(_classInfo(cl));
        }
      }

      // ===== Top-level (public only) =====
      for (final fn in unitElem.functions) {
        if (_isPrivate(fn.displayName)) continue;
        doc.functions.add(_functionSig(fn));
      }
      for (final v in unitElem.topLevelVariables) {
        if (_isPrivate(v.displayName)) continue;
        doc.variables.add(_variableSig(v));
      }
    }
  }

  // Index
  final filesSorted = perFile.keys.toList()..sort();
  buffer.writeln('## Index');
  buffer.writeln();
  for (final f in filesSorted) {
    buffer.writeln('- [${f.replaceFirst(RegExp(r"^lib/"), "")}](#${_slug(f)})');
  }
  buffer.writeln();

  // Per-file sections
  for (final f in filesSorted) {
    final doc = perFile[f]!;
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('## ${f.replaceFirst(RegExp(r"^lib/"), "")}');
    if (doc.libraryName.isNotEmpty) {
      buffer.writeln('- **Library:** `${doc.libraryName}`');
    }
    if (doc.imports.isNotEmpty) {
      buffer.writeln('- **Imports (${doc.imports.length}):** '
          '${doc.imports.map((e) => '`$e`').join(', ')}');
    }
    buffer.writeln();

    void emitList(String title, List<String> lines) {
      if (lines.isEmpty) return;
      buffer.writeln('### $title');
      for (final line in lines) {
        buffer.writeln('- $line');
      }
      buffer.writeln();
    }

    emitList('Type Aliases', doc.typeAliases);
    emitList('Enums', doc.enums);
    emitList('Mixins', doc.mixins);
    emitList('Extensions', doc.extensions);
    emitList('Classes', doc.classes);
    emitList('Top-level Functions', doc.functions);
    emitList('Top-level Variables', doc.variables);
  }

  await outFile.writeAsString(buffer.toString());
  final totalFiles = filesSorted.length;
  final totalClasses =
      perFile.values.fold<int>(0, (a, b) => a + b.classes.length);
  final totalEnums = perFile.values.fold<int>(0, (a, b) => a + b.enums.length);
  stdout.writeln(
      'Wrote ${_rel(outFile.path, projectRoot)}  (files: $totalFiles, classes: $totalClasses, enums: $totalEnums)');
}

// ---------- Docs scanning (recursive, filenames only) ----------

class _DocsIndex {
  final List<String> files;
  final bool exists;
  _DocsIndex({required this.files, required this.exists});
}

_DocsIndex _scanDocs(String docsAbs) {
  final dir = Directory(docsAbs);
  final exists = dir.existsSync();
  if (!exists) return _DocsIndex(files: const [], exists: false);

  final names = dir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.md'))
      .map((f) => _basename(f.path))
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return _DocsIndex(files: names, exists: true);
}

String _basename(String path) {
  final n = _norm(path);
  final slash = n.lastIndexOf('/');
  return slash >= 0 ? n.substring(slash + 1) : n;
}

// ---------- Structures for code section ----------

class _FileDoc {
  final String path;
  final String libraryName;
  final List<String> imports;
  final List<String> typeAliases = [];
  final List<String> enums = [];
  final List<String> mixins = [];
  final List<String> extensions = [];
  final List<String> classes = [];
  final List<String> functions = [];
  final List<String> variables = [];

  _FileDoc({
    required this.path,
    required this.libraryName,
    required this.imports,
  });
}

// ----- Formatting helpers for PUBLIC members/types -----

String _typeAliasSig(TypeAliasElement e) {
  final DartType? aliased = e.aliasedType;
  final aliasedStr =
      aliased?.getDisplayString(withNullability: true) ?? 'dynamic';
  return '`typedef ${e.displayName} = $aliasedStr`';
}

String _enumInfo(EnumElement e) {
  final values = e.fields
      .where((f) => f.isEnumConstant && !_isPrivate(f.displayName))
      .map((f) => f.displayName)
      .toList();
  final methods = e.methods
      .where((m) => !_isPrivate(m.displayName))
      .map((m) => _methodSig(m))
      .toList();
  final buf = StringBuffer();
  buf.write('`enum ${e.displayName}`');
  if (values.isNotEmpty) {
    buf.write(' — values: ${values.map((v) => '`$v`').join(', ')}');
  }
  if (methods.isNotEmpty) {
    buf.write(' — methods: ${methods.join('; ')}');
  }
  return buf.toString();
}

String _mixinInfo(MixinElement e) {
  final methods = e.methods
      .where((m) => !_isPrivate(m.displayName))
      .map((m) => _methodSig(m))
      .toList();
  final fields = e.fields
      .where((f) => !_isPrivate(f.displayName))
      .map((f) => _fieldSig(f))
      .toList();
  final buf = StringBuffer();
  buf.write('`mixin ${e.displayName}`');
  if (fields.isNotEmpty) buf.write(' — fields: ${fields.join('; ')}');
  if (methods.isNotEmpty) {
    if (fields.isNotEmpty) buf.write(' — ');
    buf.write('methods: ${methods.join('; ')}');
  }
  return buf.toString();
}

String _extensionInfo(ExtensionElement e) {
  final onType = e.extendedType.getDisplayString(withNullability: true);
  final methods = e.methods
      .where((m) => !_isPrivate(m.displayName))
      .map((m) => _methodSig(m))
      .toList();
  final accessors = e.accessors
      .where((a) => !a.isSynthetic && !_isPrivate(a.displayName))
      .map((a) => _accessorSig(a))
      .toList();
  final buf = StringBuffer();
  buf.write('`extension ${e.displayName} on $onType`');
  final parts = <String>[];
  if (methods.isNotEmpty) parts.add('methods: ${methods.join('; ')}');
  if (accessors.isNotEmpty) parts.add('accessors: ${accessors.join(' — ')}');
  if (parts.isNotEmpty) buf.write(' — ${parts.join(' — ')}');
  return buf.toString();
}

String _classInfo(ClassElement c) {
  final constructors = c.constructors
      .where((k) => !_isPrivate(k.displayName))
      .map((k) => _ctorSig(c.displayName, k))
      .toList();

  final fields = c.fields
      .where((f) => !_isPrivate(f.displayName))
      .map((f) => _fieldSig(f))
      .toList();

  final accessors = c.accessors
      .where((a) => !a.isSynthetic && !_isPrivate(a.displayName))
      .map((a) => _accessorSig(a))
      .toList();

  final methods = c.methods
      .where((m) => !_isPrivate(m.displayName) && !m.isOperator)
      .map((m) => _methodSig(m))
      .toList();

  final buf = StringBuffer();
  buf.write('`class ${c.displayName}`');
  final parts = <String>[];
  if (constructors.isNotEmpty) {
    parts.add('ctors: ${constructors.join('; ')}');
  }
  if (fields.isNotEmpty) {
    parts.add('fields: ${fields.join('; ')}');
  }
  if (accessors.isNotEmpty) {
    parts.add('accessors: ${accessors.join('; ')}');
  }
  if (methods.isNotEmpty) {
    parts.add('methods: ${methods.join('; ')}');
  }
  if (parts.isNotEmpty) {
    buf.write(' — ${parts.join(' — ')}');
  }
  return buf.toString();
}

String _ctorSig(String className, ConstructorElement k) {
  final name = k.name.isEmpty ? className : '$className.${k.name}';
  final params = _formatParams(k.parameters);
  final prefix = k.isFactory ? 'factory ' : (k.isConst ? 'const ' : '');
  return '`$prefix$name($params)`';
}

String _methodSig(MethodElement m) {
  final ret = m.returnType.getDisplayString(withNullability: true);
  final params = _formatParams(m.parameters);
  final prefix = <String>[];
  if (m.isStatic) prefix.add('static');
  final pre = prefix.isEmpty ? '' : '${prefix.join(' ')} ';
  return '`$pre$ret ${m.displayName}($params)`';
}

String _accessorSig(PropertyAccessorElement a) {
  final type = a.returnType.getDisplayString(withNullability: true);
  final name = a.displayName;
  final prefix = <String>[];
  if (a.isStatic) prefix.add('static');
  if (a.isGetter) {
    final pre = prefix.isEmpty ? '' : '${prefix.join(' ')} ';
    return '`$pre$type get $name`';
  } else {
    final params = a.parameters
        .map((p) => '${p.type.getDisplayString(withNullability: true)} ${p.displayName}')
        .join(', ');
    final pre = prefix.isEmpty ? '' : '${prefix.join(' ')} ';
    return '`$pre set $name($params)`';
  }
}

String _fieldSig(FieldElement f) {
  final type = f.type.getDisplayString(withNullability: true);
  final name = f.displayName;
  final mods = <String>[];
  if (f.isStatic) mods.add('static');
  if (f.isConst) {
    mods.add('const');
  } else if (f.isFinal) {
    mods.add('final');
  }
  final prefix = mods.isEmpty ? '' : '${mods.join(' ')} ';
  return '`$prefix$type $name`';
}

String _functionSig(FunctionElement fn) {
  final ret = fn.returnType.getDisplayString(withNullability: true);
  final name = fn.displayName;
  final params = _formatParams(fn.parameters);
  final mods = <String>[];
  if (fn.isExternal) mods.add('external');
  final pre = mods.isEmpty ? '' : '${mods.join(' ')} ';
  return '`$pre$ret $name($params)`';
}

String _variableSig(VariableElement v) {
  final type = v.type.getDisplayString(withNullability: true);
  final name = v.displayName;
  final mods = <String>[];
  if (v.isConst) {
    mods.add('const');
  } else if (v.isFinal) {
    mods.add('final');
  }
  final prefix = mods.isEmpty ? '' : '${mods.join(' ')} ';
  return '`$prefix$type $name`';
}

String _formatParams(List<ParameterElement> params) {
  if (params.isEmpty) return '';
  final reqPos = <String>[];
  final optPos = <String>[];
  final named = <String>[];

  for (final p in params) {
    final t = p.type.getDisplayString(withNullability: true);
    final def = p.defaultValueCode;
    final defStr = def == null ? '' : ' = $def';
    final req = p.isRequiredNamed || p.isRequiredPositional ? 'required ' : '';
    final s = '$req$t ${p.displayName}$defStr';

    if (p.isRequiredPositional) {
      reqPos.add(s);
    } else if (p.isOptionalPositional) {
      optPos.add('$t ${p.displayName}$defStr');
    } else if (p.isNamed) {
      named.add(s);
    } else {
      reqPos.add('$t ${p.displayName}$defStr');
    }
  }

  final parts = <String>[];
  if (reqPos.isNotEmpty) parts.add(reqPos.join(', '));
  if (optPos.isNotEmpty) parts.add('[${optPos.join(', ')}]');
  if (named.isNotEmpty) parts.add('{${named.join(', ')}}');
  return parts.join(', ');
}

// ---------- Shared path helpers ----------

bool _isPrivate(String name) => name.startsWith('_');

bool _underDir(String path, String dirAbsNorm) {
  final normP = _norm(path);
  final normD = dirAbsNorm;
  return normP == normD || normP.startsWith('$normD/');
}

String _toFsPath(String p) {
  if (p.startsWith('file:')) {
    try {
      return File.fromUri(Uri.parse(p)).absolute.path;
    } catch (_) {
      return p;
    }
  }
  return p;
}

String _rel(String target, String base) {
  final t = _norm(File(target).absolute.path);
  final b = _norm(Directory(base).absolute.path);
  if (t == b) return '.';
  if (t.startsWith('$b/')) {
    return t.substring(b.length + 1);
  }
  return t;
}

String _norm(String p) {
  var s = p.replaceAll('\\', '/');
  if (s.length >= 2 && s[1] == ':') {
    s = '${s[0].toUpperCase()}${s.substring(1)}';
  }
  if (s.length > 3 && s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

String _slug(String s) => _rel(s, Directory.current.path)
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'-+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

String? _argValue(List<String> args, String key) {
  final prefix = '--$key=';
  for (final a in args) {
    if (a.startsWith(prefix)) return a.substring(prefix.length);
  }
  return null;
}
