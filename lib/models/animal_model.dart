import 'dart:math';
import 'package:flutter/foundation.dart';

// ══════════════════════════════════════════════════
// 실험동물 종류 DB
// ══════════════════════════════════════════════════
class AnimalSpecies {
  final String id;
  final String name;
  final String scientificName;
  final String strain;
  final String description;
  final String category;
  final String iconEmoji;
  // 생애주기 (일)
  final double lifespanDays;
  final double adultAgeDays;
  // 표준 관리 수치
  final double stdOxygenMin;   // 최소 산소 %
  final double stdOxygenMax;   // 최대 산소 %
  final double stdFeedGPerDay; // 일일 표준 사료 (g)
  final double stdWaterMlPerDay; // 일일 표준 물 (mL)
  final double avgWeightG;     // 평균 체중 (g)
  // 사망 임계값
  final double oxygenDeathMin; // 이 이하면 사망 위험
  final double oxygenDeathMax; // 이 이상이면 사망 위험
  final double waterStarveDays; // 물 없이 생존 가능 일수
  final double feedStarveDays;  // 먹이 없이 생존 가능 일수
  // 케이지 요구사항
  final String cageSize;
  final int maxPerCage;

  const AnimalSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.strain,
    required this.description,
    required this.category,
    required this.iconEmoji,
    required this.lifespanDays,
    required this.adultAgeDays,
    required this.stdOxygenMin,
    required this.stdOxygenMax,
    required this.stdFeedGPerDay,
    required this.stdWaterMlPerDay,
    required this.avgWeightG,
    required this.oxygenDeathMin,
    required this.oxygenDeathMax,
    required this.waterStarveDays,
    required this.feedStarveDays,
    required this.cageSize,
    required this.maxPerCage,
  });
}

class AnimalDatabase {
  static const List<AnimalSpecies> species = [
    AnimalSpecies(
      id: 'mouse_c57bl6',
      name: '마우스 (C57BL/6)',
      scientificName: 'Mus musculus',
      strain: 'C57BL/6',
      description: '가장 널리 사용되는 inbred 마우스 계통. 면역학, 종양학, 신경과학 연구의 표준.',
      category: '설치류',
      iconEmoji: '🐭',
      lifespanDays: 730,
      adultAgeDays: 56,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 4.5,
      stdWaterMlPerDay: 5.0,
      avgWeightG: 25.0,
      oxygenDeathMin: 15.0,
      oxygenDeathMax: 26.0,
      waterStarveDays: 3.0,
      feedStarveDays: 7.0,
      cageSize: 'Type II (표준)',
      maxPerCage: 5,
    ),
    AnimalSpecies(
      id: 'mouse_balbc',
      name: '마우스 (BALB/c)',
      scientificName: 'Mus musculus',
      strain: 'BALB/c',
      description: '면역학 연구 특화 마우스. 항체 생산 및 알레르기 모델에 활용.',
      category: '설치류',
      iconEmoji: '🐭',
      lifespanDays: 700,
      adultAgeDays: 56,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 4.5,
      stdWaterMlPerDay: 5.0,
      avgWeightG: 22.0,
      oxygenDeathMin: 15.0,
      oxygenDeathMax: 26.0,
      waterStarveDays: 3.0,
      feedStarveDays: 7.0,
      cageSize: 'Type II (표준)',
      maxPerCage: 5,
    ),
    AnimalSpecies(
      id: 'mouse_nude',
      name: '누드마우스 (Nude)',
      scientificName: 'Mus musculus',
      strain: 'Athymic Nude',
      description: 'T세포 결핍 면역결핍 마우스. 이종이식(xenograft) 종양 모델의 표준.',
      category: '설치류',
      iconEmoji: '🐭',
      lifespanDays: 365,
      adultAgeDays: 42,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 4.0,
      stdWaterMlPerDay: 5.0,
      avgWeightG: 20.0,
      oxygenDeathMin: 16.0,
      oxygenDeathMax: 25.0,
      waterStarveDays: 2.5,
      feedStarveDays: 6.0,
      cageSize: 'IVC (개별환기)',
      maxPerCage: 5,
    ),
    AnimalSpecies(
      id: 'rat_sd',
      name: '랫트 (Sprague-Dawley)',
      scientificName: 'Rattus norvegicus',
      strain: 'Sprague-Dawley',
      description: '독성시험, 약동학 연구에 가장 많이 사용되는 outbred 랫트 계통.',
      category: '설치류',
      iconEmoji: '🐀',
      lifespanDays: 900,
      adultAgeDays: 70,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 20.0,
      stdWaterMlPerDay: 35.0,
      avgWeightG: 300.0,
      oxygenDeathMin: 15.0,
      oxygenDeathMax: 26.0,
      waterStarveDays: 3.0,
      feedStarveDays: 10.0,
      cageSize: 'Type IV (대형)',
      maxPerCage: 3,
    ),
    AnimalSpecies(
      id: 'rat_wistar',
      name: '랫트 (Wistar)',
      scientificName: 'Rattus norvegicus',
      strain: 'Wistar',
      description: '신경과학, 생리학 연구에 활용. 온순한 성격으로 핸들링 용이.',
      category: '설치류',
      iconEmoji: '🐀',
      lifespanDays: 900,
      adultAgeDays: 70,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 20.0,
      stdWaterMlPerDay: 35.0,
      avgWeightG: 280.0,
      oxygenDeathMin: 15.0,
      oxygenDeathMax: 26.0,
      waterStarveDays: 3.0,
      feedStarveDays: 10.0,
      cageSize: 'Type IV (대형)',
      maxPerCage: 3,
    ),
    AnimalSpecies(
      id: 'rabbit_nzw',
      name: '토끼 (New Zealand White)',
      scientificName: 'Oryctolagus cuniculus',
      strain: 'New Zealand White',
      description: '피부자극시험, 안자극시험(Draize test), 항체 생산에 사용.',
      category: '토끼',
      iconEmoji: '🐰',
      lifespanDays: 3650,
      adultAgeDays: 180,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 150.0,
      stdWaterMlPerDay: 300.0,
      avgWeightG: 4000.0,
      oxygenDeathMin: 16.0,
      oxygenDeathMax: 25.0,
      waterStarveDays: 2.0,
      feedStarveDays: 14.0,
      cageSize: 'Rabbit Cage (전용)',
      maxPerCage: 1,
    ),
    AnimalSpecies(
      id: 'guineapig',
      name: '기니피그',
      scientificName: 'Cavia porcellus',
      strain: 'Hartley',
      description: '피부감작시험, 알레르기 연구에 사용. 비타민C 결핍 모델.',
      category: '설치류',
      iconEmoji: '🐹',
      lifespanDays: 2190,
      adultAgeDays: 60,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 30.0,
      stdWaterMlPerDay: 50.0,
      avgWeightG: 700.0,
      oxygenDeathMin: 16.0,
      oxygenDeathMax: 25.0,
      waterStarveDays: 2.0,
      feedStarveDays: 7.0,
      cageSize: 'Type III (중형)',
      maxPerCage: 3,
    ),
    AnimalSpecies(
      id: 'zebrafish',
      name: '제브라피시',
      scientificName: 'Danio rerio',
      strain: 'AB / TU',
      description: '발생학, 유전학 연구 모델. 투명한 배아로 발생 과정 관찰 가능.',
      category: '어류',
      iconEmoji: '🐟',
      lifespanDays: 1095,
      adultAgeDays: 90,
      stdOxygenMin: 6.0,   // 수중 용존산소 mg/L
      stdOxygenMax: 9.0,
      stdFeedGPerDay: 0.2,
      stdWaterMlPerDay: 0.0, // 수중 생활
      avgWeightG: 0.5,
      oxygenDeathMin: 3.0,
      oxygenDeathMax: 12.0,
      waterStarveDays: 999, // 수중 생활이라 해당없음
      feedStarveDays: 14.0,
      cageSize: 'Tank 3L (전용)',
      maxPerCage: 20,
    ),
    AnimalSpecies(
      id: 'minipig',
      name: '미니피그',
      scientificName: 'Sus scrofa',
      strain: 'Göttingen Minipig',
      description: '심혈관, 피부, 약물대사 연구. 인간과 유사한 해부학적 구조.',
      category: '돼지',
      iconEmoji: '🐷',
      lifespanDays: 5475,
      adultAgeDays: 365,
      stdOxygenMin: 19.5,
      stdOxygenMax: 23.5,
      stdFeedGPerDay: 500.0,
      stdWaterMlPerDay: 1000.0,
      avgWeightG: 25000.0,
      oxygenDeathMin: 16.0,
      oxygenDeathMax: 25.0,
      waterStarveDays: 2.0,
      feedStarveDays: 21.0,
      cageSize: 'Minipig Pen (전용)',
      maxPerCage: 2,
    ),
  ];

  static AnimalSpecies? findById(String id) {
    try { return species.firstWhere((s) => s.id == id); } catch (_) { return null; }
  }
}

// ══════════════════════════════════════════════════
// 케이지 타입
// ══════════════════════════════════════════════════
class CageType {
  final String id;
  final String name;
  final String description;
  final String size;
  final List<String> suitableFor;

  const CageType({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.suitableFor,
  });
}

class CageDatabase {
  static const List<CageType> cages = [
    CageType(id: 'type2', name: 'Type II 표준 케이지', description: '마우스 표준 사육 케이지. 필터 덮개 포함.', size: '26×20×14 cm', suitableFor: ['mouse_c57bl6','mouse_balbc']),
    CageType(id: 'ivc', name: 'IVC (개별환기 케이지)', description: '무균/면역결핍 동물 전용. 독립 환기 시스템.', size: '30×20×16 cm', suitableFor: ['mouse_nude']),
    CageType(id: 'type4', name: 'Type IV 대형 케이지', description: '랫트 표준 케이지. 충분한 활동 공간 확보.', size: '56×38×20 cm', suitableFor: ['rat_sd','rat_wistar']),
    CageType(id: 'type3', name: 'Type III 중형 케이지', description: '기니피그, 햄스터 등 중형 설치류 케이지.', size: '43×27×15 cm', suitableFor: ['guineapig']),
    CageType(id: 'rabbit', name: 'Rabbit Cage (전용)', description: '토끼 전용 케이지. 철망 바닥, 건초 및 급수대 포함.', size: '80×50×40 cm', suitableFor: ['rabbit_nzw']),
    CageType(id: 'tank', name: 'Zebrafish Tank 3L', description: '제브라피시 전용 수조. 순환 필터 및 조명 포함.', size: '20×15×15 cm', suitableFor: ['zebrafish']),
    CageType(id: 'pen', name: 'Minipig Pen (전용)', description: '미니피그 전용 사육공간. 자동 급이·급수 시스템.', size: '200×150×80 cm', suitableFor: ['minipig']),
  ];
}

// ══════════════════════════════════════════════════
// 놀이시설/환경강화(Enrichment)
// ══════════════════════════════════════════════════
class EnrichmentItem {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> suitableFor; // 빈 리스트면 전체 호환
  const EnrichmentItem({
    required this.id, required this.name, required this.emoji,
    required this.description, required this.suitableFor,
  });
}

class EnrichmentDatabase {
  static const List<EnrichmentItem> items = [
    EnrichmentItem(id: 'ball', name: '운동 볼', emoji: '⚽', description: '굴릴 수 있는 플라스틱 볼. 운동 욕구 충족.', suitableFor: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd','rat_wistar']),
    EnrichmentItem(id: 'tunnel', name: '터널', emoji: '🕳️', description: '종이/플라스틱 터널. 은신처 제공.', suitableFor: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd','rat_wistar','guineapig']),
    EnrichmentItem(id: 'wood', name: '나무 블록', emoji: '🪵', description: '갉기 가능한 나무 블록. 치아 관리.', suitableFor: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd','rat_wistar','guineapig','rabbit_nzw']),
    EnrichmentItem(id: 'nest', name: '둥지 재료', emoji: '🪹', description: '종이 조각/코튼 울. 둥지 만들기 행동 유도.', suitableFor: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd','rat_wistar']),
    EnrichmentItem(id: 'wheel', name: '러닝 휠', emoji: '🎡', description: '회전 운동 기구. 자발적 운동 증가.', suitableFor: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd','rat_wistar']),
    EnrichmentItem(id: 'rope', name: '밧줄', emoji: '🪢', description: '매달리기/오르기 가능한 밧줄.', suitableFor: ['rat_sd','rat_wistar','rabbit_nzw']),
    EnrichmentItem(id: 'hay', name: '건초', emoji: '🌾', description: '토끼 전용 건초. 소화기 건강 유지.', suitableFor: ['rabbit_nzw','guineapig']),
    EnrichmentItem(id: 'shelter', name: '은신처 박스', emoji: '📦', description: '종이 박스 은신처. 스트레스 감소.', suitableFor: ['rabbit_nzw','guineapig','minipig']),
    EnrichmentItem(id: 'plant', name: '수초', emoji: '🌿', description: '제브라피시 전용 수초. 은신 및 산란.', suitableFor: ['zebrafish']),
    EnrichmentItem(id: 'stone', name: '돌멩이/자갈', emoji: '🪨', description: '제브라피시 수조 바닥재. 자연 환경 모사.', suitableFor: ['zebrafish']),
  ];
}

// ══════════════════════════════════════════════════
// 유전자 DB
// ══════════════════════════════════════════════════
class GeneInfo {
  final String id;
  final String symbol;
  final String fullName;
  final String function;
  final String knockoutPhenotype; // KO 시 표현형
  final String overexpressionPhenotype;
  final String deliveryMethod;
  final String source; // NCBI/논문
  final List<String> suitableSpecies;

  const GeneInfo({
    required this.id,
    required this.symbol,
    required this.fullName,
    required this.function,
    required this.knockoutPhenotype,
    required this.overexpressionPhenotype,
    required this.deliveryMethod,
    required this.source,
    required this.suitableSpecies,
  });
}

class GeneDatabase {
  static const List<GeneInfo> genes = [
    GeneInfo(
      id: 'tp53', symbol: 'TP53', fullName: 'Tumor Protein p53',
      function: '세포 주기 정지, 아폽토시스 유도, 종양 억제',
      knockoutPhenotype: '자발적 종양 발생 (림프종, 육종). 생후 6개월 내 70% 종양 형성.',
      overexpressionPhenotype: '성장 억제, 과도한 아폽토시스, 조기 노화.',
      deliveryMethod: 'CRISPR-Cas9 KO / Lentivirus overexpression',
      source: 'NCBI Gene ID: 22059 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc','rat_sd'],
    ),
    GeneInfo(
      id: 'kras', symbol: 'KRAS', fullName: 'Kirsten Rat Sarcoma Viral Proto-oncogene',
      function: 'RAS-MAPK 신호전달. 세포 증식, 생존 조절.',
      knockoutPhenotype: '배아 치사. 조건부 KO 시 조직 특이적 성장 이상.',
      overexpressionPhenotype: 'KRAS G12D: 폐암, 췌장암 모델. 과증식.',
      deliveryMethod: 'Conditional KO (Cre-lox) / AAV point mutation',
      source: 'NCBI Gene ID: 16653 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc','rat_sd','rat_wistar'],
    ),
    GeneInfo(
      id: 'brca1', symbol: 'BRCA1', fullName: 'Breast Cancer Gene 1',
      function: 'DNA 손상 복구, 게놈 안정성 유지.',
      knockoutPhenotype: '유방암, 난소암 자발적 발생. 배아 치사(전신 KO).',
      overexpressionPhenotype: '정상. 과도한 발현은 세포 주기 억제.',
      deliveryMethod: 'Conditional KO (Cre-lox, MMTV-Cre)',
      source: 'NCBI Gene ID: 12189 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc'],
    ),
    GeneInfo(
      id: 'egfr', symbol: 'EGFR', fullName: 'Epidermal Growth Factor Receptor',
      function: '세포 증식, 분화, 생존 신호전달.',
      knockoutPhenotype: '피부 장벽 이상, 위장관 이상. 체중 감소.',
      overexpressionPhenotype: '폐암 모델 (EGFR L858R). 과증식.',
      deliveryMethod: 'AAV / Lentivirus / CRISPR point mutation',
      source: 'NCBI Gene ID: 13649 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd'],
    ),
    GeneInfo(
      id: 'app', symbol: 'APP', fullName: 'Amyloid Precursor Protein',
      function: '신경 발달, 시냅스 형성. 아밀로이드-β 전구체.',
      knockoutPhenotype: '인지 기능 저하, 소뇌 이상.',
      overexpressionPhenotype: '알츠하이머 모델. 아밀로이드 플라크 형성.',
      deliveryMethod: 'Transgenic / AAV overexpression',
      source: 'NCBI Gene ID: 351 (Homo sapiens orthologue)',
      suitableSpecies: ['mouse_c57bl6','rat_sd','rat_wistar'],
    ),
    GeneInfo(
      id: 'ins2', symbol: 'INS2', fullName: 'Insulin 2',
      function: '인슐린 생산. 혈당 조절.',
      knockoutPhenotype: 'NOD 배경: 당뇨병 모델(Type 1). 인슐린 분비 감소.',
      overexpressionPhenotype: '저혈당증.',
      deliveryMethod: 'CRISPR-Cas9 / Transgenic',
      source: 'NCBI Gene ID: 16334 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc','rat_sd'],
    ),
    GeneInfo(
      id: 'vegfa', symbol: 'VEGFA', fullName: 'Vascular Endothelial Growth Factor A',
      function: '혈관 신생, 내피세포 증식.',
      knockoutPhenotype: '배아 치사. 혈관 형성 장애.',
      overexpressionPhenotype: '종양 혈관 신생 증가, 혈관종.',
      deliveryMethod: 'AAV / Lentivirus (조건부 KO Cre-lox)',
      source: 'NCBI Gene ID: 22339 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_nude','rat_sd'],
    ),
    GeneInfo(
      id: 'pten', symbol: 'PTEN', fullName: 'Phosphatase and Tensin Homolog',
      function: 'PI3K/AKT 신호 억제. 종양 억제 유전자.',
      knockoutPhenotype: 'PI3K 과활성. 전립선암, 자궁내막암 모델.',
      overexpressionPhenotype: '세포 성장 억제, 아폽토시스 증가.',
      deliveryMethod: 'CRISPR-Cas9 / Cre-lox conditional KO',
      source: 'NCBI Gene ID: 19211 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc','rat_sd'],
    ),
    GeneInfo(
      id: 'myc', symbol: 'MYC', fullName: 'MYC Proto-oncogene',
      function: '세포 증식, 성장, 대사 조절 전사인자.',
      knockoutPhenotype: '성장 억제, 발달 지연.',
      overexpressionPhenotype: '림프종, 간암 등 다양한 종양 모델.',
      deliveryMethod: 'Transgenic / Lentivirus / Tet-inducible system',
      source: 'NCBI Gene ID: 17869 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','mouse_balbc','rat_sd'],
    ),
    GeneInfo(
      id: 'drd2', symbol: 'DRD2', fullName: 'Dopamine Receptor D2',
      function: '도파민 신호전달. 운동 조절, 보상 회로.',
      knockoutPhenotype: '파킨슨 유사 운동 장애. 과잉행동 감소.',
      overexpressionPhenotype: '조현병 모델. 도파민 과민성.',
      deliveryMethod: 'CRISPR-Cas9 / AAV',
      source: 'NCBI Gene ID: 13489 (Mus musculus)',
      suitableSpecies: ['mouse_c57bl6','rat_sd','rat_wistar'],
    ),
  ];

  static GeneInfo? findById(String id) {
    try { return genes.firstWhere((g) => g.id == id); } catch (_) { return null; }
  }
}

// ══════════════════════════════════════════════════
// 부검 항목
// ══════════════════════════════════════════════════
class NecropsynItem {
  final String id;
  final String name;
  final String description;
  final List<String> suitableFor; // 빈 리스트면 전체
  const NecropsynItem({required this.id, required this.name, required this.description, required this.suitableFor});
}

class NecropsyDatabase {
  static const List<NecropsynItem> organs = [
    NecropsynItem(id: 'brain', name: '뇌 (Brain)', description: '신경계 이상, 종양, 염증 평가', suitableFor: []),
    NecropsynItem(id: 'heart', name: '심장 (Heart)', description: '심근 비대, 섬유화, 경색 평가', suitableFor: []),
    NecropsynItem(id: 'lung', name: '폐 (Lung)', description: '폐렴, 종양, 섬유화 평가', suitableFor: []),
    NecropsynItem(id: 'liver', name: '간 (Liver)', description: '간독성, 지방간, 종양 평가', suitableFor: []),
    NecropsynItem(id: 'kidney', name: '신장 (Kidney)', description: '신독성, 사구체신염 평가', suitableFor: []),
    NecropsynItem(id: 'spleen', name: '비장 (Spleen)', description: '면역 반응, 종양 평가', suitableFor: []),
    NecropsynItem(id: 'intestine', name: '장 (Intestine)', description: '장염, 종양, 흡수 이상 평가', suitableFor: []),
    NecropsynItem(id: 'pancreas', name: '췌장 (Pancreas)', description: '당뇨 모델, 췌장암 평가', suitableFor: []),
    NecropsynItem(id: 'tumor', name: '종양 (Tumor)', description: '이식/자발적 종양 채취 및 분석', suitableFor: []),
    NecropsynItem(id: 'blood', name: '혈액 (Blood)', description: 'CBC, 생화학 패널, 사이토카인', suitableFor: []),
    NecropsynItem(id: 'bone_marrow', name: '골수 (Bone Marrow)', description: '조혈계 이상, 세포 구성 분석', suitableFor: ['mouse_c57bl6','mouse_balbc','mouse_nude','rat_sd','rat_wistar']),
    NecropsynItem(id: 'skin', name: '피부 (Skin)', description: '피부 반응, 자극성 평가', suitableFor: ['rabbit_nzw','guineapig']),
  ];

  static const List<String> disposalMethods = ['보관 (파라핀 블록)', '병리 검사 의뢰', 'H&E Staining'];
}

// ══════════════════════════════════════════════════
// 개별 실험동물 인스턴스
// ══════════════════════════════════════════════════
enum AnimalStatus { healthy, stressed, sick, critical, dead }
enum AnimalDeathCause { none, oxygenLow, oxygenHigh, dehydration, starvation, naturalDeath, euthanized, unknown }

class AnimalInstance {
  final String id;
  final String speciesId;
  String tag; // 개체 식별 태그
  DateTime birthDate;
  DateTime admitDate;
  AnimalStatus status;
  AnimalDeathCause deathCause;
  DateTime? deathDate;

  // 체중
  double weightG;
  // 컨디션 점수 0~100
  double conditionScore;
  // 마지막 급여 시각
  DateTime? lastFeedTime;
  DateTime? lastWaterTime;
  // 산소 설정
  double oxygenPercent;
  // 유전자 주입
  String? injectedGeneId;
  DateTime? geneInjectionDate;
  String? geneInjectionMethod;
  // 부검 여부
  bool necropsyDone;
  List<String> necropsyOrgans;
  String? necropsyDisposal;
  DateTime? necropsyDate;
  // 케이지 ID
  String? cageId;
  List<String> enrichmentIds;
  // 메모
  String notes;

  AnimalInstance({
    required this.id,
    required this.speciesId,
    required this.tag,
    required this.birthDate,
    required this.admitDate,
    this.status = AnimalStatus.healthy,
    this.deathCause = AnimalDeathCause.none,
    this.deathDate,
    required this.weightG,
    this.conditionScore = 100.0,
    this.lastFeedTime,
    this.lastWaterTime,
    this.oxygenPercent = 21.0,
    this.injectedGeneId,
    this.geneInjectionDate,
    this.geneInjectionMethod,
    this.necropsyDone = false,
    List<String>? necropsyOrgans,
    this.necropsyDisposal,
    this.necropsyDate,
    this.cageId,
    List<String>? enrichmentIds,
    this.notes = '',
  })  : necropsyOrgans = necropsyOrgans ?? [],
        enrichmentIds = enrichmentIds ?? [];

  double get ageInDays => DateTime.now().difference(birthDate).inMinutes / (60 * 24).toDouble();

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id, 'speciesId': speciesId, 'tag': tag,
    'birthDate': birthDate.toIso8601String(),
    'admitDate': admitDate.toIso8601String(),
    'status': status.index, 'deathCause': deathCause.index,
    'deathDate': deathDate?.toIso8601String(),
    'weightG': weightG, 'conditionScore': conditionScore,
    'lastFeedTime': lastFeedTime?.toIso8601String(),
    'lastWaterTime': lastWaterTime?.toIso8601String(),
    'oxygenPercent': oxygenPercent,
    'injectedGeneId': injectedGeneId,
    'geneInjectionDate': geneInjectionDate?.toIso8601String(),
    'geneInjectionMethod': geneInjectionMethod,
    'necropsyDone': necropsyDone,
    'necropsyOrgans': necropsyOrgans,
    'necropsyDisposal': necropsyDisposal,
    'necropsyDate': necropsyDate?.toIso8601String(),
    'cageId': cageId,
    'enrichmentIds': enrichmentIds,
    'notes': notes,
  };

  factory AnimalInstance.fromJson(Map<String, dynamic> j) => AnimalInstance(
    id: j['id'] as String,
    speciesId: j['speciesId'] as String,
    tag: j['tag'] as String,
    birthDate: DateTime.parse(j['birthDate'] as String),
    admitDate: DateTime.parse(j['admitDate'] as String),
    status: AnimalStatus.values[j['status'] as int],
    deathCause: AnimalDeathCause.values[j['deathCause'] as int],
    deathDate: j['deathDate'] != null ? DateTime.parse(j['deathDate'] as String) : null,
    weightG: (j['weightG'] as num).toDouble(),
    conditionScore: (j['conditionScore'] as num).toDouble(),
    lastFeedTime: j['lastFeedTime'] != null ? DateTime.parse(j['lastFeedTime'] as String) : null,
    lastWaterTime: j['lastWaterTime'] != null ? DateTime.parse(j['lastWaterTime'] as String) : null,
    oxygenPercent: (j['oxygenPercent'] as num).toDouble(),
    injectedGeneId: j['injectedGeneId'] as String?,
    geneInjectionDate: j['geneInjectionDate'] != null ? DateTime.parse(j['geneInjectionDate'] as String) : null,
    geneInjectionMethod: j['geneInjectionMethod'] as String?,
    necropsyDone: j['necropsyDone'] as bool? ?? false,
    necropsyOrgans: List<String>.from(j['necropsyOrgans'] as List? ?? []),
    necropsyDisposal: j['necropsyDisposal'] as String?,
    necropsyDate: j['necropsyDate'] != null ? DateTime.parse(j['necropsyDate'] as String) : null,
    cageId: j['cageId'] as String?,
    enrichmentIds: List<String>.from(j['enrichmentIds'] as List? ?? []),
    notes: j['notes'] as String? ?? '',
  );
}

// ══════════════════════════════════════════════════
// 동물 입고 신청
// ══════════════════════════════════════════════════
enum AnimalRequestStatus { pending, approved, rejected }

class AnimalAdmissionRequest {
  final String id;
  final String userId;
  final String userName;
  final String speciesId;
  final int count;
  final String purpose;
  final DateTime requestDate;
  AnimalRequestStatus status;
  String? adminNote;

  AnimalAdmissionRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.speciesId,
    required this.count,
    required this.purpose,
    required this.requestDate,
    this.status = AnimalRequestStatus.pending,
    this.adminNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'userName': userName,
    'speciesId': speciesId, 'count': count, 'purpose': purpose,
    'requestDate': requestDate.toIso8601String(),
    'status': status.index, 'adminNote': adminNote,
  };

  factory AnimalAdmissionRequest.fromJson(Map<String, dynamic> j) =>
    AnimalAdmissionRequest(
      id: j['id'] as String,
      userId: j['userId'] as String,
      userName: j['userName'] as String,
      speciesId: j['speciesId'] as String,
      count: j['count'] as int,
      purpose: j['purpose'] as String,
      requestDate: DateTime.parse(j['requestDate'] as String),
      status: AnimalRequestStatus.values[j['status'] as int],
      adminNote: j['adminNote'] as String?,
    );
}

// ══════════════════════════════════════════════════
// In Vivo 앱 상태 Provider
// ══════════════════════════════════════════════════
class InVivoState extends ChangeNotifier {
  List<AnimalInstance> _animals = [];
  List<AnimalAdmissionRequest> _requests = [];

  List<AnimalInstance> get animals => _animals;
  List<AnimalInstance> get aliveAnimals => _animals.where((a) => a.status != AnimalStatus.dead).toList();
  List<AnimalInstance> get deadAnimals => _animals.where((a) => a.status == AnimalStatus.dead).toList();
  List<AnimalAdmissionRequest> get requests => _requests;
  List<AnimalAdmissionRequest> get pendingRequests =>
      _requests.where((r) => r.status == AnimalRequestStatus.pending).toList();

  // 동물 추가 (입고 승인 후)
  void addAnimals(String speciesId, int count, String userId) {
    final species = AnimalDatabase.findById(speciesId);
    if (species == null) return;
    final now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final a = AnimalInstance(
        id: '${now.millisecondsSinceEpoch}_$i',
        speciesId: speciesId,
        tag: '${species.name.split(' ').first}-${(_animals.length + i + 1).toString().padLeft(3, '0')}',
        birthDate: now.subtract(Duration(days: (species.adultAgeDays * 0.8).toInt())),
        admitDate: now,
        weightG: species.avgWeightG,
        lastFeedTime: now,
        lastWaterTime: now,
        oxygenPercent: 21.0,
      );
      _animals.add(a);
    }
    notifyListeners();
  }

  // 입고 신청
  void submitAdmissionRequest(AnimalAdmissionRequest req) {
    _requests.add(req);
    notifyListeners();
  }

  // 관리자 승인/거절
  void approveRequest(String reqId, String? adminNote) {
    final req = _requests.firstWhere((r) => r.id == reqId);
    req.status = AnimalRequestStatus.approved;
    req.adminNote = adminNote;
    addAnimals(req.speciesId, req.count, req.userId);
    notifyListeners();
  }

  void rejectRequest(String reqId, String? adminNote) {
    final req = _requests.firstWhere((r) => r.id == reqId);
    req.status = AnimalRequestStatus.rejected;
    req.adminNote = adminNote;
    notifyListeners();
  }

  // 급여
  void feedAnimal(String animalId, double amountG) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    a.lastFeedTime = DateTime.now();
    a.conditionScore = min(100.0, a.conditionScore + 5.0);
    _updateStatus(a);
    notifyListeners();
  }

  void waterAnimal(String animalId, double amountMl) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    a.lastWaterTime = DateTime.now();
    a.conditionScore = min(100.0, a.conditionScore + 3.0);
    _updateStatus(a);
    notifyListeners();
  }

  // 산소 설정
  void setOxygen(String animalId, double pct) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    a.oxygenPercent = pct;
    _updateStatus(a);
    notifyListeners();
  }

  // 케이지/환경 설정
  void setCage(String animalId, String cageId) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    a.cageId = cageId;
    notifyListeners();
  }

  void toggleEnrichment(String animalId, String enrichId) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    if (a.enrichmentIds.contains(enrichId)) {
      a.enrichmentIds.remove(enrichId);
    } else {
      a.enrichmentIds.add(enrichId);
    }
    notifyListeners();
  }

  // 유전자 주입
  void injectGene(String animalId, String geneId, String method) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    a.injectedGeneId = geneId;
    a.geneInjectionDate = DateTime.now();
    a.geneInjectionMethod = method;
    notifyListeners();
  }

  // 부검
  void performNecropsy(String animalId, List<String> organs, String disposal) {
    final a = _animals.firstWhere((x) => x.id == animalId);
    a.necropsyDone = true;
    a.necropsyOrgans = organs;
    a.necropsyDisposal = disposal;
    a.necropsyDate = DateTime.now();
    if (a.status != AnimalStatus.dead) {
      a.status = AnimalStatus.dead;
      a.deathCause = AnimalDeathCause.euthanized;
      a.deathDate = DateTime.now();
    }
    notifyListeners();
  }

  // 컨디션 계산 (실시간 - 매 호출 시 업데이트)
  void updateAllConditions() {
    final now = DateTime.now();
    bool changed = false;
    for (final a in _animals) {
      if (a.status == AnimalStatus.dead) continue;
      final species = AnimalDatabase.findById(a.speciesId);
      if (species == null) continue;

      // ① 물 부족 체크
      if (a.lastWaterTime != null && species.id != 'zebrafish') {
        final waterDays = now.difference(a.lastWaterTime!).inSeconds / 86400.0;
        if (waterDays > species.waterStarveDays) {
          a.status = AnimalStatus.dead;
          a.deathCause = AnimalDeathCause.dehydration;
          a.deathDate = now;
          changed = true;
          continue;
        } else if (waterDays > species.waterStarveDays * 0.6) {
          a.conditionScore = max(0, a.conditionScore - 1.5);
          changed = true;
        }
      }

      // ② 먹이 부족 체크
      if (a.lastFeedTime != null) {
        final feedDays = now.difference(a.lastFeedTime!).inSeconds / 86400.0;
        if (feedDays > species.feedStarveDays) {
          a.status = AnimalStatus.dead;
          a.deathCause = AnimalDeathCause.starvation;
          a.deathDate = now;
          changed = true;
          continue;
        } else if (feedDays > 1.0) {
          final weightLoss = (feedDays - 1.0) * species.avgWeightG * 0.02;
          a.weightG = max(species.avgWeightG * 0.5, a.weightG - weightLoss);
          a.conditionScore = max(0, a.conditionScore - 0.8);
          changed = true;
        }
      }

      // ③ 산소 체크
      if (a.oxygenPercent < species.oxygenDeathMin || a.oxygenPercent > species.oxygenDeathMax) {
        a.conditionScore = max(0, a.conditionScore - 5.0);
        if (a.conditionScore <= 0) {
          a.status = AnimalStatus.dead;
          a.deathCause = a.oxygenPercent < species.oxygenDeathMin
              ? AnimalDeathCause.oxygenLow
              : AnimalDeathCause.oxygenHigh;
          a.deathDate = now;
          changed = true;
          continue;
        }
      } else if (a.oxygenPercent < species.stdOxygenMin || a.oxygenPercent > species.stdOxygenMax) {
        a.conditionScore = max(0, a.conditionScore - 0.5);
        changed = true;
      }

      // ④ 노화
      final ageRatio = a.ageInDays / species.lifespanDays;
      if (ageRatio > 0.85) {
        a.conditionScore = max(0, a.conditionScore - 0.1);
        changed = true;
      }
      if (ageRatio >= 1.0) {
        a.status = AnimalStatus.dead;
        a.deathCause = AnimalDeathCause.naturalDeath;
        a.deathDate = now;
        changed = true;
        continue;
      }

      // ⑤ 상태 갱신
      _updateStatus(a);
    }
    if (changed) notifyListeners();
  }

  void _updateStatus(AnimalInstance a) {
    if (a.status == AnimalStatus.dead) return;
    if (a.conditionScore >= 80) a.status = AnimalStatus.healthy;
    else if (a.conditionScore >= 60) a.status = AnimalStatus.stressed;
    else if (a.conditionScore >= 30) a.status = AnimalStatus.sick;
    else a.status = AnimalStatus.critical;
  }
}
