import 'package:flutter/material.dart';
import '../models/cell_model.dart';

// ══════════════════════════════════════════
// 배양액 정보 데이터
// ══════════════════════════════════════════
class MediumInfo {
  final String name;
  final String description;
  final String company;
  final String catalogNumber;
  final String category;
  final String baseComposition;
  final List<String> usedFor;

  const MediumInfo({
    required this.name,
    required this.description,
    required this.company,
    required this.catalogNumber,
    required this.category,
    required this.baseComposition,
    required this.usedFor,
  });
}

class MediumDatabase {
  static const List<MediumInfo> mediums = [
    MediumInfo(
      name: 'DMEM + 10% FBS',
      description: 'Dulbecco\'s Modified Eagle Medium에 10% 소태아혈청을 첨가한 표준 배양액. 가장 광범위하게 사용되는 포유류 세포 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092 / FBS: 16000044',
      category: '기본 배양액',
      baseComposition: 'DMEM + 4.5g/L Glucose + L-Glutamine + 10% FBS',
      usedFor: ['HeLa', 'HEK293', 'MCF-7', 'A375', 'HT-1080', 'PANC-1', 'U-87 MG', 'HaCaT'],
    ),
    MediumInfo(
      name: 'DMEM + 5% FBS',
      description: 'FBS 농도를 5%로 낮춘 DMEM. 혈청 의존성이 낮은 실험 조건에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092 / FBS: 16000044',
      category: '기본 배양액',
      baseComposition: 'DMEM + 4.5g/L Glucose + L-Glutamine + 5% FBS',
      usedFor: ['HeLa', 'LN-229'],
    ),
    MediumInfo(
      name: 'DMEM + 20% FBS',
      description: '고농도 혈청 DMEM. 세포 증식이 느리거나 영양 요구량이 높은 세포에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092 / FBS: 16000044',
      category: '기본 배양액',
      baseComposition: 'DMEM + 4.5g/L Glucose + L-Glutamine + 20% FBS',
      usedFor: ['Caco-2', 'C2C12'],
    ),
    MediumInfo(
      name: 'DMEM/F12 + 10% FBS',
      description: 'DMEM과 Ham\'s F-12를 1:1로 혼합. 광범위한 세포 유형에 적합한 범용 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11320033',
      category: '기본 배양액',
      baseComposition: 'DMEM/F12 (1:1) + 10% FBS',
      usedFor: ['A549', 'HK-2', 'SH-SY5Y'],
    ),
    MediumInfo(
      name: 'DMEM/F12 (1:1) + 10% FBS',
      description: 'DMEM과 F-12의 1:1 혼합 배양액. 신경세포 및 다양한 세포주에 활용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11320033',
      category: '기본 배양액',
      baseComposition: 'DMEM/F12 1:1 혼합 + 10% FBS',
      usedFor: ['SH-SY5Y'],
    ),
    MediumInfo(
      name: 'RPMI-1640 + 10% FBS',
      description: 'Roswell Park Memorial Institute 1640 배양액. 현탁 세포 및 혈액암 세포주에 최적.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11875093',
      category: '기본 배양액',
      baseComposition: 'RPMI-1640 + L-Glutamine + 10% FBS',
      usedFor: ['Jurkat', 'K-562', 'THP-1', 'PC-3', 'MOLT-4', 'U-937', 'Ramos', 'Daudi', 'NCI-H460', 'LNCaP', 'T-47D', 'DU145'],
    ),
    MediumInfo(
      name: 'RPMI-1640 + 20% FBS',
      description: '고농도 혈청 RPMI-1640. 영양 요구량이 높은 혈액암 세포주에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11875093',
      category: '기본 배양액',
      baseComposition: 'RPMI-1640 + 20% FBS',
      usedFor: ['HL-60'],
    ),
    MediumInfo(
      name: 'MEM + 10% FBS',
      description: 'Minimum Essential Medium. 부착성 정상 세포 및 암세포주에 광범위하게 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11090081',
      category: '기본 배양액',
      baseComposition: 'MEM + Earle\'s Salts + L-Glutamine + 10% FBS',
      usedFor: ['HepG2', 'WI-38', 'ACHN', 'Calu-3', 'SK-MEL-28', 'HT-1197'],
    ),
    MediumInfo(
      name: 'Ham\'s F-12 + 10% FBS',
      description: 'Ham\'s F-12 Nutrient Mix. CHO 세포 및 다양한 상피세포 배양에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11765054',
      category: '기본 배양액',
      baseComposition: 'Ham\'s F-12 + L-Glutamine + 10% FBS',
      usedFor: ['CHO', 'CHO-K1', 'AGS', 'FL83B', 'LoVo', 'PC-3'],
    ),
    MediumInfo(
      name: 'McCoy\'s 5A + 10% FBS',
      description: 'McCoy\'s 5A Modified Medium. 대장암 및 골육종 세포주에 적합.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '16600082',
      category: '기본 배양액',
      baseComposition: 'McCoy\'s 5A + L-Glutamine + 10% FBS',
      usedFor: ['HCT116', 'SKOV-3', 'HT-29', 'U-2 OS', 'SK-BR-3', 'RT4'],
    ),
    MediumInfo(
      name: 'McCoy\'s 5A + 15% FBS',
      description: 'McCoy\'s 5A에 고농도 FBS를 첨가. 골육종 세포주 등 영양 요구량이 높은 세포에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '16600082',
      category: '기본 배양액',
      baseComposition: 'McCoy\'s 5A + 15% FBS',
      usedFor: ['Saos-2'],
    ),
    MediumInfo(
      name: 'IMDM + 20% FBS',
      description: 'Iscove\'s Modified Dulbecco\'s Medium. 빠른 성장 세포 및 조혈 세포에 적합.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '12440053',
      category: '기본 배양액',
      baseComposition: 'IMDM + L-Glutamine + 20% FBS',
      usedFor: ['Capan-1', 'HL-60'],
    ),
    MediumInfo(
      name: 'L-15 + 10% FBS',
      description: 'Leibovitz\'s L-15 Medium. CO₂ 비의존성 배양에 사용. 개방계 배양 가능.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11415064',
      category: '기본 배양액',
      baseComposition: 'L-15 + 10% FBS (CO₂ 불필요)',
      usedFor: ['SW480', 'SW1353'],
    ),
    MediumInfo(
      name: 'α-MEM + 10% FBS',
      description: 'Alpha-Modified MEM. 핵산 합성 인자가 첨가된 MEM 변형 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '12571071',
      category: '기본 배양액',
      baseComposition: 'α-MEM + Ribonucleosides + Deoxyribonucleosides + 10% FBS',
      usedFor: ['Hepa1c1c7', 'hMSC-BM', 'hMSC-AT'],
    ),
    MediumInfo(
      name: 'RPMI-1640 + 10% HS + 5% FBS',
      description: 'RPMI에 말혈청(Horse Serum)과 FBS를 혼합. PC12 세포 표준 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'RPMI: 11875093 / HS: 16050122',
      category: '특수 배양액',
      baseComposition: 'RPMI-1640 + 10% Horse Serum + 5% FBS',
      usedFor: ['PC12'],
    ),
    MediumInfo(
      name: 'DMEM + 10% CS',
      description: 'DMEM에 소혈청(Calf Serum) 사용. NIH 3T3 등 마우스 섬유아세포 표준.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092 / CS: 16170078',
      category: '기본 배양액',
      baseComposition: 'DMEM + 10% Calf Serum',
      usedFor: ['NIH 3T3', 'BALB/c 3T3'],
    ),
    MediumInfo(
      name: 'mTeSR1',
      description: '무혈청 줄기세포 유지 배양액. iPSC 및 hESC의 미분화 상태 유지에 최적화.',
      company: 'STEMCELL Technologies',
      catalogNumber: '85850',
      category: '줄기세포 배양액',
      baseComposition: 'Basal Medium + 5x Supplement (bFGF, TGF-β1, LiCl 등)',
      usedFor: ['iPSC', 'hESC'],
    ),
    MediumInfo(
      name: 'Essential 8',
      description: '8가지 필수 성분만 포함한 최소 줄기세포 배양액. 무혈청, 무피더 세포 조건.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'A1517001',
      category: '줄기세포 배양액',
      baseComposition: 'DMEM/F12 + L-ascorbic acid + Selenium + Transferrin + NaHCO₃ + Insulin + FGF2 + TGFβ1',
      usedFor: ['iPSC', 'hESC'],
    ),
    MediumInfo(
      name: 'StemFlex',
      description: '유연한 줄기세포 배양 시스템. 계대배양 빈도를 줄일 수 있는 개선된 줄기세포 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'A3349401',
      category: '줄기세포 배양액',
      baseComposition: 'StemFlex Basal + StemFlex Supplement',
      usedFor: ['iPSC', 'hESC'],
    ),
    MediumInfo(
      name: 'MesenCult-ACF Plus',
      description: '동물성 성분 무첨가(ACF) 중간엽 줄기세포 배양액. GMP 등급 가능.',
      company: 'STEMCELL Technologies',
      catalogNumber: '05448',
      category: '줄기세포 배양액',
      baseComposition: 'ACF Basal Medium + MesenCult-ACF Plus Supplement',
      usedFor: ['hMSC-BM', 'hMSC-AT', 'hMSC-UC'],
    ),
    MediumInfo(
      name: 'NeuroCult NS-A Basal + EGF/bFGF',
      description: '신경줄기세포 뉴로스피어 배양용 기저 배양액. EGF와 bFGF 보충 필요.',
      company: 'STEMCELL Technologies',
      catalogNumber: '05750',
      category: '줄기세포 배양액',
      baseComposition: 'NeuroCult NS-A Basal + Proliferation Supplement + EGF(20ng/mL) + bFGF(10ng/mL)',
      usedFor: ['hNSC'],
    ),
    MediumInfo(
      name: 'RPMI-1640 + B27 (insulin-free)',
      description: 'iPSC 유래 심근세포 성숙화 배양액. 인슐린 제거로 대사 성숙 유도.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'RPMI: 11875093 / B27 minus insulin: A1895601',
      category: '특수 배양액',
      baseComposition: 'RPMI-1640 + B27 Supplement (minus insulin)',
      usedFor: ['hPSC-CM'],
    ),
    MediumInfo(
      name: 'HepatoZYME-SFM',
      description: '무혈청 간세포 배양액. iPSC 유래 간세포의 성숙 및 기능 유지.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '17705021',
      category: '특수 배양액',
      baseComposition: 'HepatoZYME-SFM Basal + L-Glutamine',
      usedFor: ['iPSC-Hep'],
    ),
    MediumInfo(
      name: 'EGM-2 + 2% FBS',
      description: '내피세포 성장 배양액-2. HUVEC 등 내피세포 증식에 최적화.',
      company: 'Lonza',
      catalogNumber: 'CC-3162',
      category: '특수 배양액',
      baseComposition: 'EBM-2 Basal + EGM-2 BulletKit (hEGF, VEGF, hFGF-B, R3-IGF-1, Ascorbic acid, Heparin, 2% FBS)',
      usedFor: ['HUVEC'],
    ),
    MediumInfo(
      name: 'EGM-2 MV + 5% FBS',
      description: '미세혈관 내피세포 특화 배양액. 소혈관 내피세포 배양에 최적.',
      company: 'Lonza',
      catalogNumber: 'CC-3202',
      category: '특수 배양액',
      baseComposition: 'EBM-2 Basal + EGM-2 MV BulletKit + 5% FBS',
      usedFor: ['HMVEC'],
    ),
    MediumInfo(
      name: 'KGM-Gold',
      description: '각질형성세포 성장 배양액. 혈청 무첨가 각질형성세포 전용 배양액.',
      company: 'Lonza',
      catalogNumber: 'CC-3107',
      category: '특수 배양액',
      baseComposition: 'KBM-Gold Basal + KGM-Gold SingleQuots Supplements',
      usedFor: ['NHEK', 'HaCaT'],
    ),
    MediumInfo(
      name: 'BEGM + SingleQuots',
      description: '기관지 상피세포 성장 배양액. 무혈청 기관지 상피세포 전용.',
      company: 'Lonza',
      catalogNumber: 'CC-3170',
      category: '특수 배양액',
      baseComposition: 'BEBM Basal + BEGM SingleQuots (BPE, hEGF, Insulin, Hydrocortisone 등)',
      usedFor: ['NHBE', 'BEAS-2B'],
    ),
    MediumInfo(
      name: 'REBM + SingleQuots',
      description: '신장 상피세포 기저 배양액 + 보충제. 신장 근위세뇨관 상피세포 전용.',
      company: 'Lonza',
      catalogNumber: 'CC-3191',
      category: '특수 배양액',
      baseComposition: 'REBM Basal + REGM SingleQuots',
      usedFor: ['RPTEC'],
    ),
    MediumInfo(
      name: 'Sf-900 III SFM',
      description: '곤충 세포 무혈청 배양액. Sf9 바큘로바이러스 발현 시스템 전용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '12658027',
      category: '특수 배양액',
      baseComposition: 'Sf-900 III SFM (무혈청, 27°C 배양)',
      usedFor: ['Sf9'],
    ),
    MediumInfo(
      name: 'CD CHO (SFM)',
      description: 'CHO 세포 무혈청 화학적 한정 배양액. 대규모 바이오의약품 생산용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '10743011',
      category: '특수 배양액',
      baseComposition: 'CD CHO Basal + 8mM L-Glutamine (무혈청)',
      usedFor: ['CHO'],
    ),
    MediumInfo(
      name: 'DMEM-LG + 10% FBS',
      description: 'Low Glucose DMEM. 저혈당 조건 필요 세포, 특히 줄기세포 배양에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11885084',
      category: '기본 배양액',
      baseComposition: 'DMEM-LG (1g/L Glucose) + 10% FBS',
      usedFor: ['hMSC-BM', 'hMSC-AT'],
    ),
    MediumInfo(
      name: 'William\'s E + GlutaMAX + Hydrocortisone + Insulin',
      description: 'HepaRG 세포 특화 배양액. 간세포 기능 유지를 위한 완전 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: "William's E: 12551032",
      category: '특수 배양액',
      baseComposition: "William's E + GlutaMAX + Hydrocortisone(50μM) + Insulin(5μg/mL)",
      usedFor: ['HepaRG'],
    ),
    MediumInfo(
      name: 'Claycomb Medium + 10% FBS + NE + Insulin',
      description: 'HL-1 심근세포 특화 배양액. 수축 기능 유지를 위한 완전 심근세포 배양액.',
      company: 'Sigma-Aldrich',
      catalogNumber: '51800C',
      category: '특수 배양액',
      baseComposition: 'Claycomb Medium + 10% FBS + 0.1mM Norepinephrine + 10μg/mL Insulin',
      usedFor: ['HL-1'],
    ),
    MediumInfo(
      name: 'DMEM + 15% FBS + β-ME',
      description: 'MIN6 췌장 β세포 특화 배양액. β-Mercaptoethanol 첨가로 산화 스트레스 방지.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092',
      category: '특수 배양액',
      baseComposition: 'DMEM + 15% FBS + 71.5μM β-Mercaptoethanol',
      usedFor: ['MIN6'],
    ),
    MediumInfo(
      name: 'Keratinocyte-SFM + EGF + BPE',
      description: '무혈청 각질형성세포/상피세포 배양액. EGF와 소뇌하수체 추출물 첨가.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '17005042',
      category: '특수 배양액',
      baseComposition: 'Keratinocyte-SFM Basal + rEGF(0.2ng/mL) + BPE(25μg/mL)',
      usedFor: ['HPDE'],
    ),
    MediumInfo(
      name: 'LHC-9 Medium',
      description: '기관지 상피세포 무혈청 배양액. BEAS-2B 세포 표준 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '12678017',
      category: '특수 배양액',
      baseComposition: 'LHC Basal + 9가지 보충인자',
      usedFor: ['BEAS-2B'],
    ),
    MediumInfo(
      name: 'FGM-2',
      description: '섬유아세포 성장 배양액-2. 인간 섬유아세포 증식 최적화.',
      company: 'Lonza',
      catalogNumber: 'CC-3132',
      category: '특수 배양액',
      baseComposition: 'FBM Basal + FGM-2 BulletKit (hFGF-B, Insulin, 2% FBS)',
      usedFor: ['HDFC'],
    ),
    MediumInfo(
      name: 'EpiLife + HKGS',
      description: '표피 각질형성세포 무혈청 배양액. 저칼슘 조건 유지.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'M-EPI-500-CA',
      category: '특수 배양액',
      baseComposition: 'EpiLife + Human Keratinocyte Growth Supplement',
      usedFor: ['NHEK'],
    ),
    MediumInfo(
      name: 'DMEM/F12 + B27 + EGF/bFGF',
      description: '무혈청 신경줄기세포 배양액. B27 보충제와 성장인자로 신경줄기세포 유지.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM/F12: 11320033 / B27: 17504044',
      category: '줄기세포 배양액',
      baseComposition: 'DMEM/F12 + B27 Supplement + EGF(20ng/mL) + bFGF(20ng/mL)',
      usedFor: ['hNSC'],
    ),
    MediumInfo(
      name: 'RPMI-1640 + B27',
      description: 'RPMI에 B27 보충제 첨가. 심근세포 유지 배양용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'RPMI: 11875093 / B27: 17504044',
      category: '특수 배양액',
      baseComposition: 'RPMI-1640 + B27 Supplement',
      usedFor: ['hPSC-CM'],
    ),
    MediumInfo(
      name: "William's E + ITS",
      description: '간세포 배양용 무혈청 배양액. Insulin-Transferrin-Selenium 첨가.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: "William's E: 12551032 / ITS: 41400045",
      category: '특수 배양액',
      baseComposition: "William's E + ITS Supplement",
      usedFor: ['iPSC-Hep'],
    ),
    MediumInfo(
      name: 'Grace\'s Insect Medium + 10% FBS',
      description: '곤충 세포 배양용 기본 배양액. Sf9 대체 배양액.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11595030',
      category: '특수 배양액',
      baseComposition: "Grace's Insect Medium + 10% FBS (27°C, CO₂ 불필요)",
      usedFor: ['Sf9'],
    ),
    MediumInfo(
      name: 'K-SFM + EGF + BPE',
      description: '신장 세포 무혈청 배양액. EGF와 BPE 보충.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '17005042',
      category: '특수 배양액',
      baseComposition: 'K-SFM Basal + EGF + Bovine Pituitary Extract',
      usedFor: ['HK-2'],
    ),
    MediumInfo(
      name: 'DMEM + 10% FBS + Insulin',
      description: 'DMEM에 인슐린을 추가 보충. 특정 암세포주 배양 최적화.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092 / Insulin: 12585014',
      category: '기본 배양액',
      baseComposition: 'DMEM + 10% FBS + 10μg/mL Insulin',
      usedFor: ['Hs578T'],
    ),
    MediumInfo(
      name: 'DMEM + 10% FBS + ITS',
      description: 'DMEM에 Insulin-Transferrin-Selenium 보충. 연골세포 배양 최적화.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: 'DMEM: 11965092 / ITS: 41400045',
      category: '기본 배양액',
      baseComposition: 'DMEM + 10% FBS + ITS Supplement',
      usedFor: ['TC28a2'],
    ),
    MediumInfo(
      name: 'Ham\'s F-12 + 10% FBS',
      description: 'Ham\'s F-12 Nutrient Mixture. CHO 세포 및 상피세포에 사용.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11765054',
      category: '기본 배양액',
      baseComposition: 'Ham\'s F-12 + 10% FBS',
      usedFor: ['CHO', 'CHO-K1', 'PC-3', 'AGS'],
    ),
    MediumInfo(
      name: 'M199 + 20% FBS + EC growth supplement',
      description: '내피세포 배양용 M199 배양액. 내피세포 성장인자 보충.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11150059',
      category: '특수 배양액',
      baseComposition: 'M199 + 20% FBS + ECGS(100μg/mL) + Heparin(100μg/mL)',
      usedFor: ['HUVEC'],
    ),
    MediumInfo(
      name: 'α-MEM + 10% FBS',
      description: 'Alpha MEM 배양액. 골수 유래 줄기세포 및 골세포 배양.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '12571071',
      category: '기본 배양액',
      baseComposition: 'α-MEM + Nucleosides + 10% FBS',
      usedFor: ['hMSC-BM', 'hMSC-AT', 'Hepa1c1c7'],
    ),
    MediumInfo(
      name: 'MEM + 5% FBS',
      description: 'MEM 저혈청 배양액. 바이러스 연구 등 특수 목적.',
      company: 'Thermo Fisher Scientific',
      catalogNumber: '11090081',
      category: '기본 배양액',
      baseComposition: 'MEM + 5% FBS',
      usedFor: ['Vero'],
    ),
  ];

  static List<String> get categories {
    final cats = <String>{};
    for (final m in mediums) {
      cats.add(m.category);
    }
    return cats.toList()..sort();
  }

  static List<MediumInfo> getByName(String name) {
    return mediums.where((m) => m.name == name).toList();
  }
}

// ══════════════════════════════════════════
// Library Screen
// ══════════════════════════════════════════
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _cellSearchQuery = '';
  String _mediumSearchQuery = '';
  String? _selectedCellCategory;
  String? _selectedMediumCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCellTab(),
                _buildMediumTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0D1B2A),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF00E5FF),
        indicatorWeight: 2.5,
        labelColor: const Color(0xFF00E5FF),
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(icon: Icon(Icons.biotech, size: 18), text: '세포주'),
          Tab(icon: Icon(Icons.science, size: 18), text: '배양액'),
        ],
      ),
    );
  }

  // ── 세포주 탭 ──────────────────────────────────
  Widget _buildCellTab() {
    final categories = ['전체', ...CellDatabase.categories];
    List<CellType> filtered = CellDatabase.cells.where((c) {
      final matchCat = _selectedCellCategory == null ||
          _selectedCellCategory == '전체' ||
          c.category == _selectedCellCategory;
      final q = _cellSearchQuery.toLowerCase();
      final matchQ = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.scientificName.toLowerCase().contains(q) ||
          c.description.contains(q);
      return matchCat && matchQ;
    }).toList();

    return Column(
      children: [
        // 검색창
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '세포주 검색...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _cellSearchQuery = v),
          ),
        ),
        // 카테고리 필터
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final sel = (_selectedCellCategory ?? '전체') == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCellCategory = cat),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF00E5FF)
                          : Colors.white12,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: sel ? const Color(0xFF00E5FF) : Colors.white54,
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 결과 수
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                '${filtered.length}종 등록',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        // 세포주 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _CellListTile(cell: filtered[i]),
          ),
        ),
      ],
    );
  }

  // ── 배양액 탭 ──────────────────────────────────
  Widget _buildMediumTab() {
    // 앱에 등록된 배양액 이름 목록
    final registeredNames = CellDatabase.allMediums.toSet();
    // MediumDatabase에서 등록된 것만 필터
    final allMediums = MediumDatabase.mediums
        .where((m) => registeredNames.contains(m.name))
        .toList();

    final categories = ['전체', ...MediumDatabase.categories];
    List<MediumInfo> filtered = allMediums.where((m) {
      final matchCat = _selectedMediumCategory == null ||
          _selectedMediumCategory == '전체' ||
          m.category == _selectedMediumCategory;
      final q = _mediumSearchQuery.toLowerCase();
      final matchQ = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.company.toLowerCase().contains(q) ||
          m.description.contains(q);
      return matchCat && matchQ;
    }).toList();

    return Column(
      children: [
        // 검색창
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '배양액 검색...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _mediumSearchQuery = v),
          ),
        ),
        // 카테고리 필터
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final sel = (_selectedMediumCategory ?? '전체') == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedMediumCategory = cat),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.tealAccent.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? Colors.tealAccent.withValues(alpha: 0.8)
                          : Colors.white12,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: sel ? Colors.tealAccent : Colors.white54,
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // 결과 수
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(
                '${filtered.length}종 등록',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        // 배양액 목록
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _MediumListTile(medium: filtered[i]),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════
// 세포주 리스트 타일
// ══════════════════════════════════════════
class _CellListTile extends StatelessWidget {
  final CellType cell;
  const _CellListTile({required this.cell});

  Color get _categoryColor {
    switch (cell.category) {
      case '줄기세포': return Colors.purpleAccent;
      case '암세포주': return Colors.redAccent;
      case '정상세포주': return Colors.greenAccent;
      case '동물세포주': return Colors.orangeAccent;
      case '면역세포주': return Colors.blueAccent;
      case '신경세포주': return Colors.yellowAccent;
      case '간세포주': return Colors.brown.shade300;
      case '심장/근육세포주': return Colors.pinkAccent;
      case '골/연골세포주': return const Color(0xFFB0BEC5);
      case '신장세포주': return Colors.cyanAccent;
      case '폐세포주': return Colors.lightBlueAccent;
      case '피부세포주': return Colors.amberAccent;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCellDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            // 카테고리 컬러 바
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        cell.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cell.category,
                          style: TextStyle(color: _categoryColor, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cell.scientificName,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cell.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'DT ${cell.doublingTimeHours.toInt()}h',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCellDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CellDetailSheet(cell: cell),
    );
  }
}

// ══════════════════════════════════════════
// 세포주 상세 시트
// ══════════════════════════════════════════
class _CellDetailSheet extends StatelessWidget {
  final CellType cell;
  const _CellDetailSheet({required this.cell});

  Color get _categoryColor {
    switch (cell.category) {
      case '줄기세포': return Colors.purpleAccent;
      case '암세포주': return Colors.redAccent;
      case '정상세포주': return Colors.greenAccent;
      case '동물세포주': return Colors.orangeAccent;
      case '면역세포주': return Colors.blueAccent;
      case '신경세포주': return Colors.yellowAccent;
      case '간세포주': return Colors.brown.shade300;
      case '심장/근육세포주': return Colors.pinkAccent;
      case '골/연골세포주': return const Color(0xFFB0BEC5);
      case '신장세포주': return Colors.cyanAccent;
      case '폐세포주': return Colors.lightBlueAccent;
      case '피부세포주': return Colors.amberAccent;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1B2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 헤더
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _categoryColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.biotech, color: _categoryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cell.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _categoryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cell.category,
                                style: TextStyle(color: _categoryColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cell.scientificName,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 설명
              _DetailSection(
                icon: Icons.info_outline,
                title: '세포 설명',
                color: const Color(0xFF00E5FF),
                child: Text(
                  cell.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                ),
              ),
              const SizedBox(height: 12),
              // 배양 조건
              _DetailSection(
                icon: Icons.thermostat,
                title: '배양 조건',
                color: Colors.orangeAccent,
                child: Column(
                  children: [
                    _InfoRow('온도', '${cell.optimalTemp.toStringAsFixed(1)} °C'),
                    _InfoRow('pH', cell.optimalPH.toStringAsFixed(1)),
                    _InfoRow('CO₂', '${cell.co2Percent.toStringAsFixed(1)} %'),
                    _InfoRow('더블링 타임', '${cell.doublingTimeHours.toStringAsFixed(0)} h'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 권장 배양액
              _DetailSection(
                icon: Icons.science,
                title: '권장 배양액',
                color: Colors.tealAccent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 메인 권장
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.tealAccent, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cell.medium,
                              style: const TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                          const Text('권장',
                              style: TextStyle(color: Colors.tealAccent, fontSize: 10)),
                        ],
                      ),
                    ),
                    if (cell.acceptableMediums.length > 1) ...[
                      const SizedBox(height: 8),
                      const Text('대체 가능 배양액',
                          style: TextStyle(color: Colors.white38, fontSize: 11)),
                      const SizedBox(height: 4),
                      ...cell.acceptableMediums
                          .where((m) => m != cell.medium)
                          .map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check,
                                        color: Colors.white24, size: 14),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(m,
                                          style: const TextStyle(
                                              color: Colors.white54, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════
// 배양액 리스트 타일
// ══════════════════════════════════════════
class _MediumListTile extends StatelessWidget {
  final MediumInfo medium;
  const _MediumListTile({required this.medium});

  Color get _categoryColor {
    switch (medium.category) {
      case '기본 배양액': return const Color(0xFF00E5FF);
      case '줄기세포 배양액': return Colors.purpleAccent;
      case '특수 배양액': return Colors.orangeAccent;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMediumDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medium.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          medium.category,
                          style: TextStyle(color: _categoryColor, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    medium.company,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    medium.description,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }

  void _showMediumDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MediumDetailSheet(medium: medium),
    );
  }
}

// ══════════════════════════════════════════
// 배양액 상세 시트
// ══════════════════════════════════════════
class _MediumDetailSheet extends StatelessWidget {
  final MediumInfo medium;
  const _MediumDetailSheet({required this.medium});

  Color get _categoryColor {
    switch (medium.category) {
      case '기본 배양액': return const Color(0xFF00E5FF);
      case '줄기세포 배양액': return Colors.purpleAccent;
      case '특수 배양액': return Colors.orangeAccent;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D1B2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 헤더
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _categoryColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.local_drink, color: _categoryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medium.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            medium.category,
                            style: TextStyle(
                                color: _categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 설명
              _DetailSection(
                icon: Icons.info_outline,
                title: '배양액 설명',
                color: const Color(0xFF00E5FF),
                child: Text(
                  medium.description,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.6),
                ),
              ),
              const SizedBox(height: 12),
              // 제조사 / 카탈로그
              _DetailSection(
                icon: Icons.business,
                title: '제조사 정보',
                color: Colors.greenAccent,
                child: Column(
                  children: [
                    _InfoRow('제조사', medium.company),
                    _InfoRow('카탈로그 번호', medium.catalogNumber),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 기본 성분
              _DetailSection(
                icon: Icons.science,
                title: '기본 성분 조성',
                color: Colors.tealAccent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    medium.baseComposition,
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 적용 세포주
              if (medium.usedFor.isNotEmpty)
                _DetailSection(
                  icon: Icons.biotech,
                  title: '사용 세포주',
                  color: Colors.amberAccent,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: medium.usedFor.map((name) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                              color: Colors.amberAccent, fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════
// 공통 위젯
// ══════════════════════════════════════════
class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
