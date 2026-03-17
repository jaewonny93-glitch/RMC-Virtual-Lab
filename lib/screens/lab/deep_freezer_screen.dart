import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cell_model.dart';
import '../../models/lab_model.dart';
import 'clean_bench_screen.dart';

class DeepFreezerScreen extends StatefulWidget {
  const DeepFreezerScreen({super.key});
  @override
  State<DeepFreezerScreen> createState() => _DeepFreezerScreenState();
}

class _DeepFreezerScreenState extends State<DeepFreezerScreen>
    with TickerProviderStateMixin {
  late AnimationController _openController;
  late Animation<double> _openAnim;
  String _searchQuery = '';
  String _selectedCategory = '전체';
  CellType? _selectedCell;

  @override
  void initState() {
    super.initState();
    _openController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _openAnim =
        CurvedAnimation(parent: _openController, curve: Curves.easeOut);
    _openController.forward();
  }

  @override
  void dispose() {
    _openController.dispose();
    super.dispose();
  }

  List<CellType> get _filteredCells {
    return CellDatabase.cells.where((c) {
      final matchCat =
          _selectedCategory == '전체' || c.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.scientificName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  void _selectCell(CellType cell) {
    setState(() => _selectedCell = cell);
    _showCellDetails(cell);
  }

  void _showCellDetails(CellType cell) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(cell.category,
                      style: const TextStyle(
                          color: Color(0xFF00E5FF), fontSize: 12)),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DT: ${cell.doublingTimeHours}h',
                    style: const TextStyle(
                        color: Colors.tealAccent, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(cell.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(cell.scientificName,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text(cell.description,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            _InfoRow('권장 배지', cell.medium),
            _InfoRow('최적 온도', '${cell.optimalTemp}°C'),
            _InfoRow('최적 pH', cell.optimalPH.toString()),
            _InfoRow('CO₂', '${cell.co2Percent}%'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.local_hospital),
                label: Text('${cell.name} Vial 꺼내기',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                  _proceedWithCell(cell);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedWithCell(CellType cell) {
    final session = context.read<ExperimentSession>();
    session.cellTypeId = cell.id;
    session.deepFreezerTime = DateTime.now();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CleanBenchScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['전체', ...CellDatabase.categories];

    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/deep_freezer.jpg',
              fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.75)),
          SafeArea(
            child: FadeTransition(
              opacity: _openAnim,
              child: Column(
                children: [
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Column(
                            children: [
                              Text('딥프리저',
                                  style: TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text('세포주 선택 (50종)',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  // 검색
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '세포주 검색...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFF00E5FF)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 카테고리 필터
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final sel = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color:
                                    sel ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: sel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 세포 목록
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCells.length,
                      itemBuilder: (context, i) {
                        final cell = _filteredCells[i];
                        return _CellListTile(
                          cell: cell,
                          onTap: () => _selectCell(cell),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12))),
            Text(value,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
}

class _CellListTile extends StatelessWidget {
  final CellType cell;
  final VoidCallback onTap;
  const _CellListTile({required this.cell, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.biotech,
                  color: Color(0xFF00E5FF), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cell.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(cell.scientificName,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${cell.doublingTimeHours}h',
                    style: const TextStyle(
                        color: Colors.tealAccent, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 2),
                Text(cell.category,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
