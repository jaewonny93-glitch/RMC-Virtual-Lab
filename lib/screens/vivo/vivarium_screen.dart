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
    _tab = TabController(length: 2, vsync: this);
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
              Tab(text: '💀 폐사'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [
              _AliveAnimalsTab(),
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
