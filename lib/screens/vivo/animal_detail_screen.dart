import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/animal_model.dart';
import 'gene_injection_screen.dart';
import 'necropsy_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen>
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
    final inVivo = context.watch<InVivoState>();
    final animal = inVivo.animals.firstWhere(
      (a) => a.id == widget.animalId,
      orElse: () => AnimalInstance(
        id: '', speciesId: 'mouse_c57bl6', tag: 'N/A',
        birthDate: DateTime.now(), admitDate: DateTime.now(), weightG: 0,
      ),
    );

    if (animal.id.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1F0D),
          title: const Text('동물 정보'),
        ),
        body: const Center(
          child: Text('동물을 찾을 수 없습니다.',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final species = AnimalDatabase.findById(animal.speciesId);
    final isDead = animal.status == AnimalStatus.dead;
    final statusColor = _statusColor(animal.status);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.greenAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(animal.tag,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(species?.name ?? animal.speciesId,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 10)),
          ],
        ),
        actions: [
          if (!isDead) ...[
            // 유전자 주입 버튼
            IconButton(
              icon: const Icon(Icons.science, color: Colors.purpleAccent),
              tooltip: '유전자 주입',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GeneInjectionScreen(animalId: animal.id),
                ),
              ),
            ),
            // 부검 버튼 (안락사)
            IconButton(
              icon: const Icon(Icons.biotech, color: Colors.tealAccent),
              tooltip: '부검',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NecropsyScreen(animalId: animal.id),
                ),
              ),
            ),
          ] else if (!animal.necropsyDone) ...[
            IconButton(
              icon: const Icon(Icons.biotech, color: Colors.tealAccent),
              tooltip: '부검',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NecropsyScreen(animalId: animal.id),
                ),
              ),
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.greenAccent,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: '현황'),
            Tab(text: '관리'),
            Tab(text: '케이지'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _StatusTab(animal: animal, species: species),
          _CareTab(animal: animal, species: species),
          _CageTab(animal: animal, species: species),
        ],
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
}

// ── 현황 탭 ────────────────────────────────────────────
class _StatusTab extends StatelessWidget {
  final AnimalInstance animal;
  final AnimalSpecies? species;
  const _StatusTab({required this.animal, required this.species});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gene = animal.injectedGeneId != null
        ? GeneDatabase.findById(animal.injectedGeneId!)
        : null;

    double waterDays = 0;
    double feedDays = 0;
    if (animal.lastWaterTime != null) {
      waterDays = now.difference(animal.lastWaterTime!).inSeconds / 86400.0;
    }
    if (animal.lastFeedTime != null) {
      feedDays = now.difference(animal.lastFeedTime!).inSeconds / 86400.0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 컨디션 메인 카드
          _ConditionCard(animal: animal, species: species),
          const SizedBox(height: 16),

          // 생체 정보
          _SectionTitle('생체 정보'),
          const SizedBox(height: 8),
          _InfoGrid([
            _InfoItem('나이', '${animal.ageInDays.toStringAsFixed(1)}일령'),
            _InfoItem('체중', '${animal.weightG.toStringAsFixed(1)}g'),
            _InfoItem('입고일', _formatDate(animal.admitDate)),
            _InfoItem('컨디션', '${animal.conditionScore.toStringAsFixed(1)}%'),
            _InfoItem('산소', '${animal.oxygenPercent.toStringAsFixed(1)}%'),
            _InfoItem('마지막 급수',
                animal.lastWaterTime != null
                    ? '${waterDays.toStringAsFixed(1)}일 전'
                    : '없음'),
            _InfoItem('마지막 급이',
                animal.lastFeedTime != null
                    ? '${feedDays.toStringAsFixed(1)}일 전'
                    : '없음'),
            _InfoItem('케이지', animal.cageId ?? '미배정'),
          ]),

          // 유전자 주입 정보
          if (gene != null) ...[
            const SizedBox(height: 16),
            _SectionTitle('유전자 주입 정보'),
            const SizedBox(height: 8),
            _GeneStatusCard(animal: animal, gene: gene),
          ],

          // 폐사 정보
          if (animal.status == AnimalStatus.dead) ...[
            const SizedBox(height: 16),
            _SectionTitle('폐사 정보'),
            const SizedBox(height: 8),
            _DeathCard(animal: animal),
          ],

          // 부검 정보
          if (animal.necropsyDone) ...[
            const SizedBox(height: 16),
            _SectionTitle('부검 정보'),
            const SizedBox(height: 8),
            _NecropsyResultCard(animal: animal),
          ],

          // 환경 강화 용품
          if (animal.enrichmentIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionTitle('환경 강화'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 6,
              children: animal.enrichmentIds.map((id) {
                final item = EnrichmentDatabase.items.firstWhere(
                  (e) => e.id == id,
                  orElse: () => const EnrichmentItem(
                      id: '', name: '?', emoji: '❓',
                      description: '', suitableFor: []),
                );
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(item.name,
                          style: const TextStyle(
                              color: Colors.greenAccent, fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // 메모
          if (animal.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionTitle('메모'),
            const SizedBox(height: 6),
            Text(animal.notes,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

// ── 관리 탭 ─────────────────────────────────────────
class _CareTab extends StatefulWidget {
  final AnimalInstance animal;
  final AnimalSpecies? species;
  const _CareTab({required this.animal, required this.species});

  @override
  State<_CareTab> createState() => _CareTabState();
}

class _CareTabState extends State<_CareTab> {
  double _oxygenValue = 21.0;

  @override
  void initState() {
    super.initState();
    _oxygenValue = widget.animal.oxygenPercent;
  }

  @override
  Widget build(BuildContext context) {
    final inVivo = context.read<InVivoState>();
    final sp = widget.species;
    final isDead = widget.animal.status == AnimalStatus.dead;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDead)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.redAccent, size: 16),
                  SizedBox(width: 8),
                  Text('폐사한 동물은 관리할 수 없습니다.',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
              ),
            ),

          // 산소 설정
          _SectionTitle('산소 농도 설정'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('O₂ 농도', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(
                      '${_oxygenValue.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _oxygenColor(_oxygenValue, sp),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                if (sp != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('권장: ${sp.stdOxygenMin}~${sp.stdOxygenMax}%',
                          style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      Text('위험: < ${sp.oxygenDeathMin}% 또는 > ${sp.oxygenDeathMax}%',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
                    ],
                  ),
                ],
                Slider(
                  value: _oxygenValue,
                  min: sp?.id == 'zebrafish' ? 1.0 : 10.0,
                  max: sp?.id == 'zebrafish' ? 15.0 : 30.0,
                  divisions: sp?.id == 'zebrafish' ? 140 : 200,
                  activeColor: _oxygenColor(_oxygenValue, sp),
                  inactiveColor: Colors.white12,
                  onChanged: isDead ? null : (v) {
                    setState(() => _oxygenValue = double.parse(v.toStringAsFixed(1)));
                  },
                  onChangeEnd: isDead ? null : (v) {
                    inVivo.setOxygen(widget.animal.id, v);
                  },
                ),
                // 경고 메시지
                if (sp != null && (_oxygenValue < sp.stdOxygenMin || _oxygenValue > sp.stdOxygenMax))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _oxygenValue < sp.oxygenDeathMin
                                ? '⚠️ 위험! 산소 부족으로 폐사 위험이 있습니다.'
                                : _oxygenValue > sp.oxygenDeathMax
                                    ? '⚠️ 위험! 산소 과다로 폐사 위험이 있습니다.'
                                    : '산소 농도가 권장 범위를 벗어났습니다. 컨디션이 저하됩니다.',
                            style: const TextStyle(
                                color: Colors.amberAccent, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 먹이 급여
          _SectionTitle('먹이 급여'),
          const SizedBox(height: 8),
          _FeedWaterCard(
            icon: '🌿',
            title: '사료',
            subtitle: sp != null ? '권장 일일 급이량: ${sp.stdFeedGPerDay}g' : '',
            lastTime: widget.animal.lastFeedTime,
            starveDays: sp?.feedStarveDays ?? 7.0,
            buttonLabel: '급이',
            buttonColor: Colors.green.shade700,
            onPressed: isDead ? null : () {
              inVivo.feedAnimal(widget.animal.id, sp?.stdFeedGPerDay ?? 5.0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.animal.tag} 급이 완료 (${sp?.stdFeedGPerDay ?? 5.0}g)'),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // 음수 급여
          _FeedWaterCard(
            icon: '💧',
            title: '음수',
            subtitle: sp != null && sp.id != 'zebrafish'
                ? '권장 일일 음수량: ${sp.stdWaterMlPerDay}mL'
                : sp?.id == 'zebrafish' ? '수중 생활 (자동)' : '',
            lastTime: widget.animal.lastWaterTime,
            starveDays: sp?.waterStarveDays ?? 3.0,
            buttonLabel: '급수',
            buttonColor: Colors.blue.shade700,
            onPressed: (isDead || sp?.id == 'zebrafish') ? null : () {
              inVivo.waterAnimal(widget.animal.id, sp?.stdWaterMlPerDay ?? 10.0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.animal.tag} 급수 완료 (${sp?.stdWaterMlPerDay ?? 10.0}mL)'),
                  backgroundColor: Colors.blue.shade700,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _oxygenColor(double o, AnimalSpecies? sp) {
    if (sp == null) return Colors.white70;
    if (o < sp.oxygenDeathMin || o > sp.oxygenDeathMax) return Colors.redAccent;
    if (o < sp.stdOxygenMin || o > sp.stdOxygenMax) return Colors.amberAccent;
    return Colors.greenAccent;
  }
}

// ── 케이지 탭 ─────────────────────────────────────────
class _CageTab extends StatelessWidget {
  final AnimalInstance animal;
  final AnimalSpecies? species;
  const _CageTab({required this.animal, required this.species});

  @override
  Widget build(BuildContext context) {
    final inVivo = context.read<InVivoState>();
    final isDead = animal.status == AnimalStatus.dead;

    // 이 동물에 맞는 케이지 필터
    final compatibleCages = CageDatabase.cages.where((c) =>
        c.suitableFor.isEmpty || c.suitableFor.contains(animal.speciesId)).toList();

    // 이 동물에 맞는 환경강화 아이템 필터
    final compatibleEnrich = EnrichmentDatabase.items.where((e) =>
        e.suitableFor.isEmpty || e.suitableFor.contains(animal.speciesId)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 케이지 선택
          _SectionTitle('케이지 선택'),
          const SizedBox(height: 10),
          if (compatibleCages.isEmpty)
            const Text('호환 케이지 없음',
                style: TextStyle(color: Colors.white38)),
          ...compatibleCages.map((cage) {
            final selected = animal.cageId == cage.id;
            return GestureDetector(
              onTap: isDead ? null : () {
                inVivo.setCage(animal.id, cage.id);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? Colors.greenAccent
                        : Colors.white12,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? Colors.greenAccent : Colors.white24,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cage.name,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.greenAccent
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(cage.description,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          Text('크기: ${cage.size}',
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 환경 강화 용품
          _SectionTitle('환경 강화 용품 (Enrichment)'),
          const SizedBox(height: 4),
          const Text(
            '동물 복지 기준에 따라 적절한 환경 강화 용품을 제공하세요',
            style: TextStyle(color: Colors.white30, fontSize: 10),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: compatibleEnrich.map((item) {
              final selected = animal.enrichmentIds.contains(item.id);
              return GestureDetector(
                onTap: isDead ? null : () {
                  inVivo.toggleEnrichment(animal.id, item.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? Colors.greenAccent
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.greenAccent
                                      : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          Text(item.description,
                              style: const TextStyle(
                                  color: Colors.white30, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── 하위 위젯 ─────────────────────────────────────────
class _ConditionCard extends StatelessWidget {
  final AnimalInstance animal;
  final AnimalSpecies? species;
  const _ConditionCard({required this.animal, required this.species});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(animal.status);
    final ageRatio = species != null
        ? (animal.ageInDays / species!.lifespanDays).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(species?.iconEmoji ?? '🐭',
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _statusLabel(animal.status),
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        if (animal.status == AnimalStatus.dead) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _causeLabel(animal.deathCause),
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(animal.tag,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // 컨디션 게이지
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: animal.conditionScore / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                    Center(
                      child: Text(
                        '${animal.conditionScore.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 노화 진행도
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('노화 진행도',
                      style: TextStyle(color: Colors.white38, fontSize: 10)),
                  Text(
                    '${(ageRatio * 100).toStringAsFixed(1)}% (${animal.ageInDays.toStringAsFixed(0)}일 / ${species?.lifespanDays.toStringAsFixed(0) ?? '?'}일)',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ageRatio,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                    ageRatio > 0.85 ? Colors.orangeAccent : Colors.tealAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
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

  String _causeLabel(AnimalDeathCause c) {
    switch (c) {
      case AnimalDeathCause.oxygenLow: return '산소 부족';
      case AnimalDeathCause.oxygenHigh: return '산소 과다';
      case AnimalDeathCause.dehydration: return '탈수';
      case AnimalDeathCause.starvation: return '기아';
      case AnimalDeathCause.naturalDeath: return '자연사';
      case AnimalDeathCause.euthanized: return '안락사';
      case AnimalDeathCause.unknown: return '원인 불명';
      case AnimalDeathCause.none: return '';
    }
  }
}

class _GeneStatusCard extends StatelessWidget {
  final AnimalInstance animal;
  final GeneInfo gene;
  const _GeneStatusCard({required this.animal, required this.gene});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: Colors.purpleAccent, size: 18),
              const SizedBox(width: 8),
              Text('${gene.symbol} - ${gene.fullName}',
                  style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow('주입 방법', animal.geneInjectionMethod ?? '?'),
          _InfoRow('주입일',
              animal.geneInjectionDate != null
                  ? _formatDate(animal.geneInjectionDate!)
                  : '?'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('예상 표현형',
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 4),
                Text(
                  animal.geneInjectionMethod?.contains('KO') == true
                      ? gene.knockoutPhenotype
                      : gene.overexpressionPhenotype,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

class _DeathCard extends StatelessWidget {
  final AnimalInstance animal;
  const _DeathCard({required this.animal});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow('사인', _causeLabel(animal.deathCause)),
          if (animal.deathDate != null)
            _InfoRow('폐사일', '${animal.deathDate!.year}.${animal.deathDate!.month.toString().padLeft(2,'0')}.${animal.deathDate!.day.toString().padLeft(2,'0')}'),
          _InfoRow('부검 여부', animal.necropsyDone ? '완료' : '미실시'),
        ],
      ),
    );
  }
}

class _NecropsyResultCard extends StatelessWidget {
  final AnimalInstance animal;
  const _NecropsyResultCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (animal.necropsyDate != null)
            _InfoRow('부검일', '${animal.necropsyDate!.year}.${animal.necropsyDate!.month.toString().padLeft(2,'0')}.${animal.necropsyDate!.day.toString().padLeft(2,'0')}'),
          _InfoRow('처리 방법', animal.necropsyDisposal ?? '?'),
          const SizedBox(height: 6),
          const Text('채취 장기:', style: TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: animal.necropsyOrgans.map((id) {
              final organ = NecropsyDatabase.organs.firstWhere(
                  (o) => o.id == id,
                  orElse: () => NecropsynItem(
                      id: '', name: id, description: '', suitableFor: const []));
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(organ.name,
                    style: const TextStyle(
                        color: Colors.tealAccent, fontSize: 10)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeedWaterCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final DateTime? lastTime;
  final double starveDays;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback? onPressed;

  const _FeedWaterCard({
    required this.icon, required this.title, required this.subtitle,
    required this.lastTime, required this.starveDays,
    required this.buttonLabel, required this.buttonColor, required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = lastTime != null
        ? now.difference(lastTime!).inSeconds / 86400.0
        : null;
    final ratio = days != null ? (days / starveDays).clamp(0.0, 1.0) : 0.0;
    final dangerColor = ratio > 0.7 ? Colors.redAccent : ratio > 0.4 ? Colors.amberAccent : Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(buttonLabel,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          if (days != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '마지막 ${buttonLabel == '급이' ? '급이' : '급수'}: ${days.toStringAsFixed(1)}일 전',
                  style: TextStyle(color: dangerColor, fontSize: 11),
                ),
                Text(
                  '생존 한계: ${starveDays.toStringAsFixed(0)}일',
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(dangerColor),
              ),
            ),
            if (ratio > 0.7) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.redAccent, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    buttonLabel == '급이' ? '⚠️ 사료가 부족합니다! 체중이 감소합니다.' : '⚠️ 탈수 위험! 즉시 급수하세요.',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoGrid(this.items);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(items[i].label,
                  style: const TextStyle(color: Colors.white38, fontSize: 9)),
              Text(items[i].value,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 13,
            fontWeight: FontWeight.bold));
  }
}
