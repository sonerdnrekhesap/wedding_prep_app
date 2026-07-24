import 'dart:convert';
import 'dart:typed_data';

import '../models/app_settings_model.dart';
import '../models/guest_model.dart';
import '../models/item_model.dart';
import 'export_service.dart';

class PdfReportService {
  const PdfReportService();

  Uint8List buildPlanningReportPdf(
    AppSettings settings,
    List<PrepItem> items,
    List<Guest> guests,
  ) {
    final text = ExportService().buildPlanningReportText(
      settings,
      items,
      guests,
    );
    final lines = _wrapLines(_normalize(text), maxLength: 82);
    final pages = _paginate(lines, linesPerPage: 42);
    return _buildPdf(pages);
  }

  List<String> _wrapLines(String text, {required int maxLength}) {
    final output = <String>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        output.add('');
        continue;
      }

      var remaining = line;
      while (remaining.length > maxLength) {
        final splitAt = remaining.lastIndexOf(' ', maxLength);
        final index = splitAt <= 0 ? maxLength : splitAt;
        output.add(remaining.substring(0, index).trimRight());
        remaining = remaining.substring(index).trimLeft();
      }
      output.add(remaining);
    }
    return output;
  }

  List<List<String>> _paginate(List<String> lines,
      {required int linesPerPage}) {
    final pages = <List<String>>[];
    for (var index = 0; index < lines.length; index += linesPerPage) {
      final end = (index + linesPerPage).clamp(0, lines.length);
      pages.add(lines.sublist(index, end));
    }
    return pages.isEmpty ? [[]] : pages;
  }

  Uint8List _buildPdf(List<List<String>> pages) {
    final objects = <String>[];
    final pageRefs = <String>[];

    objects.add('<< /Type /Catalog /Pages 2 0 R >>');
    objects.add('');

    for (var pageIndex = 0; pageIndex < pages.length; pageIndex += 1) {
      final pageObjectNumber = objects.length + 1;
      final contentObjectNumber = pageObjectNumber + 1;
      pageRefs.add('$pageObjectNumber 0 R');

      objects.add(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        '/Resources << /Font << /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> >> >> '
        '/Contents $contentObjectNumber 0 R >>',
      );

      final stream = _pageStream(pages[pageIndex], pageIndex + 1, pages.length);
      objects.add(
        '<< /Length ${ascii.encode(stream).length} >>\nstream\n$stream\nendstream',
      );
    }

    objects[1] =
        '<< /Type /Pages /Kids [${pageRefs.join(' ')}] /Count ${pages.length} >>';

    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[0];
    for (var index = 0; index < objects.length; index += 1) {
      offsets.add(ascii.encode(buffer.toString()).length);
      buffer
        ..write('${index + 1} 0 obj\n')
        ..write(objects[index])
        ..write('\nendobj\n');
    }

    final xrefOffset = ascii.encode(buffer.toString()).length;
    buffer
      ..write('xref\n')
      ..write('0 ${objects.length + 1}\n')
      ..write('0000000000 65535 f \n');

    for (final offset in offsets.skip(1)) {
      buffer.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }

    buffer
      ..write('trailer\n')
      ..write('<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
      ..write('startxref\n')
      ..write('$xrefOffset\n')
      ..write('%%EOF');

    return Uint8List.fromList(ascii.encode(buffer.toString()));
  }

  String _pageStream(List<String> lines, int pageNumber, int pageCount) {
    final buffer = StringBuffer()
      ..writeln('BT')
      ..writeln('/F1 16 Tf')
      ..writeln('50 790 Td')
      ..writeln('(${_escapePdfText('Hazirlik Takibi Premium Rapor')}) Tj')
      ..writeln('/F1 11 Tf')
      ..writeln('0 -24 Td');

    for (final line in lines) {
      buffer
        ..writeln('(${_escapePdfText(line)}) Tj')
        ..writeln('0 -16 Td');
    }

    buffer
      ..writeln('/F1 9 Tf')
      ..writeln('0 -20 Td')
      ..writeln('(${_escapePdfText('Sayfa $pageNumber / $pageCount')}) Tj')
      ..writeln('ET');
    return buffer.toString();
  }

  String _escapePdfText(String value) {
    return value.replaceAll('\\', '\\\\').replaceAll('(', r'\(').replaceAll(
          ')',
          r'\)',
        );
  }

  String _normalize(String value) {
    const replacements = {
      'ç': 'c',
      'Ç': 'C',
      'ğ': 'g',
      'Ğ': 'G',
      'ı': 'i',
      'İ': 'I',
      'ö': 'o',
      'Ö': 'O',
      'ş': 's',
      'Ş': 'S',
      'ü': 'u',
      'Ü': 'U',
    };

    var output = value;
    for (final entry in replacements.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output.runes
        .map((rune) => rune >= 32 && rune <= 126 || rune == 10 ? rune : 32)
        .map(String.fromCharCode)
        .join();
  }
}
