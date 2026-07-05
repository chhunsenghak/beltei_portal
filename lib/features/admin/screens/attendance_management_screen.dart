import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

// ── Grouped-list item types ───────────────────────────────────────────────────

enum _ItemKind { faculty, major, course, record }

class _Item {
  final _ItemKind kind;
  final String? label;
  final String? sublabel;
  final AdminAttendanceRecord? rec;
  _Item._({required this.kind, this.label, this.sublabel, this.rec});

  factory _Item.faculty(String name) =>
      _Item._(kind: _ItemKind.faculty, label: name);
  factory _Item.major(String name) =>
      _Item._(kind: _ItemKind.major, label: name);
  factory _Item.course(String name, String sub) =>
      _Item._(kind: _ItemKind.course, label: name, sublabel: sub);
  factory _Item.record(AdminAttendanceRecord r) =>
      _Item._(kind: _ItemKind.record, rec: r);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AttendanceManagementScreen extends ConsumerStatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  ConsumerState<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends ConsumerState<AttendanceManagementScreen> {
  // ── filter state ─────────────────────────────────────────────────────────
  String? _yearFilter;
  String? _facultyFilter;    // facultyId
  String? _majorFilter;      // majorId
  int?    _yearLevelFilter;
  String? _semesterFilter;   // semesterId
  String? _courseFilter;     // courseId
  String? _classFilter;      // "yearLevel|majorId" derived class key
  final TextEditingController _studentCtrl = TextEditingController();

  // ── bulk edit ─────────────────────────────────────────────────────────────
  bool _bulkEditMode = false;
  final Set<String> _selected = {};
  bool _isProcessing = false;
  bool _isExporting = false;

  // ── filter panel visibility ───────────────────────────────────────────────
  bool _filtersExpanded = true;

  @override
  void dispose() {
    _studentCtrl.dispose();
    super.dispose();
  }

  // ── filter helpers ────────────────────────────────────────────────────────

  List<AdminAttendanceRecord> _applyFilter(
      List<AdminAttendanceRecord> all) {
    return all.where((r) {
      if (_yearFilter != null && r.academicYear != _yearFilter) return false;
      if (_facultyFilter != null && r.facultyId != _facultyFilter) return false;
      if (_majorFilter != null && r.majorId != _majorFilter) return false;
      if (_yearLevelFilter != null && r.yearLevel != _yearLevelFilter) return false;
      if (_semesterFilter != null && r.semesterId != _semesterFilter) return false;
      if (_courseFilter != null && r.courseId != _courseFilter) return false;
      if (_classFilter != null) {
        final parts = _classFilter!.split('|');
        final yl  = int.tryParse(parts[0]);
        final mid = parts.length > 1 ? parts[1] : null;
        if (yl  != null && r.yearLevel != yl)  return false;
        if (mid != null && r.majorId   != mid) return false;
      }
      final q = _studentCtrl.text.trim().toLowerCase();
      if (q.isNotEmpty &&
          !r.studentName.toLowerCase().contains(q) &&
          !r.studentCode.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<_Item> _buildGrouped(List<AdminAttendanceRecord> records) {
    // faculty → major → course → [records]
    final tree = <String, Map<String, Map<String, List<AdminAttendanceRecord>>>>{};
    final facultyNames = <String, String>{}; // facultyId → name
    final majorNames   = <String, String>{};
    final courseNames  = <String, ({String name, String sem})>{};

    for (final r in records) {
      final fid = r.facultyId ?? '__none__';
      final mid = r.majorId   ?? '__none__';
      final cid = r.courseId;
      facultyNames[fid] = r.facultyName ?? '(No Faculty)';
      majorNames[mid]   = r.majorName   ?? '(No Major)';
      courseNames[cid]  = (
        name: r.courseName,
        sem:  [r.semesterName, r.academicYear].whereType<String>().join(' • '),
      );
      tree.putIfAbsent(fid, () => {});
      tree[fid]!.putIfAbsent(mid, () => {});
      tree[fid]![mid]!.putIfAbsent(cid, () => []);
      tree[fid]![mid]![cid]!.add(r);
    }

    final items = <_Item>[];
    final sortedFac = tree.keys.toList()
      ..sort((a, b) => facultyNames[a]!.compareTo(facultyNames[b]!));

    for (final fid in sortedFac) {
      items.add(_Item.faculty(facultyNames[fid]!));
      final majors = tree[fid]!;
      final sortedMaj = majors.keys.toList()
        ..sort((a, b) => majorNames[a]!.compareTo(majorNames[b]!));

      for (final mid in sortedMaj) {
        items.add(_Item.major(majorNames[mid]!));
        final courses = majors[mid]!;
        final sortedCrs = courses.keys.toList()
          ..sort((a, b) => courseNames[a]!.name.compareTo(courseNames[b]!.name));

        for (final cid in sortedCrs) {
          final ci = courseNames[cid]!;
          items.add(_Item.course(ci.name, ci.sem));
          for (final r in courses[cid]!) {
            items.add(_Item.record(r));
          }
        }
      }
    }
    return items;
  }

  bool get _hasFilter =>
      _yearFilter != null ||
      _facultyFilter != null ||
      _majorFilter != null ||
      _yearLevelFilter != null ||
      _semesterFilter != null ||
      _courseFilter != null ||
      _classFilter != null ||
      _studentCtrl.text.trim().isNotEmpty;

  void _resetFilters() => setState(() {
        _yearFilter = null;
        _facultyFilter = null;
        _majorFilter = null;
        _yearLevelFilter = null;
        _semesterFilter = null;
        _courseFilter = null;
        _classFilter = null;
        _studentCtrl.clear();
      });

  // ── bulk actions ──────────────────────────────────────────────────────────

  Future<void> _applyBulkAction(String action) async {
    if (_selected.isEmpty) return;
    final ids = _selected.toList();

    if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Records?'),
          content: Text(
            'Delete ${ids.length} record${ids.length == 1 ? '' : 's'}? '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusRed),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _isProcessing = true);
    try {
      final svc = ref.read(adminServiceProvider);
      if (action == 'delete') {
        await svc.deleteAttendanceRecords(ids);
      } else {
        await svc.updateAttendanceStatuses(ids, action);
      }
      ref.invalidate(adminAttendanceProvider);
      if (mounted) setState(() => _selected.clear());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.statusRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Export ────────────────────────────────────────────────────────────────

  void _showExportPicker(List<AdminAttendanceRecord> records) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExportFormatSheet(
        recordCount: records.length,
        onFormat: (fmt) async {
          if (!mounted) return;
          setState(() => _isExporting = true);
          try {
            switch (fmt) {
              case 'pdf':   await _exportPdf(records);
              case 'excel': await _exportExcel(records);
              case 'csv':   await _exportCsv(records);
            }
          } finally {
            if (mounted) setState(() => _isExporting = false);
          }
        },
      ),
    );
  }

  Future<void> _exportCsv(List<AdminAttendanceRecord> records) async {
    final buf = StringBuffer();
    buf.writeln('Faculty,Major,Course,Semester,Academic Year,'
        'Student Code,Student Name,Year Level,Date,Status');
    for (final r in records) {
      buf.writeln([
        _esc(r.facultyName ?? ''),
        _esc(r.majorName ?? ''),
        _esc(r.courseName),
        _esc(r.semesterName ?? ''),
        _esc(r.academicYear ?? ''),
        _esc(r.studentCode),
        _esc(r.studentName),
        r.yearLevel?.toString() ?? '',
        r.date,
        r.status,
      ].join(','));
    }
    final file = await _saveBytes(
        buf.toString().codeUnits.map((e) => e).toList(), 'csv');
    if (mounted) _showExportSuccess(file, records.length, 'CSV');
  }

  Future<void> _exportExcel(List<AdminAttendanceRecord> records) async {
    final xcel = Excel.createExcel();
    xcel.delete('Sheet1');
    final sheet = xcel['Attendance'];

    const headers = [
      'Faculty', 'Major', 'Course', 'Semester', 'Academic Year',
      'Student Code', 'Student Name', 'Year Level', 'Date', 'Status',
    ];
    const widths = [22.0, 22.0, 28.0, 18.0, 14.0, 14.0, 28.0, 10.0, 14.0, 10.0];

    // Header row
    for (int j = 0; j < headers.length; j++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 0));
      cell.value = TextCellValue(headers[j]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
      sheet.setColumnWidth(j, widths[j]);
    }

    // Data rows
    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      final isEven = i.isEven;
      final bg = ExcelColor.fromHexString(isEven ? '#FFFFFF' : '#F8F9FF');
      final statusColor = ExcelColor.fromHexString(
        r.status == 'present' ? '#059669' :
        r.status == 'absent'  ? '#DC2626' :
        r.status == 'late'    ? '#D97706' : '#6B7280',
      );
      final values = [
        r.facultyName ?? '', r.majorName ?? '', r.courseName,
        r.semesterName ?? '', r.academicYear ?? '',
        r.studentCode, r.studentName,
        r.yearLevel?.toString() ?? '', r.date, r.status,
      ];
      for (int j = 0; j < values.length; j++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
        cell.value = TextCellValue(values[j]);
        cell.cellStyle = CellStyle(
          backgroundColorHex: bg,
          fontColorHex:
              j == 9 ? statusColor : ExcelColor.fromHexString('#111827'),
          bold: j == 9,
        );
      }
    }

    final bytes = xcel.encode() ?? [];
    final file = await _saveBytes(bytes, 'xlsx');
    if (mounted) _showExportSuccess(file, records.length, 'Excel');
  }

  Future<void> _exportPdf(List<AdminAttendanceRecord> records) async {
    // Build grouped tree
    final tree =
        <String, Map<String, Map<String, List<AdminAttendanceRecord>>>>{};
    final facNames = <String, String>{};
    final majNames = <String, String>{};
    final crsNames = <String, String>{};
    for (final r in records) {
      final fid = r.facultyId ?? '__';
      final mid = r.majorId   ?? '__';
      final cid = r.courseId;
      facNames[fid] = r.facultyName ?? '(No Faculty)';
      majNames[mid] = r.majorName   ?? '(No Major)';
      crsNames[cid] = r.courseName;
      tree.putIfAbsent(fid, () => {});
      tree[fid]!.putIfAbsent(mid, () => {});
      tree[fid]![mid]!.putIfAbsent(cid, () => []);
      tree[fid]![mid]![cid]!.add(r);
    }

    final sortedFac = tree.keys.toList()
      ..sort((a, b) => facNames[a]!.compareTo(facNames[b]!));

    final doc = pw.Document();

    final content = <pw.Widget>[
      // ── report title ─────────────────────────────────────────────────────
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('BELTEI Portal',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.blueGrey500)),
            pw.Text('Attendance Report',
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${DateFormat('MMMM d, yyyy · HH:mm').format(DateTime.now())}'
              '   ·   ${records.length} record${records.length == 1 ? '' : 's'}',
              style: const pw.TextStyle(
                  fontSize: 8.5, color: PdfColors.blueGrey500)),
            pw.Divider(color: PdfColors.blueGrey100, thickness: 1),
          ],
        ),
      ),
    ];

    // ── sections ─────────────────────────────────────────────────────────────
    for (final fid in sortedFac) {
      // Faculty banner
      content.add(pw.Container(
        margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
        child: pw.Row(children: [
          pw.Text(facNames[fid]!.toUpperCase(),
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8.5,
                  letterSpacing: 0.6)),
        ]),
      ));

      final majors = tree[fid]!;
      final sortedMaj = majors.keys.toList()
        ..sort((a, b) => majNames[a]!.compareTo(majNames[b]!));

      for (final mid in sortedMaj) {
        // Major sub-banner
        content.add(pw.Container(
          margin: const pw.EdgeInsets.only(top: 6, bottom: 2, left: 10),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.blueGrey50,
            border: const pw.Border(
                left: pw.BorderSide(color: PdfColors.blue, width: 3)),
          ),
          child: pw.Text(majNames[mid]!,
              style: pw.TextStyle(
                  color: PdfColors.blueGrey800,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8)),
        ));

        final courses = majors[mid]!;
        final sortedCrs = courses.keys.toList()
          ..sort((a, b) => crsNames[a]!.compareTo(crsNames[b]!));

        for (final cid in sortedCrs) {
          // Course label
          content.add(pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20, top: 4, bottom: 2),
            child: pw.Text(crsNames[cid]!,
                style: pw.TextStyle(
                    fontSize: 7.5,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.blueGrey600)),
          ));

          // Student table
          final rows = courses[cid]!;
          content.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 20, right: 0, bottom: 8),
            child: pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColors.blueGrey100, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4), // Code
                1: const pw.FlexColumnWidth(2.4), // Name
                2: const pw.FlexColumnWidth(0.7), // Year
                3: const pw.FlexColumnWidth(1.6), // Date
                4: const pw.FlexColumnWidth(1.0), // Status
              },
              children: [
                // col headers
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.blueGrey50),
                  children: ['Code', 'Student Name', 'Yr', 'Date', 'Status']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 5, vertical: 3),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 7,
                                    color: PdfColors.blueGrey700)),
                          ))
                      .toList(),
                ),
                // data rows
                ...rows.asMap().entries.map((e) {
                  final idx = e.key;
                  final r   = e.value;
                  final sc = r.status == 'present' ? PdfColors.green700
                      : r.status == 'absent'       ? PdfColors.red700
                      : r.status == 'late'         ? PdfColors.orange700
                      : PdfColors.blueGrey500;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: idx.isEven
                            ? PdfColors.white
                            : const PdfColor(0.97, 0.98, 1.0)),
                    children: [
                      _pdfCell(r.studentCode),
                      _pdfCell(r.studentName),
                      _pdfCell(r.yearLevel?.toString() ?? '—'),
                      _pdfCell(r.fmtDate),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 5, vertical: 3),
                        child: pw.Text(r.status,
                            style: pw.TextStyle(
                                fontSize: 7,
                                color: sc,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ));
        }
      }
    }

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 40),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(
                fontSize: 8, color: PdfColors.blueGrey400)),
      ),
      build: (_) => content,
    ));

    final bytes = await doc.save();
    final file = await _saveBytes(bytes, 'pdf');
    if (mounted) _showExportSuccess(file, records.length, 'PDF');
  }

  // ── file save helper ──────────────────────────────────────────────────────

  Future<String> _saveBytes(List<int> bytes, String ext) async {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';
    final dir = Directory(
        Platform.isWindows ? '$home\\Downloads' : '$home/Downloads');
    if (!await dir.exists()) await dir.create(recursive: true);
    final ts   = DateTime.now();
    final name = 'attendance_${ts.year}${_pad(ts.month)}${_pad(ts.day)}'
        '_${_pad(ts.hour)}${_pad(ts.minute)}.$ext';
    final file = File('${dir.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void _showExportSuccess(String filePath, int rowCount, String format) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExportSuccessSheet(
        filePath: filePath,
        rowCount: rowCount,
        format: format,
      ),
    );
  }

  static pw.Widget _pdfCell(String text) => pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 7)),
      );

  static String _esc(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminAttendanceProvider);

    // Pre-load reference data so filter dropdowns always show all options
    final allFaculties =
        ref.watch(adminFacultiesProvider).valueOrNull ?? [];
    final allMajors =
        ref.watch(adminMajorsProvider).valueOrNull ?? [];
    final allSemesters =
        ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final allCourses =
        ref.watch(adminAllCoursesProvider).valueOrNull ?? [];

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: AppColors.statusRed, size: 40),
            const SizedBox(height: 8),
            Text('Could not load attendance data',
                style: AppTextStyles.body),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(adminAttendanceProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (allRecords) {
        final filtered = _applyFilter(allRecords);
        final items    = _buildGrouped(filtered);

        return Column(
          children: [
            _buildHeader(allRecords, filtered),
            if (_filtersExpanded)
              _buildFilterPanel(allRecords, allFaculties, allMajors, allSemesters, allCourses),
            _buildTableHeader(),
            Expanded(child: _buildList(items)),
            if (_bulkEditMode && _selected.isNotEmpty) _buildBulkBar(),
          ],
        );
      },
    );
  }

  // ── header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
      List<AdminAttendanceRecord> all,
      List<AdminAttendanceRecord> filtered) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance Management',
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.primaryNavy)),
                    const SizedBox(height: 2),
                    Text(
                      _hasFilter
                          ? '${filtered.length} of ${all.length} records'
                          : '${all.length} records',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              // Export
              SizedBox(
                width: 120,
                child: ElevatedButton.icon(
                  onPressed: (_isExporting || filtered.isEmpty)
                      ? null
                      : () => _showExportPicker(filtered),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.file_download_outlined,
                          size: 14, color: Colors.white),
                  label: Text(
                      _isExporting ? 'Exporting…' : 'Export',
                      style:
                          AppTextStyles.button.copyWith(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    disabledBackgroundColor:
                        AppColors.primaryNavy.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Bulk edit toggle
              Text('Bulk Edit',
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Switch(
                value: _bulkEditMode,
                onChanged: _isProcessing
                    ? null
                    : (v) => setState(() {
                          _bulkEditMode = v;
                          if (!v) _selected.clear();
                        }),
                activeThumbColor: AppColors.primaryBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Spacer(),
              // Filter toggle
              if (_hasFilter)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.close,
                            size: 12, color: AppColors.statusRed),
                        const SizedBox(width: 3),
                        Text('Clear filters',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.statusRed)),
                      ]),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () =>
                    setState(() => _filtersExpanded = !_filtersExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _filtersExpanded
                          ? Icons.filter_list_off
                          : Icons.filter_list,
                      size: 14,
                      color: _hasFilter
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _filtersExpanded ? 'Hide Filters' : 'Filters',
                      style: AppTextStyles.caption.copyWith(
                          color: _hasFilter
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── filter panel ──────────────────────────────────────────────────────────

  // Derive a short class code from major name words + year level.
  // e.g. "Computer Science" Year 1 → "Y1CS"
  String _classCode(String majorName, int yearLevel) {
    final initials = majorName
        .split(RegExp(r'[\s\-/]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join();
    return 'Y$yearLevel$initials';
  }

  Widget _buildFilterPanel(
    List<AdminAttendanceRecord> all,
    List<AdminFaculty> allFaculties,
    List<AdminMajor> allMajors,
    List<AdminSemester> allSemesters,
    List<AdminCourse> allCourses,
  ) {
    // ── cascade data preparation ──────────────────────────────────────────────

    final years = allSemesters
        .map((s) => s.academicYear)
        .toSet()
        .toList()
      ..sort();

    final sortedFaculties = allFaculties.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Majors cascade: filtered by selected faculty
    final filteredMajors = allMajors.where((m) {
      if (_facultyFilter == null) return true;
      return m.facultyId == _facultyFilter;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    const yearLevels = [1, 2, 3, 4];

    // Semesters: show all, sorted by year desc then name
    final filteredSemesters = allSemesters.toList()
      ..sort((a, b) {
        final y = b.academicYear.compareTo(a.academicYear);
        return y != 0 ? y : a.name.compareTo(b.name);
      });

    // Courses cascade: filtered by faculty (courses have no semester of their
    // own anymore — a course can be taught in many semesters via different
    // class terms, so year/semester filtering happens on the attendance
    // records themselves below, not on the course list).
    final filteredCourses = allCourses.where((c) {
      if (_facultyFilter != null && c.facultyId != _facultyFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Class cascade: unique (yearLevel, majorId) combos from attendance records
    // filtered by faculty, major, year level, semester, course selections
    final majorNameById = {for (final m in allMajors) m.id: m.name};
    final classKeys = <String, String>{};
    for (final r in all) {
      if (_facultyFilter != null && r.facultyId != _facultyFilter) continue;
      if (_majorFilter != null && r.majorId != _majorFilter) continue;
      if (_yearLevelFilter != null && r.yearLevel != _yearLevelFilter) continue;
      if (_semesterFilter != null && r.semesterId != _semesterFilter) continue;
      if (_courseFilter != null && r.courseId != _courseFilter) continue;
      if (r.yearLevel == null || r.majorId == null) continue;
      final key = '${r.yearLevel}|${r.majorId}';
      final majorName = majorNameById[r.majorId] ?? r.majorName ?? r.majorId!;
      final code = _classCode(majorName, r.yearLevel!);
      classKeys[key] = '$code · Year ${r.yearLevel} $majorName';
    }
    final sortedClasses = classKeys.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // ── widget ────────────────────────────────────────────────────────────────

    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 0, color: AppColors.divider),
          const SizedBox(height: 12),

          // Row 1: Academic Year | Faculty
          Row(children: [
            Expanded(
              child: _FilterDrop<String>(
                label: 'Academic Year',
                value: _yearFilter,
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                hint: 'All Years',
                onChanged: (v) => setState(() {
                  _yearFilter = v;
                  _semesterFilter = null;
                  _courseFilter = null;
                  _classFilter = null;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDrop<String>(
                label: 'Faculty',
                value: _facultyFilter,
                items: sortedFaculties
                    .map((f) => DropdownMenuItem(
                        value: f.id, child: Text(f.name)))
                    .toList(),
                hint: 'All Faculties',
                onChanged: (v) => setState(() {
                  _facultyFilter = v;
                  if (_majorFilter != null &&
                      !filteredMajors.any((m) => m.id == _majorFilter)) {
                    _majorFilter = null;
                  }
                  _courseFilter = null;
                  _classFilter = null;
                }),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Row 2: Major | Year Level
          Row(children: [
            Expanded(
              child: _FilterDrop<String>(
                label: 'Major',
                value: filteredMajors.any((m) => m.id == _majorFilter)
                    ? _majorFilter
                    : null,
                items: filteredMajors
                    .map((m) => DropdownMenuItem(
                        value: m.id, child: Text(m.name)))
                    .toList(),
                hint: 'All Majors',
                onChanged: (v) => setState(() {
                  _majorFilter = v;
                  _classFilter = null;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDrop<int>(
                label: 'Year Level',
                value: _yearLevelFilter,
                items: yearLevels
                    .map((y) => DropdownMenuItem(
                        value: y, child: Text('Year $y')))
                    .toList(),
                hint: 'All Years',
                onChanged: (v) => setState(() {
                  _yearLevelFilter = v;
                  _classFilter = null;
                }),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Row 3: Semester | Course
          Row(children: [
            Expanded(
              child: _FilterDrop<String>(
                label: 'Semester',
                value: filteredSemesters.any((s) => s.id == _semesterFilter)
                    ? _semesterFilter
                    : null,
                items: filteredSemesters
                    .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                hint: 'All Semesters',
                onChanged: (v) => setState(() {
                  _semesterFilter = v;
                  _courseFilter = null;
                  _classFilter = null;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterDrop<String>(
                label: 'Course',
                value: filteredCourses.any((c) => c.courseId == _courseFilter)
                    ? _courseFilter
                    : null,
                items: filteredCourses
                    .map((c) => DropdownMenuItem(
                        value: c.courseId,
                        child: Text(c.name,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                hint: 'All Courses',
                onChanged: (v) => setState(() {
                  _courseFilter = v;
                  _classFilter = null;
                }),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Row 4: Class (searchable) | Student search
          Row(children: [
            Expanded(
              child: _SearchableClassPicker(
                label: 'Class',
                value: sortedClasses.any((e) => e.key == _classFilter)
                    ? _classFilter
                    : null,
                options: sortedClasses,
                hint: 'All Classes',
                onChanged: (v) => setState(() => _classFilter = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _studentCtrl,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.body.copyWith(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Name or ID',
                        hintStyle: AppTextStyles.caption,
                        prefixIcon: Icon(Icons.search,
                            size: 14, color: AppColors.textSecondary),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 32),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ── table column header ───────────────────────────────────────────────────

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF1F3F9),
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          if (_bulkEditMode) const SizedBox(width: 32),
          Expanded(
              flex: 3,
              child: _colHead('STUDENT')),
          Expanded(
              flex: 2,
              child: _colHead('YEAR / MAJOR')),
          Expanded(
              flex: 2,
              child: _colHead('DATE')),
          _colHead('ST'),
        ],
      ),
    );
  }

  Widget _colHead(String t) => Text(t,
      style: AppTextStyles.label
          .copyWith(fontSize: 9, letterSpacing: 0.5));

  // ── list ──────────────────────────────────────────────────────────────────

  Widget _buildList(List<_Item> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 36, color: AppColors.textSecondary.withValues(alpha: .5)),
            const SizedBox(height: 8),
            Text('No records match the current filters',
                style: AppTextStyles.caption),
            if (_hasFilter) ...[
              const SizedBox(height: 6),
              TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Clear filters')),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        switch (item.kind) {
          case _ItemKind.faculty:
            return _FacultyHeader(name: item.label!);
          case _ItemKind.major:
            return _MajorHeader(name: item.label!);
          case _ItemKind.course:
            return _CourseHeader(
                name: item.label!, semester: item.sublabel ?? '');
          case _ItemKind.record:
            return _RecordRow(
              record: item.rec!,
              bulkMode: _bulkEditMode,
              selected: _selected.contains(item.rec!.id),
              onToggle: () => setState(() {
                if (_selected.contains(item.rec!.id)) {
                  _selected.remove(item.rec!.id);
                } else {
                  _selected.add(item.rec!.id);
                }
              }),
            );
        }
      },
    );
  }

  // ── bulk bar ──────────────────────────────────────────────────────────────

  Widget _buildBulkBar() {
    return Container(
      height: 56,
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('${_selected.length} selected',
              style: AppTextStyles.captionWhite),
          const Spacer(),
          _BulkBtn(
              label: 'Present',
              color: AppColors.statusGreen,
              enabled: !_isProcessing,
              onTap: () => _applyBulkAction('present')),
          const SizedBox(width: 8),
          _BulkBtn(
              label: 'Absent',
              color: AppColors.statusAmber,
              enabled: !_isProcessing,
              onTap: () => _applyBulkAction('absent')),
          const SizedBox(width: 8),
          _BulkBtn(
              label: _isProcessing ? '…' : 'Delete',
              color: AppColors.statusRed,
              enabled: !_isProcessing,
              onTap: () => _applyBulkAction('delete')),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FacultyHeader extends StatelessWidget {
  const _FacultyHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      color: AppColors.primaryNavy.withValues(alpha: 0.06),
      child: Row(children: [
        Icon(Icons.account_balance_outlined,
            size: 13, color: AppColors.primaryNavy),
        const SizedBox(width: 6),
        Expanded(
          child: Text(name,
              style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryNavy,
                  fontSize: 11,
                  letterSpacing: 0.3)),
        ),
      ]),
    );
  }
}

class _MajorHeader extends StatelessWidget {
  const _MajorHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 8, 16, 4),
      color: AppColors.primaryBlue.withValues(alpha: 0.04),
      child: Row(children: [
        Icon(Icons.school_outlined,
            size: 11, color: AppColors.primaryBlue),
        const SizedBox(width: 5),
        Expanded(
          child: Text(name,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
        ),
      ]),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.name, required this.semester});
  final String name;
  final String semester;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 6, 16, 4),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.primaryBlue, width: 2)),
        color: Color(0xFFF8F9FF),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600, fontSize: 11)),
        if (semester.isNotEmpty)
          Text(semester,
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.record,
    required this.bulkMode,
    required this.selected,
    required this.onToggle,
  });
  final AdminAttendanceRecord record;
  final bool bulkMode;
  final bool selected;
  final VoidCallback onToggle;

  Color get _statusColor {
    switch (record.status) {
      case 'present': return AppColors.statusGreen;
      case 'absent':  return AppColors.statusRed;
      case 'late':    return AppColors.statusAmber;
      default:        return AppColors.statusGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: bulkMode ? onToggle : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: selected
            ? AppColors.primaryNavy.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(children: [
          if (bulkMode)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 26,
                height: 26,
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.primaryNavy,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          // Student
          Expanded(
            flex: 3,
            child: Row(children: [
              CircleAvatar(
                radius: 13,
                backgroundColor:
                    AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(record.initials,
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryNavy, fontSize: 9)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.studentName,
                        style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(record.studentCode,
                        style: AppTextStyles.label
                            .copyWith(fontSize: 9, letterSpacing: 0)),
                  ],
                ),
              ),
            ]),
          ),
          // Year / Major
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record.yearLevel != null)
                  Text('Year ${record.yearLevel}',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryBlue, fontSize: 9)),
                if (record.majorName != null)
                  Text(record.majorName!,
                      style: AppTextStyles.label
                          .copyWith(fontSize: 9, letterSpacing: 0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(record.fmtDate,
                style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ),
          // Status badge
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(record.statusCode,
                  style: AppTextStyles.label
                      .copyWith(color: _statusColor, fontSize: 9)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Searchable class picker ───────────────────────────────────────────────────

class _SearchableClassPicker extends StatefulWidget {
  const _SearchableClassPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.hint,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final List<MapEntry<String, String>> options; // key → display label
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  State<_SearchableClassPicker> createState() => _SearchableClassPickerState();
}

class _SearchableClassPickerState extends State<_SearchableClassPicker> {
  void _open() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClassPickerSheet(
        options: widget.options,
        selected: widget.value,
        hint: widget.hint,
      ),
    ).then((picked) {
      if (picked == '') {
        widget.onChanged(null); // cleared
      } else if (picked != null) {
        widget.onChanged(picked);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.options
        .where((e) => e.key == widget.value)
        .map((e) => e.value)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _open,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  selected ?? widget.hint,
                  style: selected != null
                      ? AppTextStyles.body.copyWith(fontSize: 12)
                      : AppTextStyles.caption.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.value != null)
                GestureDetector(
                  onTap: () => widget.onChanged(null),
                  child: Icon(Icons.close,
                      size: 14, color: AppColors.textSecondary),
                )
              else
                Icon(Icons.arrow_drop_down,
                    size: 18, color: AppColors.textSecondary),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ClassPickerSheet extends StatefulWidget {
  const _ClassPickerSheet({
    required this.options,
    required this.selected,
    required this.hint,
  });
  final List<MapEntry<String, String>> options;
  final String? selected;
  final String hint;

  @override
  State<_ClassPickerSheet> createState() => _ClassPickerSheetState();
}

class _ClassPickerSheetState extends State<_ClassPickerSheet> {
  final _ctrl = TextEditingController();
  List<MapEntry<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.options;
    _ctrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _ctrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.options
          : widget.options
              .where((e) => e.value.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onSearch);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              Text('Select Class',
                  style: AppTextStyles.bodyMedium),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: Text('Clear',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primaryBlue)),
              ),
            ]),
          ),
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: AppTextStyles.body.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search class…',
                  hintStyle: AppTextStyles.caption,
                  prefixIcon: Icon(Icons.search,
                      size: 16, color: AppColors.textSecondary),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 36),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          Divider(height: 0, color: AppColors.divider),
          // Options list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No classes found',
                        style: AppTextStyles.caption))
                : ListView.builder(
                    controller: sc,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final e = _filtered[i];
                      final isSelected = e.key == widget.selected;
                      return InkWell(
                        onTap: () => Navigator.pop(context, e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: isSelected
                              ? AppColors.primaryBlue.withValues(alpha: 0.08)
                              : null,
                          child: Row(children: [
                            Expanded(
                              child: Text(e.value,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 13,
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  )),
                            ),
                            if (isSelected)
                              Icon(Icons.check,
                                  size: 16, color: AppColors.primaryBlue),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

// ── Filter dropdown ────────────────────────────────────────────────────────────

class _FilterDrop<T> extends StatelessWidget {
  const _FilterDrop({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(hint,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              style: AppTextStyles.body.copyWith(fontSize: 12),
              items: [
                DropdownMenuItem<T>(
                    value: null,
                    child: Text(hint,
                        style: AppTextStyles.body.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis)),
                ...items,
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bulk action button ─────────────────────────────────────────────────────────

class _BulkBtn extends StatelessWidget {
  const _BulkBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        child: Text(label,
            style: AppTextStyles.label
                .copyWith(color: Colors.white, fontSize: 10)),
      ),
    );
  }
}

// ── Export success sheet ───────────────────────────────────────────────────────

class _ExportSuccessSheet extends StatefulWidget {
  const _ExportSuccessSheet({
    required this.filePath,
    required this.rowCount,
    required this.format,
  });
  final String filePath;
  final int rowCount;
  final String format;

  @override
  State<_ExportSuccessSheet> createState() => _ExportSuccessSheetState();
}

class _ExportSuccessSheetState extends State<_ExportSuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _checkDraw;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _scale = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut));

    _checkDraw = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut));

    _fadeSlide = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _fileName => widget.filePath.split(Platform.pathSeparator).last;
  String get _dirPath {
    final parts = widget.filePath.split(Platform.pathSeparator);
    parts.removeLast();
    return parts.join(Platform.pathSeparator);
  }

  Future<void> _openFolder() async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', widget.filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', widget.filePath]);
      } else {
        await Process.run('xdg-open', [_dirPath]);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── drag handle ──────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ── animated check circle ────────────────────────────────────────
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF34D399), Color(0xFF059669)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _checkDraw,
                builder: (_, _) => CustomPaint(
                  painter: _CheckPainter(_checkDraw.value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── title + subtitle ─────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeSlide,
            child: SlideTransition(
              position: Tween(
                      begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(_fadeSlide),
              child: Column(
                children: [
                  Text('Export Complete',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primaryNavy)),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.rowCount} record${widget.rowCount == 1 ? '' : 's'} saved as ${widget.format}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── file card ────────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeSlide,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.description_outlined,
                        color: AppColors.primaryNavy, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName,
                          style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryNavy),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _dirPath,
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // CSV badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('CSV',
                        style: AppTextStyles.label.copyWith(
                            color: const Color(0xFF059669),
                            fontSize: 9)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── buttons ──────────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeSlide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Open folder
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openFolder,
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: const Text('Open Folder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryNavy,
                        side: BorderSide(color: AppColors.border),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Done
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

// ── Animated checkmark painter ─────────────────────────────────────────────────

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Check path: two segments — short downward stroke, long upward stroke
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Points of the checkmark (relative to centre)
    final p0 = Offset(cx - 14, cy);
    final p1 = Offset(cx - 4, cy + 10);
    final p2 = Offset(cx + 14, cy - 10);

    // Total path length (approximate)
    final seg1 = (p1 - p0).distance;
    final seg2 = (p2 - p1).distance;
    final total = seg1 + seg2;

    final drawn = total * progress;

    final path = Path()..moveTo(p0.dx, p0.dy);

    if (drawn <= seg1) {
      final t = drawn / seg1;
      path.lineTo(
        p0.dx + (p1.dx - p0.dx) * t,
        p0.dy + (p1.dy - p0.dy) * t,
      );
    } else {
      path.lineTo(p1.dx, p1.dy);
      final t = (drawn - seg1) / seg2;
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

// ── Export format picker sheet ─────────────────────────────────────────────────

class _ExportFormatSheet extends StatelessWidget {
  const _ExportFormatSheet({
    required this.recordCount,
    required this.onFormat,
  });
  final int recordCount;
  final void Function(String format) onFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // title
          Text('Export Report',
              style: AppTextStyles.h2
                  .copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 6),
          Text(
            '$recordCount record${recordCount == 1 ? '' : 's'} · choose a format',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // format cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FormatCard(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'PDF',
                  description: 'Print-ready\ngrouped table',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                  onTap: () {
                    Navigator.pop(context);
                    onFormat('pdf');
                  },
                ),
                const SizedBox(width: 12),
                _FormatCard(
                  icon: Icons.table_chart_outlined,
                  label: 'Excel',
                  description: 'Spreadsheet\n.xlsx format',
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () {
                    Navigator.pop(context);
                    onFormat('excel');
                  },
                ),
                const SizedBox(width: 12),
                _FormatCard(
                  icon: Icons.text_snippet_outlined,
                  label: 'CSV',
                  description: 'Plain text\nopens anywhere',
                  color: AppColors.primaryBlue,
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () {
                    Navigator.pop(context);
                    onFormat('csv');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: AppTextStyles.label.copyWith(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0)),
              const SizedBox(height: 4),
              Text(description,
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                      height: 1.4),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
