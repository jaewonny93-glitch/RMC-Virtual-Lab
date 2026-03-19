import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../models/animal_model.dart';
import 'animal_detail_screen.dart';

class VivariumScreen extends StatefulWidget {
  const VivariumScreen({super.key});
  @override
  State<VivariumScreen> createState() => _VivariumScreenState();
}

class _VivariumScreenState extends State<VivariumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF0D1F0D),
          child: TabBar(
            controller: _tab,
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(text: '🐾 사육 중'),
              Tab(text: '🐣 번식'),
              Tab(text: '💀 폐사'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [
              _AliveAnimalsTab(),
              _BreedingTab(),
              _DeadAnimalsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 생존 동물 탭 ────────────────────────────────────────
class _AliveAnimalsTab extends StatefulWidget {
  const _AliveAnimalsTab();
  @override
  State<_AliveAnimalsTab> createState() => _AliveAnimalsTabState();
}

class _AliveAnimalsTabState extends State<_AliveAnimalsTab> {
  String _filterSpecies = 'all';
  String _sortMode = 'status'; // 'status', 'age', 'tag'

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    var animals = inVivo.aliveAnimals;

    // 필터
    if (_filterSpecies != 'all') {
      animals = animals.where((a) => a.speciesId == _filterSpecies).toList();
    }

    // 정렬
    switch (_sortMode) {
      case 'status':
        animals.sort((a, b) => a.conditionScore.compareTo(b.conditionScore));
        break;
      case 'age':
        animals.sort((a, b) => b.ageInDays.compareTo(a.ageInDays));
        break;
      case 'tag':
        animals.sort((a, b) => a.tag.compareTo(b.tag));
        break;
    }

    // 전체 상태 요약
    final healthyCount = animals.where((a) => a.status == AnimalStatus.healthy).length;
    final stressedCount = animals.where((a) => a.status == AnimalStatus.stressed).length;
    final sickCount = animals.where((a) => a.status == AnimalStatus.sick).length;
    final criticalCount = animals.where((a) => a.status == AnimalStatus.critical).length;

    return Column(
      children: [
        // 상태 요약 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF0D1F0D),
          child: Row(
            children: [
              _StatusSummaryChip(label: '건강', count: healthyCount, color: Colors.greenAccent),
              const SizedBox(width: 6),
              _StatusSummaryChip(label: '스트레스', count: stressedCount, color: Colors.amberAccent),
              const SizedBox(width: 6),
              _StatusSummaryChip(label: '아픔', count: sickCount, color: Colors.orangeAccent),
              const SizedBox(width: 6),
              _StatusSummaryChip(label: '위험', count: criticalCount, color: Colors.redAccent),
              const Spacer(),
              // 정렬 드롭다운
              DropdownButton<String>(
                value: _sortMode,
                dropdownColor: const Color(0xFF0D1F0D),
                underline: const SizedBox(),
                icon: const Icon(Icons.sort, color: Colors.white38, size: 16),
                items: const [
                  DropdownMenuItem(value: 'status', child: Text('상태순', style: TextStyle(color: Colors.white70, fontSize: 11))),
                  DropdownMenuItem(value: 'age', child: Text('나이순', style: TextStyle(color: Colors.white70, fontSize: 11))),
                  DropdownMenuItem(value: 'tag', child: Text('태그순', style: TextStyle(color: Colors.white70, fontSize: 11))),
                ],
                onChanged: (v) => setState(() => _sortMode = v!),
              ),
            ],
          ),
        ),

        // 종별 필터
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              _FilterChip(label: '전체', selected: _filterSpecies == 'all',
                  onTap: () => setState(() => _filterSpecies = 'all')),
              ...AnimalDatabase.species.map((sp) =>
                _FilterChip(
                  label: sp.iconEmoji + ' ' + sp.name.split(' ').first,
                  selected: _filterSpecies == sp.id,
                  onTap: () => setState(() => _filterSpecies = sp.id),
                ),
              ),
            ],
          ),
        ),

        // 동물 리스트
        Expanded(
          child: animals.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🐾', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('사육 중인 동물이 없습니다',
                          style: TextStyle(color: Colors.white38, fontSize: 14)),
                      SizedBox(height: 6),
                      Text('입고 신청 탭에서 동물을 신청하세요',
                          style: TextStyle(color: Colors.white24, fontSize: 11)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: animals.length,
                  itemBuilder: (_, i) => _AnimalCard(animal: animals[i]),
                ),
        ),
      ],
    );
  }
}

// ── 동물 카드 ─────────────────────────────────────────
class _AnimalCard extends StatelessWidget {
  final AnimalInstance animal;
  const _AnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(animal.speciesId);
    final statusColor = _statusColor(animal.status);
    final gene = animal.injectedGeneId != null
        ? GeneDatabase.findById(animal.injectedGeneId!)
        : null;

    // 산소/물/먹이 경고
    final now = DateTime.now();
    final sp = species;
    bool waterWarn = false;
    bool feedWarn = false;
    bool oxygenWarn = false;

    if (sp != null) {
      if (animal.lastWaterTime != null && sp.id != 'zebrafish') {
        final wDays = now.difference(animal.lastWaterTime!).inSeconds / 86400.0;
        waterWarn = wDays > sp.waterStarveDays * 0.4;
      }
      if (animal.lastFeedTime != null) {
        final fDays = now.difference(animal.lastFeedTime!).inSeconds / 86400.0;
        feedWarn = fDays > 0.8;
      }
      oxygenWarn = animal.oxygenPercent < sp.stdOxygenMin || animal.oxygenPercent > sp.stdOxygenMax;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnimalDetailScreen(animalId: animal.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.4),
            width: animal.status == AnimalStatus.critical ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // 이모지 + 상태 인디케이터
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(species?.iconEmoji ?? '🐭',
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                // 컨디션 미니바
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                    child: LinearProgressIndicator(
                      value: animal.conditionScore / 100,
                      minHeight: 4,
                      backgroundColor: Colors.black45,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        animal.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 성별 배지
                      Text(
                        animal.gender == AnimalGender.male ? '♂' : '♀',
                        style: TextStyle(
                          color: animal.gender == AnimalGender.male ? Colors.lightBlue : Colors.pinkAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(animal.status),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (gene != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('🧬 ${gene.symbol}',
                              style: const TextStyle(color: Colors.purpleAccent, fontSize: 9)),
                        ),
                      ],
                      // 임신 배지
                      if (animal.pregnancyStatus == PregnancyStatus.pregnant) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🤰임신중',
                              style: TextStyle(color: Colors.pinkAccent, fontSize: 9)),
                        ),
                      ],
                      if (animal.pregnancyStatus == PregnancyStatus.nursing) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🍼수유중',
                              style: TextStyle(color: Colors.orangeAccent, fontSize: 9)),
                        ),
                      ],
                      if (animal.isOffspring) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🐣새끼',
                              style: TextStyle(color: Colors.tealAccent, fontSize: 9)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${species?.name ?? animal.speciesId} · ${animal.ageInDays.toStringAsFixed(1)}일령 · ${animal.weightG.toStringAsFixed(1)}g',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniStat(icon: '🌬️', value: '${animal.oxygenPercent.toStringAsFixed(1)}%', warn: oxygenWarn),
                      const SizedBox(width: 8),
                      _MiniStat(icon: '💧', value: waterWarn ? '보충 필요' : '정상', warn: waterWarn),
                      const SizedBox(width: 8),
                      _MiniStat(icon: '🌿', value: feedWarn ? '사료 부족' : '정상', warn: feedWarn),
                    ],
                  ),
                ],
              ),
            ),

            // 컨디션 수치
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${animal.conditionScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text('컨디션',
                    style: TextStyle(color: Colors.white24, fontSize: 9)),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(AnimalStatus s) {
    switch (s) {
      case AnimalStatus.healthy: return Colors.greenAccent;
      case AnimalStatus.stressed: return Colors.amberAccent;
      case AnimalStatus.sick: return Colors.orangeAccent;
      case AnimalStatus.critical: return Colors.redAccent;
      case AnimalStatus.dead: return Colors.grey;
    }
  }

  String _statusLabel(AnimalStatus s) {
    switch (s) {
      case AnimalStatus.healthy: return '건강';
      case AnimalStatus.stressed: return '스트레스';
      case AnimalStatus.sick: return '아픔';
      case AnimalStatus.critical: return '위험';
      case AnimalStatus.dead: return '폐사';
    }
  }
}

// ── 폐사 동물 탭 ────────────────────────────────────────
class _BreedingTab extends StatefulWidget {
  const _BreedingTab();
  @override
  State<_BreedingTab> createState() => _BreedingTabState();
}

class _BreedingTabState extends State<_BreedingTab> {
  AnimalInstance? _selectedFemale;
  AnimalInstance? _selectedMale;

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final alive = inVivo.aliveAnimals;
    final females = alive.where((a) => a.gender == AnimalGender.female && a.pregnancyStatus == PregnancyStatus.none).toList();
    final males = alive.where((a) => a.gender == AnimalGender.male).toList();
    final pregnant = alive.where((a) => a.pregnancyStatus == PregnancyStatus.pregnant).toList();
    final nursing = alive.where((a) => a.pregnancyStatus == PregnancyStatus.nursing).toList();
    final offspring = alive.where((a) => a.isOffspring).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 임신 유도 섹션 ──
          _BreedingHeader(icon: '💑', title: '교배 및 임신 유도'),
          const SizedBox(height: 12),

          // 암컷 선택
          const Text('암컷 선택', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 6),
          females.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('교배 가능한 암컷이 없습니다.\n(임신/수유 중이 아닌 암컷)',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                )
              : SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: females.length,
                    itemBuilder: (_, i) {
                      final f = females[i];
                      final sp = AnimalDatabase.findById(f.speciesId);
                      final sel = _selectedFemale?.id == f.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFemale = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.pink.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? Colors.pinkAccent : Colors.white24,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${sp?.iconEmoji ?? "🐭"}♀', style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(f.tag, style: TextStyle(
                                  color: sel ? Colors.pinkAccent : Colors.white70,
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('${f.ageInDays.toInt()}일령',
                                  style: const TextStyle(color: Colors.white38, fontSize: 9)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 14),

          // 수컷 선택
          const Text('수컷 선택', style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 6),
          males.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('수컷이 없습니다.',
                      style: TextStyle(color: Colors.white38, fontSize: 11)),
                )
              : SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: males.length,
                    itemBuilder: (_, i) {
                      final m = males[i];
                      final sp = AnimalDatabase.findById(m.speciesId);
                      final sel = _selectedMale?.id == m.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMale = m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.blue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? Colors.lightBlue : Colors.white24,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${sp?.iconEmoji ?? "🐭"}♂', style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(m.tag, style: TextStyle(
                                  color: sel ? Colors.lightBlue : Colors.white70,
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('${m.ageInDays.toInt()}일령',
                                  style: const TextStyle(color: Colors.white38, fontSize: 9)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 16),

          // 교배 정보 미리보기
          if (_selectedFemale != null && _selectedMale != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(children: [
                        Text(AnimalDatabase.findById(_selectedFemale!.speciesId)?.iconEmoji ?? '🐭',
                            style: const TextStyle(fontSize: 24)),
                        Text('♀ ${_selectedFemale!.tag}',
                            style: const TextStyle(color: Colors.pinkAccent, fontSize: 11)),
                      ]),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('💑', style: TextStyle(fontSize: 24)),
                      ),
                      Column(children: [
                        Text(AnimalDatabase.findById(_selectedMale!.speciesId)?.iconEmoji ?? '🐭',
                            style: const TextStyle(fontSize: 24)),
                        Text('♂ ${_selectedMale!.tag}',
                            style: const TextStyle(color: Colors.lightBlue, fontSize: 11)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Builder(builder: (_) {
                    final sp = AnimalDatabase.findById(_selectedFemale!.speciesId);
                    if (sp == null) return const SizedBox();
                    return Wrap(
                      spacing: 8, runSpacing: 4,
                      children: [
                        _MiniInfoChip('임신기간', '${sp.gestationDays.toInt()}일'),
                        _MiniInfoChip('예상 산자수', '${sp.litterSizeMin}~${sp.litterSizeMax}마리'),
                        _MiniInfoChip('새끼 체중', '${sp.birthWeightG}g'),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 교배 유도 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (_selectedFemale != null && _selectedMale != null)
                  ? () => _induceMating(context, inVivo)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_selectedFemale != null && _selectedMale != null)
                    ? Colors.pink.shade700 : Colors.white12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.favorite, color: Colors.white, size: 16),
              label: const Text('임신 유도',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // ── 임신 중 동물 ──
          _BreedingHeader(icon: '🤰', title: '임신 중 (${pregnant.length}마리)'),
          const SizedBox(height: 8),
          if (pregnant.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('임신 중인 동물이 없습니다', style: TextStyle(color: Colors.white38, fontSize: 12)),
            )
          else
            ...pregnant.map((a) => _PregnantAnimalCard(animal: a)),

          const SizedBox(height: 16),

          // ── 수유 중 동물 ──
          _BreedingHeader(icon: '🍼', title: '수유 중 (${nursing.length}마리)'),
          const SizedBox(height: 8),
          if (nursing.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('수유 중인 동물이 없습니다', style: TextStyle(color: Colors.white38, fontSize: 12)),
            )
          else
            ...nursing.map((a) => _NursingAnimalCard(animal: a, inVivo: inVivo)),

          const SizedBox(height: 16),

          // ── 새끼 목록 ──
          _BreedingHeader(icon: '🐣', title: '새끼 (${offspring.length}마리)'),
          const SizedBox(height: 8),
          if (offspring.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('새끼가 없습니다', style: TextStyle(color: Colors.white38, fontSize: 12)),
            )
          else
            ...offspring.map((a) => _OffspringCard(animal: a, inVivo: inVivo)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _induceMating(BuildContext context, InVivoState inVivo) {
    final f = _selectedFemale!;
    final m = _selectedMale!;

    // 같은 종인지 확인
    if (f.speciesId != m.speciesId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ 같은 종끼리만 교배가 가능합니다'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final error = inVivo.induceMating(f.id, m.id);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final sp = AnimalDatabase.findById(f.speciesId);
    setState(() {
      _selectedFemale = null;
      _selectedMale = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🤰 임신 유도 성공! ${f.tag}이(가) 임신 상태가 되었습니다.\n'
            '표준 임신기간: ${sp?.gestationDays.toInt()}일 후 출산 예정'),
        backgroundColor: Colors.pink.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _BreedingHeader extends StatelessWidget {
  final String icon;
  final String title;
  const _BreedingHeader({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _MiniInfoChip(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value',
          style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }
}

class _PregnantAnimalCard extends StatelessWidget {
  final AnimalInstance animal;
  const _PregnantAnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final sp = AnimalDatabase.findById(animal.speciesId);
    final elapsed = animal.pregnancyElapsedDays;
    final total = sp?.gestationDays ?? 21;
    final progress = (elapsed / total).clamp(0.0, 1.0);
    final remaining = (total - elapsed).clamp(0.0, total);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(sp?.iconEmoji ?? '🐭', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${animal.tag} ♀',
                    style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const Text('🤰 임신 중', style: TextStyle(color: Colors.pink, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('임신 경과: ${elapsed.toStringAsFixed(1)}일 / ${total.toInt()}일',
                            style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        const Spacer(),
                        Text('출산까지 ${remaining.toStringAsFixed(1)}일',
                            style: const TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Colors.pinkAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (sp != null) ...[
            const SizedBox(height: 6),
            Text('예상 산자수: ${sp.litterSizeMin}~${sp.litterSizeMax}마리',
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class _NursingAnimalCard extends StatelessWidget {
  final AnimalInstance animal;
  final InVivoState inVivo;
  const _NursingAnimalCard({required this.animal, required this.inVivo});

  @override
  Widget build(BuildContext context) {
    final sp = AnimalDatabase.findById(animal.speciesId);
    final offspringCount = animal.offspringIds.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(sp?.iconEmoji ?? '🐭', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${animal.tag} ♀',
                    style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('🍼 수유 중 · 새끼 ${offspringCount}마리',
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          // 수유 종료 버튼
          OutlinedButton(
            onPressed: () {
              animal.pregnancyStatus = PregnancyStatus.none;
              inVivo.notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ 수유 기간이 종료되었습니다'), backgroundColor: Colors.green),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orangeAccent,
              side: const BorderSide(color: Colors.orangeAccent),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('수유 종료', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _OffspringCard extends StatefulWidget {
  final AnimalInstance animal;
  final InVivoState inVivo;
  const _OffspringCard({required this.animal, required this.inVivo});
  @override
  State<_OffspringCard> createState() => _OffspringCardState();
}

class _OffspringCardState extends State<_OffspringCard> {
  @override
  Widget build(BuildContext context) {
    final sp = AnimalDatabase.findById(widget.animal.speciesId);
    final cages = CageDatabase.cages.where((c) => c.suitableFor.contains(widget.animal.speciesId) || c.suitableFor.isEmpty).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(sp?.iconEmoji ?? '🐭', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.animal.tag,
                        style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(widget.animal.gender == AnimalGender.male ? '♂' : '♀',
                        style: TextStyle(
                            color: widget.animal.gender == AnimalGender.male ? Colors.lightBlue : Colors.pinkAccent,
                            fontSize: 12)),
                    const SizedBox(width: 4),
                    const Text('🐣 새끼', style: TextStyle(color: Colors.tealAccent, fontSize: 9)),
                  ],
                ),
                Text('${widget.animal.weightG.toStringAsFixed(1)}g · ${widget.animal.ageInDays.toStringAsFixed(0)}일령',
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          // 케이지 배치
          if (widget.animal.cageId == null)
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: cages.isEmpty ? null : () => _assignCage(context, cages),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                ),
                child: const Text('케이지 배치', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.animal.cageId!,
                style: const TextStyle(color: Colors.tealAccent, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  void _assignCage(BuildContext context, List<CageType> cages) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1F0D),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('케이지 선택', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...cages.map((c) => ListTile(
            leading: const Icon(Icons.home, color: Colors.tealAccent),
            title: Text(c.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(c.size, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            onTap: () {
              Navigator.pop(ctx);
              widget.inVivo.setCage(widget.animal.id, c.id);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${widget.animal.tag}이(가) ${c.name}에 배치되었습니다'),
                  backgroundColor: Colors.teal.shade700,
                ),
              );
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── 폐사 동물 탭 ────────────────────────────────────────
class _DeadAnimalsTab extends StatelessWidget {
  const _DeadAnimalsTab();

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final dead = inVivo.deadAnimals;

    if (dead.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✅', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('폐사한 동물이 없습니다',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dead.length,
      itemBuilder: (_, i) => _DeadAnimalCard(animal: dead[i]),
    );
  }
}

class _DeadAnimalCard extends StatelessWidget {
  final AnimalInstance animal;
  const _DeadAnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(animal.speciesId);
    final causeLabel = _causeLabel(animal.deathCause);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(species?.iconEmoji ?? '🐭',
                  style: const TextStyle(fontSize: 26,
                      color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(animal.tag,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(species?.name ?? animal.speciesId,
                    style: const TextStyle(color: Colors.white24, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.redAccent, size: 12),
                    const SizedBox(width: 4),
                    Text(causeLabel,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 11)),
                  ],
                ),
                if (animal.necropsyDone) ...[
                  const SizedBox(height: 2),
                  const Row(
                    children: [
                      Icon(Icons.science, color: Colors.tealAccent, size: 11),
                      SizedBox(width: 4),
                      Text('부검 완료',
                          style: TextStyle(
                              color: Colors.tealAccent, fontSize: 10)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (animal.deathDate != null)
                Text(
                  _formatDate(animal.deathDate!),
                  style: const TextStyle(color: Colors.white24, fontSize: 9),
                ),
              const SizedBox(height: 4),
              if (!animal.necropsyDone)
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animalId: animal.id),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.tealAccent,
                    side: const BorderSide(color: Colors.tealAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('부검', style: TextStyle(fontSize: 10)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _causeLabel(AnimalDeathCause c) {
    switch (c) {
      case AnimalDeathCause.oxygenLow: return '산소 부족으로 폐사';
      case AnimalDeathCause.oxygenHigh: return '산소 과다로 폐사';
      case AnimalDeathCause.dehydration: return '탈수로 폐사';
      case AnimalDeathCause.starvation: return '기아로 폐사';
      case AnimalDeathCause.naturalDeath: return '자연사';
      case AnimalDeathCause.euthanized: return '안락사 (부검)';
      case AnimalDeathCause.unknown: return '원인 불명';
      case AnimalDeathCause.none: return '미상';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

// ── 공용 위젯 ─────────────────────────────────────────
class _StatusSummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusSummaryChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$label $count',
              style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? Colors.greenAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.greenAccent : Colors.white24,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.greenAccent : Colors.white54,
                fontSize: 11)),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String value;
  final bool warn;
  const _MiniStat({required this.icon, required this.value, required this.warn});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text(value,
            style: TextStyle(
                color: warn ? Colors.redAccent : Colors.white38,
                fontSize: 9)),
      ],
    );
  }
}
