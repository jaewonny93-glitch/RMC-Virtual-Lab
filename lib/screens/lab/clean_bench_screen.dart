import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cell_model.dart';
import '../../models/lab_model.dart';
import '../../models/user_model.dart';
import 'incubator_screen.dart';

class CleanBenchScreen extends StatefulWidget {
  const CleanBenchScreen({super.key});
  @override
  State<CleanBenchScreen> createState() => _CleanBenchScreenState();
}

class _CleanBenchScreenState extends State<CleanBenchScreen>
    with TickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _enterAnim;

  // 단계 관리
  int _step = 0; // 0=dish선택, 1=파이펫선택, 2=배양액선택, 3=배양액분주, 4=세포분주, 5=완료

  CultureDishType? _selectedDish;
  int? _selectedWellIndex;
  PipetteType? _selectedPipette;
  String? _selectedMedium;
  bool _mediumCorrect = false;

  final _mediumVolumeCtrl = TextEditingController();
  final _cellVolumeCtrl = TextEditingController();
  final _mediumRepeatCtrl = TextEditingController(text: '1');
  final _cellRepeatCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _enterAnim =
        CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _mediumVolumeCtrl.dispose();
    _cellVolumeCtrl.dispose();
    _mediumRepeatCtrl.dispose();
    _cellRepeatCtrl.dispose();
    super.dispose();
  }

  ExperimentSession get _session => context.read<ExperimentSession>();

  CellType? get _currentCell {
    if (_session.cellTypeId == null) return null;
    return CellDatabase.findById(_session.cellTypeId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/clean_bench.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.65)),
          SafeArea(
            child: FadeTransition(
              opacity: _enterAnim,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildVialInfo(),
                  Expanded(child: _buildCurrentStep()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final stepLabels = [
      'Dish 선택',
      '파이펫 선택',
      '배양액 선택',
      '배양액 분주',
      '세포 분주',
      '완료',
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text('클린벤치',
                        style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text('세포 배양 준비',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          // 스텝 인디케이터
          Row(
            children: List.generate(6, (i) {
              final done = i < _step;
              final cur = i == _step;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 3,
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFF00E5FF)
                        : cur
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                            : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            _step < stepLabels.length ? 'Step ${_step + 1}: ${stepLabels[_step]}' : '',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildVialInfo() {
    final cell = _currentCell;
    if (cell == null) return const SizedBox.shrink();
    final session = context.watch<ExperimentSession>();
    final pct = session.vialRemainingUL / 1000.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.withValues(alpha: 0.2),
              border: Border.all(color: Colors.tealAccent),
            ),
            child: const Icon(Icons.science,
                color: Colors.tealAccent, size: 22),
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
                Text(
                    'DT: ${cell.doublingTimeHours}h  |  배지: ${cell.medium}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.vialRemainingUL.toStringAsFixed(0)} μL',
                style: const TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              Text(
                '1×10⁶ cells/mL',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 10),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.tealAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildDishSelection();
      case 1:
        return _buildPipetteSelection();
      case 2:
        return _buildMediumSelection();
      case 3:
        return _buildMediumDispense();
      case 4:
        return _buildCellDispense();
      case 5:
        return _buildComplete();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 0: Dish 선택 ──────────────────────────
  Widget _buildDishSelection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Culture Dish 선택',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: DishDatabase.dishes.length,
            itemBuilder: (context, i) {
              final dish = DishDatabase.dishes[i];
              final sel = _selectedDish?.id == dish.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedDish = dish),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? const Color(0xFF00E5FF)
                            : Colors.white.withValues(alpha: 0.15),
                        width: sel ? 1.5 : 0.5),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        dish.wellCount > 1
                            ? Icons.grid_4x4
                            : Icons.circle_outlined,
                        color: sel
                            ? const Color(0xFF00E5FF)
                            : Colors.white54,
                        size: 22,
                      ),
                      const Spacer(),
                      Text(dish.name,
                          style: TextStyle(
                              color: sel
                                  ? const Color(0xFF00E5FF)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('${dish.wellCount} well  |  ${dish.wellVolumeMl}mL/well',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedDish != null) _buildWellSelector(),
        _buildNextButton(
          label: '다음: 파이펫 선택',
          enabled: _selectedDish != null &&
              (_selectedDish!.wellCount == 1 ||
                  _selectedWellIndex != null),
          onTap: () {
            final session = _session;
            session.dishTypeId = _selectedDish!.id;
            session.initWells(_selectedDish!.wellCount);
            if (_selectedWellIndex != null) {
              session.selectedWellIndex = _selectedWellIndex;
            }
            setState(() => _step = 1);
          },
        ),
      ],
    );
  }

  Widget _buildWellSelector() {
    if (_selectedDish == null || _selectedDish!.wellCount == 1) {
      return const SizedBox.shrink();
    }
    final count = _selectedDish!.wellCount;
    final cols = count <= 12 ? (count ~/ 2) : (count <= 48 ? 6 : 12);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Well 선택',
              style:
                  TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: count,
            itemBuilder: (context, i) {
              final sel = _selectedWellIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedWellIndex = i),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel
                        ? const Color(0xFF00E5FF)
                        : Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                        color: sel
                            ? const Color(0xFF00E5FF)
                            : Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                          color: sel ? Colors.black : Colors.white38,
                          fontSize: 8,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── STEP 1: 파이펫 선택 ──────────────────────
  Widget _buildPipetteSelection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('파이펫 선택',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: PipetteDatabase.pipettes.map((p) {
              final sel = _selectedPipette?.id == p.id;
              final color =
                  Color(int.parse(p.color.replaceFirst('#', '0xFF')));
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedPipette = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel
                        ? color.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? color
                            : Colors.white.withValues(alpha: 0.15),
                        width: sel ? 1.5 : 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                if (p.isMulti) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple
                                          .withValues(alpha: 0.3),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: const Text('멀티',
                                        style: TextStyle(
                                            color: Colors.purpleAccent,
                                            fontSize: 10)),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                                '최대 ${p.maxVolume.toInt()} μL',
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      if (sel)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF00E5FF)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        _buildNextButton(
          label: '다음: 배양액 선택',
          enabled: _selectedPipette != null,
          onTap: () {
            _session.pipetteId = _selectedPipette!.id;
            setState(() => _step = 2);
          },
        ),
      ],
    );
  }

  // ── STEP 2: 배양액 선택 ──────────────────────
  Widget _buildMediumSelection() {
    final cell = _currentCell;
    if (cell == null) return const SizedBox.shrink();

    // 권장 배양액 자동 선택 (첫 진입 시)
    if (_selectedMedium == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedMedium = cell.medium;
          _mediumCorrect =
              cell.acceptableMediums.contains(cell.medium);
        });
      });
    }

    // 권장 배양액을 맨 위로, 나머지는 알파벳 순 정렬
    final allMediums = CellDatabase.allMediums;
    final recommended = cell.medium;
    final sorted = [
      recommended,
      ...allMediums.where((m) => m != recommended),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const Text('배양액 선택',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              // 권장 배양액 안내 뱃지
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      Colors.tealAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.tealAccent
                          .withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.tealAccent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '권장 배양액: $recommended (자동 선택됨)',
                      style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '⚠ 잘못된 배양액 선택 시 세포가 사멸합니다',
                style: TextStyle(
                    color: Colors.orange.shade300, fontSize: 11),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final medium = sorted[i];
              final sel = _selectedMedium == medium;
              final isCorrect = cell.acceptableMediums.contains(medium);
              final isRecommended = medium == recommended;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedMedium = medium;
                  _mediumCorrect = isCorrect;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? const Color(0xFF00E5FF)
                            : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_drink_outlined,
                        color: sel
                            ? const Color(0xFF00E5FF)
                            : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                medium,
                                style: TextStyle(
                                    color: sel
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 13),
                              ),
                            ),
                            if (isRecommended) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                                child: const Text('권장',
                                    style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 9)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (sel)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF00E5FF), size: 18),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildNextButton(
          label: '다음: 배양액 분주',
          enabled: _selectedMedium != null,
          onTap: () {
            _session.selectedMedium = _selectedMedium;
            _session.isMediumCorrect = _mediumCorrect;
            setState(() => _step = 3);
          },
        ),
      ],
    );
  }

  // ── STEP 3: 배양액 분주 ──────────────────────
  Widget _buildMediumDispense() {
    final pipe = _selectedPipette;
    final dish = _selectedDish;
    if (pipe == null || dish == null) return const SizedBox.shrink();
    final wellIdx = _selectedWellIndex ?? 0;
    final maxPipeVol = pipe.maxVolume;
    // ★ dish 표준/최대 용량 반영
    final dishMaxVolUL = dish.maxVolumeUL;
    final dishStdVolUL = dish.standardVolumeUL;
    final effectiveMax = maxPipeVol < dishMaxVolUL ? maxPipeVol : dishMaxVolUL;

    // 파이펫 최대 볼륨으로 기본값 설정 (처음 진입 시)
    if (_mediumVolumeCtrl.text.isEmpty) {
      _mediumVolumeCtrl.text = maxPipeVol.toInt().toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDishPreview(wellIdx, false),
          const SizedBox(height: 12),
          // ★ Dish 용량 가이드 카드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dish.name} 배양액 가이드',
                          style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(
                        '표준: ${dishStdVolUL.toInt()} μL  |  최대: ${dishMaxVolUL.toInt()} μL  |  면적: ${dish.surfaceAreaCm2}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // 표준 용량 자동입력 버튼
                GestureDetector(
                  onTap: () => setState(() {
                    _mediumVolumeCtrl.text = dishStdVolUL.toInt().toString();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('표준', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                            pipe.color.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${pipe.name} 파이펫',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const Spacer(),
                    Text('최대 ${maxPipeVol.toInt()} μL',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Well ${wellIdx + 1}에 분주할 배양액 용량 (μL)',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _mediumVolumeCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixText: 'μL',
                    suffixStyle: const TextStyle(color: Colors.white54),
                    hintText: '표준 ${dishStdVolUL.toInt()} ~ 최대 ${effectiveMax.toInt()}',
                    hintStyle: const TextStyle(color: Colors.white24),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF00E5FF), width: 0.5)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF00E5FF))),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 4),
                Text('선택 배양액: ${_selectedMedium ?? '-'}',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 4),
                Text('⚠ dish 최대 용량(${dishMaxVolUL.toInt()} μL) 초과 시 넘칠 수 있습니다',
                    style: TextStyle(color: Colors.orange.shade300, fontSize: 10)),
                const SizedBox(height: 12),
                // ★ 반복 횟수 입력
                const Text('반복 횟수 (회)',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _mediumRepeatCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixText: '회',
                    suffixStyle: const TextStyle(color: Colors.white54),
                    hintText: '1 ~ 100',
                    hintStyle: const TextStyle(color: Colors.white24),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 0.5)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                // ★ 총 볼륨 계산 표시
                Builder(builder: (ctx) {
                  final vol = double.tryParse(_mediumVolumeCtrl.text) ?? 0;
                  final rep = int.tryParse(_mediumRepeatCtrl.text) ?? 1;
                  final total = vol * rep;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('총 분주 볼륨',
                            style: TextStyle(color: Colors.amber, fontSize: 12)),
                        Text(
                          '${vol.toStringAsFixed(0)} μL × $rep회 = ${total.toStringAsFixed(0)} μL',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNextButton(
            label: '배양액 분주 → 세포 분주',
            enabled: true,
            onTap: () {
              final vol = double.tryParse(_mediumVolumeCtrl.text) ?? 0;
              if (vol <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('배양액 용량을 입력하세요.')));
                return;
              }
              if (vol > dishMaxVolUL) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('dish 최대 용량(${dishMaxVolUL.toInt()} μL)을 초과했습니다.'),
                    backgroundColor: Colors.red));
                return;
              }
              if (vol > maxPipeVol) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('파이펫 최대 용량(${maxPipeVol.toInt()} μL)을 초과했습니다.'),
                    backgroundColor: Colors.orange));
                return;
              }
              _session.dispenseMediumToWell(wellIdx, vol);
              setState(() => _step = 4);
            },
          ),
        ],
      ),
    );
  }

  // ── STEP 4: 세포 분주 ──────────────────────
  Widget _buildCellDispense() {
    final session = context.watch<ExperimentSession>();
    final wellIdx = session.selectedWellIndex ?? 0;
    final remaining = session.vialRemainingUL;

    // 파이펫 최대 볼륨을 기본값으로 설정 (처음 진입 시)
    if (_cellVolumeCtrl.text.isEmpty && _selectedPipette != null) {
      final maxVol = _selectedPipette!.maxVolume;
      _cellVolumeCtrl.text =
          maxVol <= remaining ? maxVol.toInt().toString() : remaining.toInt().toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDishPreview(wellIdx, true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.tealAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vial → Well 세포 분주',
                    style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vial 잔량',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text('${remaining.toStringAsFixed(0)} μL',
                        style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: remaining / 1000.0,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation(Colors.tealAccent),
                ),
                const SizedBox(height: 12),
                Text('Well ${wellIdx + 1}에 넣을 세포 용량 (μL)',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _cellVolumeCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixText: 'μL',
                    suffixStyle: const TextStyle(color: Colors.white54),
                    hintText: '0 ~ ${remaining.toStringAsFixed(0)}',
                    hintStyle: const TextStyle(color: Colors.white24),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.tealAccent, width: 0.5)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.tealAccent)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 4),
                Builder(builder: (context) {
                  final vol = double.tryParse(_cellVolumeCtrl.text) ?? 0;
                  final cells = vol * session.cellsPerUL;
                  return Text(
                      '예상 분주 세포 수: ${_formatCellCount(cells)}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11));
                }),
                const SizedBox(height: 8),
                // 분주 세포 수 요약
                Builder(builder: (ctx) {
                  final vol = double.tryParse(_cellVolumeCtrl.text) ?? 0;
                  final totalCells = vol * session.cellsPerUL;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.tealAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('분주 볼륨',
                            style: TextStyle(
                                color: Colors.tealAccent, fontSize: 12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${vol.toStringAsFixed(0)} μL',
                              style: const TextStyle(
                                  color: Colors.tealAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatCellCount(totalCells),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // 다른 well 선택
                    setState(() {
                      _step = 0;
                      _mediumVolumeCtrl.clear();
                      _cellVolumeCtrl.clear();
                    });
                  },
                  child: const Text('다른 Well 선택'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final vol =
                        double.tryParse(_cellVolumeCtrl.text) ?? 0;
                    if (vol <= 0 || vol > session.vialRemainingUL) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '0 ~ ${session.vialRemainingUL.toStringAsFixed(0)} μL 범위로 입력하세요.')),
                      );
                      return;
                    }
                    final ok = session.dispenseCellsToWell(wellIdx, vol);
                    if (ok) {
                      setState(() => _step = 5);
                    }
                  },
                  child: const Text('세포 분주',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 5: 완료 ──────────────────────────
  Widget _buildComplete() {
    final session = context.watch<ExperimentSession>();
    final cell = _currentCell;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.greenAccent, size: 56),
                const SizedBox(height: 12),
                const Text('배양 준비 완료!',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '${cell?.name ?? ''} 세포가 준비되었습니다',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // 요약 정보
                _SummaryRow('세포주', cell?.name ?? '-'),
                _SummaryRow('더블링 타임', '${cell?.doublingTimeHours ?? '-'}h'),
                _SummaryRow('배지', _selectedMedium ?? '-'),
                _SummaryRow('배지 적합성',
                    _mediumCorrect ? '✅ 적합' : '❌ 부적합'),
                _SummaryRow('Dish',
                    _selectedDish?.name ?? '-'),
                _SummaryRow('분주 Wells',
                    '${session.wells.where((w) => w.hasCell).length} well(s)'),
                _SummaryRow('Vial 잔량',
                    '${session.vialRemainingUL.toStringAsFixed(0)} μL'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (session.vialRemainingUL > 0) ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.tealAccent),
                foregroundColor: Colors.tealAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.add),
              label: const Text('다른 Well에 추가 분주'),
              onPressed: () {
                setState(() {
                  _step = 0;
                  _selectedWellIndex = null;
                  _mediumVolumeCtrl.clear();
                  _cellVolumeCtrl.clear();
                });
              },
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.thermostat),
            label: const Text('Cell Culture Complete\n→ 인큐베이터로 이동',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _goToIncubator(),
          ),
        ],
      ),
    );
  }

  void _goToIncubator() {
    final session = _session;
    session.startIncubation();
    // 히스토리 저장 + CultureSession 등록
    final cell = _currentCell;
    final dish = _selectedDish;
    if (cell != null && dish != null) {
      final now = DateTime.now();
      final wellRecords = session.wells
          .where((w) => w.hasCell)
          .map((w) => WellRecord(
                index: w.wellIndex,
                cellCount: w.cellCount,
                mediumVolume: w.mediumVolume,
                cellVolume: w.cellVolume,
                mediumName: w.mediumName,
              ))
          .toList();

      final record = ExperimentRecord(
        id: now.millisecondsSinceEpoch.toString(),
        cellTypeId: cell.id,
        cellTypeName: cell.name,
        dishTypeId: dish.id,
        dishTypeName: dish.name,
        medium: _selectedMedium ?? '-',
        mediumCorrect: _mediumCorrect,
        startTime: now,
        wells: wellRecords,
      );
      final appState = context.read<AppState>();
      appState.addHistory(record);

      // CultureSession 등록 (최대 10개 제한 자동 처리됨)
      final userId = appState.currentUser?.id ?? 'anonymous';
      final cultureSession = CultureSession(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        cellTypeId: cell.id,
        cellTypeName: cell.name,
        dishTypeId: dish.id,
        dishTypeName: dish.name,
        medium: _selectedMedium ?? '-',
        mediumCorrect: _mediumCorrect,
        startTime: now,
        totalCellCount: session.wells
            .fold(0.0, (sum, w) => sum + w.cellCount),
        seededWellCount:
            session.wells.where((w) => w.hasCell).length,
        temp: cell.optimalTemp,
        co2: cell.co2Percent,
        humidity: 95.0,
      );
      appState.addCultureSession(cultureSession);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IncubatorScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget _buildDishPreview(int wellIdx, bool showFilled) {
    final dish = _selectedDish;
    if (dish == null) return const SizedBox.shrink();
    if (dish.wellCount == 1) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: showFilled
              ? Colors.teal.withValues(alpha: 0.3)
              : const Color(0xFF00E5FF).withValues(alpha: 0.1),
          border: Border.all(color: const Color(0xFF00E5FF)),
        ),
        child: Icon(
          Icons.circle,
          color: showFilled
              ? Colors.tealAccent
              : const Color(0xFF00E5FF),
          size: 36,
        ),
      );
    }
    final cols = dish.wellCount <= 12
        ? (dish.wellCount ~/ 2)
        : (dish.wellCount <= 48 ? 6 : 12);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: 1,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: dish.wellCount,
        itemBuilder: (_, i) {
          final isCur = i == wellIdx;
          final session = context.watch<ExperimentSession>();
          final hasCells = i < session.wells.length &&
              session.wells[i].hasCell;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCur
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                  : hasCells
                      ? Colors.teal.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                  color: isCur
                      ? const Color(0xFF00E5FF)
                      : Colors.white24,
                  width: isCur ? 1.5 : 0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? const Color(0xFF00E5FF) : Colors.white12,
          foregroundColor: enabled ? Colors.black : Colors.white38,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: enabled ? onTap : null,
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatCellCount(double count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(2)}×10⁶';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}×10³';
    }
    return count.toStringAsFixed(0);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13)),
          ],
        ),
      );
}
