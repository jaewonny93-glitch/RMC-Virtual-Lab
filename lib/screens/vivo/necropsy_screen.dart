import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/animal_model.dart';

class NecropsyScreen extends StatefulWidget {
  final String animalId;
  const NecropsyScreen({super.key, required this.animalId});

  @override
  State<NecropsyScreen> createState() => _NecropsyScreenState();
}

class _NecropsyScreenState extends State<NecropsyScreen> {
  final Set<String> _selectedOrgans = {};
  String _selectedDisposal = '';

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final animal = inVivo.animals.firstWhere(
      (a) => a.id == widget.animalId,
      orElse: () => AnimalInstance(
        id: '', speciesId: '', tag: '',
        birthDate: DateTime.now(), admitDate: DateTime.now(), weightG: 0,
      ),
    );

    if (animal.id.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1A0A),
        appBar: AppBar(backgroundColor: const Color(0xFF0D1F0D)),
        body: const Center(child: Text('동물을 찾을 수 없습니다.', style: TextStyle(color: Colors.white54))),
      );
    }

    if (animal.necropsyDone) {
      return _NecropsyResultView(animal: animal);
    }

    final species = AnimalDatabase.findById(animal.speciesId);

    // 이 동물 종에 맞는 장기
    final compatibleOrgans = NecropsyDatabase.organs.where((o) =>
        o.suitableFor.isEmpty || o.suitableFor.contains(animal.speciesId)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('부검 (Necropsy)',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(animal.tag,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 동물 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Text(species?.iconEmoji ?? '🐭',
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(animal.tag,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(species?.name ?? animal.speciesId,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '나이: ${animal.ageInDays.toStringAsFixed(1)}일령 · 체중: ${animal.weightG.toStringAsFixed(1)}g',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: animal.status == AnimalStatus.dead
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      animal.status == AnimalStatus.dead ? '폐사' : '생존 (안락사 예정)',
                      style: TextStyle(
                        color: animal.status == AnimalStatus.dead
                            ? Colors.redAccent
                            : Colors.amberAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (animal.status != AnimalStatus.dead) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amberAccent, size: 14),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '살아있는 동물의 부검 시 안락사 후 진행됩니다.',
                        style: TextStyle(color: Colors.amberAccent, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 채취 장기 선택
            _SectionTitle(icon: Icons.biotech, title: '채취 장기 선택'),
            const SizedBox(height: 4),
            Text('${_selectedOrgans.length}개 선택됨',
                style: const TextStyle(color: Colors.tealAccent, fontSize: 11)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
              ),
              itemCount: compatibleOrgans.length,
              itemBuilder: (_, i) {
                final organ = compatibleOrgans[i];
                final selected = _selectedOrgans.contains(organ.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedOrgans.remove(organ.id);
                      } else {
                        _selectedOrgans.add(organ.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.teal.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? Colors.tealAccent : Colors.white12,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selected ? Icons.check_box : Icons.check_box_outline_blank,
                              color: selected ? Colors.tealAccent : Colors.white24,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(organ.name,
                                  style: TextStyle(
                                      color: selected ? Colors.tealAccent : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(organ.description,
                            style: const TextStyle(
                                color: Colors.white30, fontSize: 9),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 처리 방법 선택
            _SectionTitle(icon: Icons.inventory, title: '샘플 처리 방법'),
            const SizedBox(height: 10),
            ...NecropsyDatabase.disposalMethods.map((method) {
              final selected = _selectedDisposal == method;
              return GestureDetector(
                onTap: () => setState(() => _selectedDisposal = method),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.teal.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.tealAccent : Colors.white12,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: selected ? Colors.tealAccent : Colors.white24,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(method,
                                style: TextStyle(
                                    color: selected ? Colors.tealAccent : Colors.white70,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13)),
                            Text(
                              _getMethodDesc(method),
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            // 부검 실행 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _canPerform ? _performNecropsy : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  disabledBackgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.biotech, color: Colors.white),
                label: Text(
                  animal.status == AnimalStatus.dead ? '부검 실행' : '안락사 후 부검 실행',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 장기를 하나 이상 선택하고 처리 방법을 선택해야 부검이 가능합니다.',
              style: TextStyle(color: Colors.white24, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool get _canPerform =>
      _selectedOrgans.isNotEmpty && _selectedDisposal.isNotEmpty;

  String _getMethodDesc(String method) {
    switch (method) {
      case '보관 (파라핀 블록)':
        return '포르말린 고정 후 파라핀 포매. 장기 보관 및 추후 분석 가능.';
      case '병리 검사 의뢰':
        return '전문 병리기관에 검사 의뢰. 조직학적 이상 판정.';
      case 'H&E Staining':
        return '헤마톡실린-에오신 염색. 세포 구조 및 조직 형태 관찰.';
      default:
        return '';
    }
  }

  void _performNecropsy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('부검 확인',
            style: TextStyle(color: Colors.tealAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '채취 장기: ${_selectedOrgans.length}개\n처리 방법: $_selectedDisposal',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              '부검을 진행하면 되돌릴 수 없습니다. 계속하시겠습니까?',
              style: TextStyle(color: Colors.amberAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InVivoState>().performNecropsy(
                widget.animalId,
                _selectedOrgans.toList(),
                _selectedDisposal,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ 부검이 완료되었습니다.'),
                  backgroundColor: Colors.teal.shade700,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('부검 실행', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── 부검 완료 결과 뷰 ────────────────────────────────────
class _NecropsyResultView extends StatelessWidget {
  final AnimalInstance animal;
  const _NecropsyResultView({required this.animal});

  @override
  Widget build(BuildContext context) {
    final species = AnimalDatabase.findById(animal.speciesId);
    final gene = animal.injectedGeneId != null
        ? GeneDatabase.findById(animal.injectedGeneId!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.tealAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('부검 결과',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 부검 완료 배너
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withValues(alpha: 0.2),
                    Colors.green.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.tealAccent, size: 48),
                  const SizedBox(height: 8),
                  const Text('부검 완료',
                      style: TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${species?.iconEmoji ?? ''} ${animal.tag}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (animal.necropsyDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '부검일: ${animal.necropsyDate!.year}.${animal.necropsyDate!.month.toString().padLeft(2, '0')}.${animal.necropsyDate!.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 처리 결과
            _ResultSection(title: '처리 방법', content: animal.necropsyDisposal ?? '?'),
            const SizedBox(height: 16),

            // H&E 염색 결과 (선택된 경우)
            if (animal.necropsyDisposal == 'H&E Staining') ...[
              _SectionTitle2('H&E 염색 결과 (시뮬레이션)'),
              const SizedBox(height: 10),
              _HEStainingCard(animal: animal, gene: gene),
              const SizedBox(height: 16),
            ],

            // 채취 장기 목록
            _SectionTitle2('채취 장기 (${animal.necropsyOrgans.length}개)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: animal.necropsyOrgans.map((id) {
                final organ = NecropsyDatabase.organs.firstWhere(
                    (o) => o.id == id,
                    orElse: () => NecropsynItem(
                        id: '', name: id, description: '', suitableFor: const []));
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(organ.name,
                          style: const TextStyle(
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      Text(organ.description,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 유전자 주입 관련 소견
            if (gene != null) ...[
              _SectionTitle2('유전자 관련 소견'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🧬 ${gene.symbol} (${animal.geneInjectionMethod ?? '?'})',
                        style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      animal.geneInjectionMethod?.contains('KO') == true
                          ? gene.knockoutPhenotype
                          : gene.overexpressionPhenotype,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HEStainingCard extends StatelessWidget {
  final AnimalInstance animal;
  final GeneInfo? gene;
  const _HEStainingCard({required this.animal, required this.gene});

  @override
  Widget build(BuildContext context) {
    final findings = _generateFindings(animal, gene);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B0045).withValues(alpha: 0.15),
            const Color(0xFF0045A0).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 간이 H&E 색상 표시
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF69B4), Color(0xFF9370DB)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('H&E', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('조직 병리 소견',
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text('헤마톡실린-에오신 염색 결과',
                      style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...findings.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(top: 5, right: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF69B4),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(f,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 11, height: 1.5)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _generateFindings(AnimalInstance animal, GeneInfo? gene) {
    final List<String> findings = [];

    // 기본 소견
    findings.add('핵 (Nucleus): 헤마톡실린 청자색 염색. 정상 핵 형태 관찰.');
    findings.add('세포질 (Cytoplasm): 에오신 분홍색 염색. 세포 크기 정상 범위.');

    // 컨디션에 따른 소견
    if (animal.conditionScore < 50) {
      findings.add('조직 괴사: 세포 사멸 흔적 및 핵 농축(pyknosis) 관찰.');
      findings.add('염증 세포 침윤: 중성구 및 대식세포 다수 관찰.');
    }

    // 사인에 따른 소견
    switch (animal.deathCause) {
      case AnimalDeathCause.dehydration:
        findings.add('신장: 세뇨관 상피세포 변성. 탈수 소견.');
        findings.add('피부: 콜라겐 섬유 밀집. 수분 결핍 흔적.');
        break;
      case AnimalDeathCause.starvation:
        findings.add('간: 지방변성(steatosis). 영양 결핍 소견.');
        findings.add('근육: 근섬유 위축(atrophy). 체중 감소 소견.');
        break;
      case AnimalDeathCause.oxygenLow:
        findings.add('폐: 폐포 허탈 및 충혈. 저산소증 소견.');
        findings.add('심장: 심근세포 공포화. 허혈 손상 흔적.');
        break;
      case AnimalDeathCause.oxygenHigh:
        findings.add('폐: 폐포 과확장. 산소 독성 소견.');
        findings.add('기관지: 상피세포 박리 및 손상.');
        break;
      default:
        break;
    }

    // 유전자 KO 소견
    if (gene != null) {
      final isKO = animal.geneInjectionMethod?.contains('KO') == true;
      if (isKO) {
        switch (gene.id) {
          case 'tp53':
            findings.add('비정형 세포 및 핵분열 증가. ${gene.symbol} KO에 의한 종양성 병변 의심.');
            break;
          case 'kras':
            findings.add('선상피세포 과증식. KRAS G12D 돌연변이 관련 변화.');
            break;
          case 'vegfa':
            findings.add('혈관 형성 감소. 조직 내 허혈성 변화 관찰.');
            break;
          default:
            findings.add('${gene.symbol} 결핍에 의한 조직 변화 관찰. 추가 분석 필요.');
        }
      } else {
        findings.add('${gene.symbol} 과발현 관련 세포 변화. 면역조직화학(IHC) 추가 권장.');
      }
    }

    return findings;
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final String content;
  const _ResultSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text('$title: ',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Expanded(
            child: Text(content,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.tealAccent, size: 16),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SectionTitle2 extends StatelessWidget {
  final String title;
  const _SectionTitle2(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: Colors.tealAccent,
            fontSize: 13,
            fontWeight: FontWeight.bold));
  }
}
