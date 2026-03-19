import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/animal_model.dart';
import '../../models/user_model.dart';

// ══════════════════════════════════════════════════
// Vivo Data Screen - 데이터 요약
// ══════════════════════════════════════════════════
class VivoDataScreen extends StatelessWidget {
  const VivoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final all = inVivo.animals;
    final alive = inVivo.aliveAnimals;
    final dead = inVivo.deadAnimals;

    // 종별 집계
    final Map<String, int> speciesCount = {};
    for (final a in alive) {
      speciesCount[a.speciesId] = (speciesCount[a.speciesId] ?? 0) + 1;
    }

    // 유전자 주입 수
    final injectedCount = alive.where((a) => a.injectedGeneId != null).length;

    // 부검 완료 수
    final necropsied = dead.where((a) => a.necropsyDone).length;

    // 사인 분포
    final Map<AnimalDeathCause, int> causeCount = {};
    for (final a in dead) {
      causeCount[a.deathCause] = (causeCount[a.deathCause] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 요약 카드
          _DataCard(
            title: '전체 현황',
            children: [
              _DataRow('총 동물 수', '${all.length}마리'),
              _DataRow('생존', '${alive.length}마리', color: Colors.greenAccent),
              _DataRow('폐사', '${dead.length}마리', color: Colors.redAccent),
              _DataRow('유전자 주입', '$injectedCount마리', color: Colors.purpleAccent),
              _DataRow('부검 완료', '$necropsied마리', color: Colors.tealAccent),
            ],
          ),
          const SizedBox(height: 16),

          // 컨디션 분포
          if (alive.isNotEmpty) ...[
            _DataCard(
              title: '생존 동물 컨디션 분포',
              children: [
                _DataRow('건강 (80~100%)',
                    '${alive.where((a) => a.status == AnimalStatus.healthy).length}마리',
                    color: Colors.greenAccent),
                _DataRow('스트레스 (60~80%)',
                    '${alive.where((a) => a.status == AnimalStatus.stressed).length}마리',
                    color: Colors.amberAccent),
                _DataRow('아픔 (30~60%)',
                    '${alive.where((a) => a.status == AnimalStatus.sick).length}마리',
                    color: Colors.orangeAccent),
                _DataRow('위험 (0~30%)',
                    '${alive.where((a) => a.status == AnimalStatus.critical).length}마리',
                    color: Colors.redAccent),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 종별 현황
          if (speciesCount.isNotEmpty) ...[
            _DataCard(
              title: '종별 현황 (생존)',
              children: speciesCount.entries.map((e) {
                final sp = AnimalDatabase.findById(e.key);
                return _DataRow(
                  '${sp?.iconEmoji ?? ''} ${sp?.name ?? e.key}',
                  '${e.value}마리',
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 폐사 원인 분포
          if (dead.isNotEmpty) ...[
            _DataCard(
              title: '폐사 원인 분포',
              children: causeCount.entries.map((e) {
                return _DataRow(_causeLabel(e.key), '${e.value}마리');
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 유전자 주입 현황
          if (injectedCount > 0) ...[
            _DataCard(
              title: '유전자 주입 현황',
              children: () {
                final Map<String, int> geneCount = {};
                for (final a in alive.where((a) => a.injectedGeneId != null)) {
                  geneCount[a.injectedGeneId!] = (geneCount[a.injectedGeneId!] ?? 0) + 1;
                }
                return geneCount.entries.map((e) {
                  final gene = GeneDatabase.findById(e.key);
                  return _DataRow(
                    '🧬 ${gene?.symbol ?? e.key}',
                    '${e.value}마리',
                    color: Colors.purpleAccent,
                  );
                }).toList();
              }(),
            ),
          ],
        ],
      ),
    );
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
      case AnimalDeathCause.none: return '미상';
    }
  }
}

// ══════════════════════════════════════════════════
// Vivo History Screen - 부검 이력
// ══════════════════════════════════════════════════
class VivoHistoryScreen extends StatelessWidget {
  const VivoHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final dead = inVivo.deadAnimals
      ..sort((a, b) => (b.deathDate ?? DateTime.now())
          .compareTo(a.deathDate ?? DateTime.now()));

    return dead.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📋', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text('폐사 이력이 없습니다.',
                    style: TextStyle(color: Colors.white38, fontSize: 14)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dead.length,
            itemBuilder: (_, i) => _HistoryCard(animal: dead[i]),
          );
  }
}

class _HistoryCard extends StatelessWidget {
  final AnimalInstance animal;
  const _HistoryCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(animal.speciesId);
    final gene = animal.injectedGeneId != null
        ? GeneDatabase.findById(animal.injectedGeneId!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(species?.iconEmoji ?? '🐭',
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(animal.tag,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text(species?.name ?? animal.speciesId,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              if (animal.deathDate != null)
                Text(
                  _formatDate(animal.deathDate!),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: [
              _Chip(label: _causeLabel(animal.deathCause), color: Colors.redAccent),
              _Chip(
                  label: '${animal.ageInDays.toStringAsFixed(0)}일령',
                  color: Colors.white38),
              if (gene != null)
                _Chip(label: '🧬 ${gene.symbol}', color: Colors.purpleAccent),
              if (animal.necropsyDone)
                _Chip(label: '부검: ${animal.necropsyDisposal ?? '?'}',
                    color: Colors.tealAccent),
              if (animal.necropsyOrgans.isNotEmpty)
                _Chip(
                    label: '장기 ${animal.necropsyOrgans.length}개',
                    color: Colors.tealAccent),
            ],
          ),
        ],
      ),
    );
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
      case AnimalDeathCause.none: return '미상';
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

// ══════════════════════════════════════════════════
// Vivo Settings Screen
// ══════════════════════════════════════════════════
class VivoSettingsScreen extends StatelessWidget {
  const VivoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.greenAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(user.affiliation,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      Text(user.roleDisplay,
                          style: const TextStyle(
                              color: Colors.greenAccent, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 시뮬레이션 정보
          const Text('시뮬레이션 설정',
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _SettingItem(
            icon: Icons.timer,
            title: '시간 갱신 주기',
            subtitle: '30초마다 동물 컨디션 자동 갱신',
          ),
          _SettingItem(
            icon: Icons.calendar_today,
            title: '1일 = 실제 24시간',
            subtitle: '실제 시간 기준으로 동물 노화 진행',
          ),
          _SettingItem(
            icon: Icons.warning_amber_rounded,
            title: '자동 폐사 판정',
            subtitle: '탈수, 기아, 산소 이상 시 자동 폐사',
          ),

          const SizedBox(height: 20),

          // 표준 관리 수치
          const Text('표준 관리 수치',
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _SettingItem(
            icon: Icons.air,
            title: '산소 (포유류)',
            subtitle: '권장: 19.5~23.5% / 위험: <15% 또는 >26%',
          ),
          _SettingItem(
            icon: Icons.water_drop,
            title: '산소 (제브라피시)',
            subtitle: '권장 용존산소: 6.0~9.0 mg/L',
          ),
          _SettingItem(
            icon: Icons.local_dining,
            title: '급이 기준',
            subtitle: '마우스 4.5g/일, 랫트 20g/일, 토끼 150g/일',
          ),
          _SettingItem(
            icon: Icons.water,
            title: '급수 기준',
            subtitle: '마우스 5mL/일, 랫트 35mL/일, 토끼 300mL/일',
          ),

          const SizedBox(height: 20),

          // 앱 정보
          const Text('앱 정보',
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('앱 이름', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text('RMC Virtual Lab - In Vivo',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('기관', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text('분당서울대학교병원 재생의학센터',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('유전자 DB', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text('NCBI Gene 기반', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공용 위젯 ─────────────────────────────────────────
class _DataCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DataCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _DataRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9)),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SettingItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
