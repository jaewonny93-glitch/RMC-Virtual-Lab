import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/animal_model.dart';

class GeneInjectionScreen extends StatefulWidget {
  final String animalId;
  const GeneInjectionScreen({super.key, required this.animalId});

  @override
  State<GeneInjectionScreen> createState() => _GeneInjectionScreenState();
}

class _GeneInjectionScreenState extends State<GeneInjectionScreen> {
  GeneInfo? _selectedGene;
  String _selectedMethod = '';

  @override
  Widget build(BuildContext context) {
    final inVivo = context.watch<InVivoState>();
    final animal = inVivo.animals.firstWhere((a) => a.id == widget.animalId,
        orElse: () => AnimalInstance(
              id: '', speciesId: '', tag: '',
              birthDate: DateTime.now(), admitDate: DateTime.now(), weightG: 0,
            ));

    if (animal.id.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1A0A),
        appBar: AppBar(backgroundColor: const Color(0xFF0D1F0D)),
        body: const Center(child: Text('동물을 찾을 수 없습니다.', style: TextStyle(color: Colors.white54))),
      );
    }

    final species = AnimalDatabase.findById(animal.speciesId);

    // 이 동물 종에 맞는 유전자
    final compatibleGenes = GeneDatabase.genes.where((g) =>
        g.suitableSpecies.isEmpty || g.suitableSpecies.contains(animal.speciesId)).toList();

    // 이미 주입된 경우
    final alreadyInjected = animal.injectedGeneId != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.purpleAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('유전자 주입',
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
            // 현재 동물 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
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
                      ],
                    ),
                  ),
                  if (alreadyInjected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('이미 주입됨',
                          style: TextStyle(
                              color: Colors.amberAccent, fontSize: 10)),
                    ),
                ],
              ),
            ),

            if (alreadyInjected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '이미 유전자가 주입되어 있습니다 (${GeneDatabase.findById(animal.injectedGeneId!)?.symbol ?? animal.injectedGeneId}). 재주입 시 기존 정보가 대체됩니다.',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 유전자 선택
            _SectionTitle('유전자 선택 (NCBI 기반 DB)'),
            const SizedBox(height: 10),

            if (compatibleGenes.isEmpty)
              const Text('이 동물 종에 등록된 유전자가 없습니다.',
                  style: TextStyle(color: Colors.white38))
            else
              ...compatibleGenes.map((gene) => _GeneCard(
                    gene: gene,
                    isSelected: _selectedGene?.id == gene.id,
                    onTap: () => setState(() {
                      _selectedGene = gene;
                      if (_selectedMethod.isEmpty && gene.deliveryMethod.isNotEmpty) {
                        _selectedMethod = gene.deliveryMethod.split('/').first.trim();
                      }
                    }),
                  )),

            // 주입 방법 선택
            if (_selectedGene != null) ...[
              const SizedBox(height: 20),
              _SectionTitle('주입 방법'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedGene!.deliveryMethod
                    .split('/')
                    .map((m) => m.trim())
                    .where((m) => m.isNotEmpty)
                    .map((method) {
                  final selected = _selectedMethod == method;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMethod = method),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.purple.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? Colors.purpleAccent
                              : Colors.white24,
                        ),
                      ),
                      child: Text(
                        method,
                        style: TextStyle(
                          color: selected
                              ? Colors.purpleAccent
                              : Colors.white54,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 예상 표현형 미리보기
              const SizedBox(height: 20),
              _SectionTitle('예상 반응'),
              const SizedBox(height: 10),
              _PhenotypeCard(gene: _selectedGene!, method: _selectedMethod),
            ],

            const SizedBox(height: 28),

            // 주입 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _canInject ? _inject : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  disabledBackgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.science, color: Colors.white),
                label: const Text('유전자 주입 실행',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 유전자 주입 후 표현형은 예측값이며, 실제 실험 결과와 다를 수 있습니다.',
              style: TextStyle(color: Colors.white24, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool get _canInject =>
      _selectedGene != null && _selectedMethod.isNotEmpty;

  void _inject() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('유전자 주입 확인',
            style: TextStyle(color: Colors.purpleAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('유전자: ${_selectedGene!.symbol} (${_selectedGene!.fullName})',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text('방법: $_selectedMethod',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 12),
            const Text(
              '유전자 주입을 진행하시겠습니까?',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InVivoState>().injectGene(
                widget.animalId,
                _selectedGene!.id,
                _selectedMethod,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🧬 유전자 주입 완료: ${_selectedGene!.symbol} ($_selectedMethod)'),
                  backgroundColor: Colors.purple.shade700,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('주입', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── 유전자 카드 ────────────────────────────────────────
class _GeneCard extends StatelessWidget {
  final GeneInfo gene;
  final bool isSelected;
  final VoidCallback onTap;

  const _GeneCard(
      {required this.gene,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.purpleAccent
                : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(gene.symbol,
                      style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(gene.fullName,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: Colors.purpleAccent, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(gene.function,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.link, color: Colors.white24, size: 11),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(gene.source,
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 9)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 예상 표현형 카드 ──────────────────────────────────
class _PhenotypeCard extends StatelessWidget {
  final GeneInfo gene;
  final String method;

  const _PhenotypeCard({required this.gene, required this.method});

  @override
  Widget build(BuildContext context) {
    final isKO = method.contains('KO') || method.contains('Knockout') || method.contains('Cre');
    final phenotype = isKO ? gene.knockoutPhenotype : gene.overexpressionPhenotype;
    final label = isKO ? 'Knockout (KO)' : 'Overexpression (OE)';
    final color = isKO ? Colors.orangeAccent : Colors.tealAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isKO ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(phenotype,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
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
    return Row(
      children: [
        const Icon(Icons.science, color: Colors.purpleAccent, size: 15),
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
