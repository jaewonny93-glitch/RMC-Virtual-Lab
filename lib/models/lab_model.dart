import 'package:flutter/foundation.dart';

class CultureDishType {
  final String id;
  final String name;
  final int wellCount;
  final double wellVolumeMl;       // 최대 용량 (mL)
  final double standardVolumeMl;   // 표준 배양액 권장 용량 (mL)
  final double minVolumeMl;        // 최소 권장 용량 (mL)
  final String description;
  final String surfaceAreaCm2;     // 성장 면적

  const CultureDishType({
    required this.id,
    required this.name,
    required this.wellCount,
    required this.wellVolumeMl,
    required this.standardVolumeMl,
    required this.minVolumeMl,
    required this.description,
    required this.surfaceAreaCm2,
  });

  /// 최대 용량 μL 반환
  double get maxVolumeUL => wellVolumeMl * 1000;
  /// 표준 용량 μL 반환
  double get standardVolumeUL => standardVolumeMl * 1000;
}

class DishDatabase {
  static const List<CultureDishType> dishes = [
    // ── Flask ──────────────────────────────────────
    CultureDishType(
      id: 'flask_t25',
      name: 'T-25 Flask',
      wellCount: 1,
      wellVolumeMl: 8.0,
      standardVolumeMl: 5.0,
      minVolumeMl: 3.0,
      surfaceAreaCm2: '25 cm²',
      description: 'T-25 배양 플라스크. 표준 5mL, 최대 8mL.',
    ),
    CultureDishType(
      id: 'flask_t75',
      name: 'T-75 Flask',
      wellCount: 1,
      wellVolumeMl: 20.0,
      standardVolumeMl: 15.0,
      minVolumeMl: 8.0,
      surfaceAreaCm2: '75 cm²',
      description: 'T-75 배양 플라스크. 표준 15mL, 최대 20mL.',
    ),
    CultureDishType(
      id: 'flask_t175',
      name: 'T-175 Flask',
      wellCount: 1,
      wellVolumeMl: 50.0,
      standardVolumeMl: 40.0,
      minVolumeMl: 20.0,
      surfaceAreaCm2: '175 cm²',
      description: 'T-175 배양 플라스크. 표준 40mL, 최대 50mL.',
    ),
    CultureDishType(
      id: 'flask_t225',
      name: 'T-225 Flask',
      wellCount: 1,
      wellVolumeMl: 70.0,
      standardVolumeMl: 50.0,
      minVolumeMl: 25.0,
      surfaceAreaCm2: '225 cm²',
      description: 'T-225 대용량 배양 플라스크. 표준 50mL, 최대 70mL.',
    ),
    // ── Culture Dish ───────────────────────────────
    CultureDishType(
      id: 'dish_35',
      name: '35mm Culture Dish',
      wellCount: 1,
      wellVolumeMl: 3.0,
      standardVolumeMl: 2.0,
      minVolumeMl: 1.0,
      surfaceAreaCm2: '9.6 cm²',
      description: '직경 35mm 배양 접시. 표준 2mL, 최대 3mL.',
    ),
    CultureDishType(
      id: 'dish_60',
      name: '60mm Culture Dish',
      wellCount: 1,
      wellVolumeMl: 8.0,
      standardVolumeMl: 5.0,
      minVolumeMl: 2.0,
      surfaceAreaCm2: '21 cm²',
      description: '직경 60mm 배양 접시. 표준 5mL, 최대 8mL.',
    ),
    CultureDishType(
      id: 'dish_100',
      name: '100mm Culture Dish',
      wellCount: 1,
      wellVolumeMl: 15.0,
      standardVolumeMl: 10.0,
      minVolumeMl: 5.0,
      surfaceAreaCm2: '57 cm²',
      description: '직경 100mm 표준 배양 접시. 표준 10mL, 최대 15mL.',
    ),
    CultureDishType(
      id: 'dish_150',
      name: '150mm Culture Dish',
      wellCount: 1,
      wellVolumeMl: 30.0,
      standardVolumeMl: 20.0,
      minVolumeMl: 10.0,
      surfaceAreaCm2: '145 cm²',
      description: '직경 150mm 대형 배양 접시. 표준 20mL, 최대 30mL.',
    ),
    // ── Well Plate ─────────────────────────────────
    CultureDishType(
      id: 'plate_6well',
      name: '6-Well Plate',
      wellCount: 6,
      wellVolumeMl: 4.0,
      standardVolumeMl: 2.0,
      minVolumeMl: 1.0,
      surfaceAreaCm2: '9.6 cm²/well',
      description: '6웰 플레이트. 웰당 표준 2mL, 최대 4mL.',
    ),
    CultureDishType(
      id: 'plate_12well',
      name: '12-Well Plate',
      wellCount: 12,
      wellVolumeMl: 2.0,
      standardVolumeMl: 1.0,
      minVolumeMl: 0.5,
      surfaceAreaCm2: '3.8 cm²/well',
      description: '12웰 플레이트. 웰당 표준 1mL, 최대 2mL.',
    ),
    CultureDishType(
      id: 'plate_24well',
      name: '24-Well Plate',
      wellCount: 24,
      wellVolumeMl: 1.0,
      standardVolumeMl: 0.5,
      minVolumeMl: 0.2,
      surfaceAreaCm2: '1.9 cm²/well',
      description: '24웰 플레이트. 웰당 표준 500μL, 최대 1mL.',
    ),
    CultureDishType(
      id: 'plate_48well',
      name: '48-Well Plate',
      wellCount: 48,
      wellVolumeMl: 0.5,
      standardVolumeMl: 0.25,
      minVolumeMl: 0.1,
      surfaceAreaCm2: '0.95 cm²/well',
      description: '48웰 플레이트. 웰당 표준 250μL, 최대 500μL.',
    ),
    CultureDishType(
      id: 'plate_96well',
      name: '96-Well Plate',
      wellCount: 96,
      wellVolumeMl: 0.3,
      standardVolumeMl: 0.1,
      minVolumeMl: 0.05,
      surfaceAreaCm2: '0.32 cm²/well',
      description: '96웰 플레이트. 웰당 표준 100μL, 최대 300μL.',
    ),
    CultureDishType(
      id: 'plate_384well',
      name: '384-Well Plate',
      wellCount: 384,
      wellVolumeMl: 0.08,
      standardVolumeMl: 0.04,
      minVolumeMl: 0.01,
      surfaceAreaCm2: '0.056 cm²/well',
      description: '384웰 플레이트. 웰당 표준 40μL, 최대 80μL.',
    ),
  ];

  static CultureDishType? findById(String id) {
    try {
      return dishes.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}

class PipetteType {
  final String id;
  final String name;
  final double maxVolume;
  final String color;
  final bool isMulti;

  const PipetteType({
    required this.id,
    required this.name,
    required this.maxVolume,
    required this.color,
    this.isMulti = false,
  });
}

class PipetteDatabase {
  static const List<PipetteType> pipettes = [
    PipetteType(
      id: 'p1000',
      name: 'P1000',
      maxVolume: 1000,
      color: '#2196F3',
    ),
    PipetteType(
      id: 'p200',
      name: 'P200',
      maxVolume: 200,
      color: '#FFC107',
    ),
    PipetteType(
      id: 'p100',
      name: 'P100',
      maxVolume: 100,
      color: '#FFC107',
    ),
    PipetteType(
      id: 'p10',
      name: 'P10',
      maxVolume: 10,
      color: '#212121',
    ),
    PipetteType(
      id: 'multi_p300',
      name: 'Multi-P300',
      maxVolume: 300,
      color: '#FFC107',
      isMulti: true,
    ),
  ];
}

class WellData {
  final int wellIndex;
  double mediumVolume;
  double cellVolume;
  double cellCount;
  bool hasCell;
  bool hasMedium;
  String? mediumName;
  DateTime? seedingTime;
  bool isSelected;

  WellData({
    required this.wellIndex,
    this.mediumVolume = 0,
    this.cellVolume = 0,
    this.cellCount = 0,
    this.hasCell = false,
    this.hasMedium = false,
    this.mediumName,
    this.seedingTime,
    this.isSelected = false,
  });

  double get totalVolume => mediumVolume + cellVolume;
}

class ExperimentSession extends ChangeNotifier {
  String? cellTypeId;
  String? dishTypeId;
  String? pipetteId;
  String? selectedMedium;
  List<WellData> wells = [];
  double vialRemainingUL = 1000.0;
  double vialInitialCells = 1000000.0;
  int? selectedWellIndex;
  bool isInIncubator = false;
  DateTime? incubatorStartTime;
  bool isMediumCorrect = false;

  void reset() {
    cellTypeId = null;
    dishTypeId = null;
    pipetteId = null;
    selectedMedium = null;
    wells = [];
    vialRemainingUL = 1000.0;
    vialInitialCells = 1000000.0;
    selectedWellIndex = null;
    isInIncubator = false;
    incubatorStartTime = null;
    isMediumCorrect = false;
    notifyListeners();
  }

  void initWells(int count) {
    wells = List.generate(count, (i) => WellData(wellIndex: i));
    notifyListeners();
  }

  void dispenseMediumToWell(int wellIndex, double volumeUL) {
    if (wellIndex < wells.length) {
      wells[wellIndex].mediumVolume += volumeUL;
      wells[wellIndex].hasMedium = true;
      wells[wellIndex].mediumName = selectedMedium;
      notifyListeners();
    }
  }

  bool dispenseCellsToWell(int wellIndex, double volumeUL) {
    if (volumeUL > vialRemainingUL) return false;
    if (wellIndex < wells.length) {
      final cellsPerUL = vialInitialCells / 1000.0;
      wells[wellIndex].cellVolume += volumeUL;
      wells[wellIndex].cellCount += cellsPerUL * volumeUL;
      wells[wellIndex].hasCell = true;
      wells[wellIndex].seedingTime = DateTime.now();
      vialRemainingUL -= volumeUL;
      notifyListeners();
      return true;
    }
    return false;
  }

  double get cellsPerUL => vialInitialCells / 1000.0;

  void startIncubation() {
    isInIncubator = true;
    incubatorStartTime = DateTime.now();
    notifyListeners();
  }
}
