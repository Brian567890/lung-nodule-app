/// 肺结节密度类型
enum NoduleDensity {
  solid,        // 实性结节
  pGGN,         // 纯磨玻璃结节
  mGGN,         // 混杂性结节（部分实性）
}

extension NoduleDensityExtension on NoduleDensity {
  String get displayName {
    switch (this) {
      case NoduleDensity.solid:
        return '实性结节';
      case NoduleDensity.pGGN:
        return '纯磨玻璃结节';
      case NoduleDensity.mGGN:
        return '混杂性结节';
    }
  }

  String get englishName {
    switch (this) {
      case NoduleDensity.solid:
        return 'Solid Nodule';
      case NoduleDensity.pGGN:
        return 'Pure Ground-Glass Nodule';
      case NoduleDensity.mGGN:
        return 'Mixed Ground-Glass Nodule';
    }
  }
}

/// 肺叶位置
enum LungLobe {
  rightUpper,   // 右上叶
  rightMiddle,  // 右中叶
  rightLower,   // 右下叶
  leftUpper,    // 左上叶
  leftLower,    // 左下叶
}

extension LungLobeExtension on LungLobe {
  String get displayName {
    switch (this) {
      case LungLobe.rightUpper:
        return '右上叶';
      case LungLobe.rightMiddle:
        return '右中叶';
      case LungLobe.rightLower:
        return '右下叶';
      case LungLobe.leftUpper:
        return '左上叶';
      case LungLobe.leftLower:
        return '左下叶';
    }
  }

  bool get isUpperLobe {
    return this == LungLobe.rightUpper || this == LungLobe.leftUpper;
  }
}

/// 肺结节模型
class LungNodule {
  final String id;
  final String patientId;           // 关联患者ID
  
  // 发现信息
  final DateTime discoveryDate;     // 发现日期
  final String? discoveryMethod;    // 发现途径：筛查/症状/体检等
  
  // 基本参数
  final double diameter;            // 直径 mm（梅奥模型关键参数）
  final NoduleDensity density;      // 密度类型
  final double? solidComponentRatio; // 实性成分占比（0-1，mGGN用）
  final double? solidComponentSize;  // 实性成分大小 mm
  
  // 位置
  final LungLobe lobe;              // 肺叶
  final String? segment;            // 肺段（可选）
  final String? specificLocation;   // 具体位置描述
  
  // 影像特征（梅奥模型相关）
  final bool hasSpiculation;        // 毛刺征
  final bool hasLobulation;         // 分叶征
  final bool hasPleuralIndentation; // 胸膜凹陷征
  final bool hasVascularConvergence;// 血管集束征
  final bool hasBubbleSign;         // 空泡征
  final bool hasCavity;             // 空洞
  
  // CT值
  final double? ctValueMin;         // CT值最小
  final double? ctValueMax;         // CT值最大
  final double? ctValueMean;        // CT值平均
  
  // 计算结果
  final double? malignancyProbability; // 恶性概率（0-100%）
  final String? riskLevel;          // 风险等级：低/中/高
  
  // 随访计划
  final DateTime? nextFollowUpDate; // 下次随访日期
  final String? followUpPlan;       // 随访方案描述
  final int? followUpIntervalMonths;// 随访间隔月数
  
  // 状态
  final bool isActive;              // 是否活跃（未手术/未消失）
  final String? status;             // 当前状态：随访中/已手术/已消失等
  
  final DateTime createdAt;
  final DateTime updatedAt;

  LungNodule({
    required this.id,
    required this.patientId,
    required this.discoveryDate,
    this.discoveryMethod,
    required this.diameter,
    required this.density,
    this.solidComponentRatio,
    this.solidComponentSize,
    required this.lobe,
    this.segment,
    this.specificLocation,
    this.hasSpiculation = false,
    this.hasLobulation = false,
    this.hasPleuralIndentation = false,
    this.hasVascularConvergence = false,
    this.hasBubbleSign = false,
    this.hasCavity = false,
    this.ctValueMin,
    this.ctValueMax,
    this.ctValueMean,
    this.malignancyProbability,
    this.riskLevel,
    this.nextFollowUpDate,
    this.followUpPlan,
    this.followUpIntervalMonths,
    this.isActive = true,
    this.status = '随访中',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'discoveryDate': discoveryDate.toIso8601String(),
      'discoveryMethod': discoveryMethod,
      'diameter': diameter,
      'density': density.index,
      'solidComponentRatio': solidComponentRatio,
      'solidComponentSize': solidComponentSize,
      'lobe': lobe.index,
      'segment': segment,
      'specificLocation': specificLocation,
      'hasSpiculation': hasSpiculation ? 1 : 0,
      'hasLobulation': hasLobulation ? 1 : 0,
      'hasPleuralIndentation': hasPleuralIndentation ? 1 : 0,
      'hasVascularConvergence': hasVascularConvergence ? 1 : 0,
      'hasBubbleSign': hasBubbleSign ? 1 : 0,
      'hasCavity': hasCavity ? 1 : 0,
      'ctValueMin': ctValueMin,
      'ctValueMax': ctValueMax,
      'ctValueMean': ctValueMean,
      'malignancyProbability': malignancyProbability,
      'riskLevel': riskLevel,
      'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
      'followUpPlan': followUpPlan,
      'followUpIntervalMonths': followUpIntervalMonths,
      'isActive': isActive ? 1 : 0,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LungNodule.fromMap(Map<String, dynamic> map) {
    return LungNodule(
      id: map['id'],
      patientId: map['patientId'],
      discoveryDate: DateTime.parse(map['discoveryDate']),
      discoveryMethod: map['discoveryMethod'],
      diameter: map['diameter'],
      density: NoduleDensity.values[map['density']],
      solidComponentRatio: map['solidComponentRatio'],
      solidComponentSize: map['solidComponentSize'],
      lobe: LungLobe.values[map['lobe']],
      segment: map['segment'],
      specificLocation: map['specificLocation'],
      hasSpiculation: map['hasSpiculation'] == 1,
      hasLobulation: map['hasLobulation'] == 1,
      hasPleuralIndentation: map['hasPleuralIndentation'] == 1,
      hasVascularConvergence: map['hasVascularConvergence'] == 1,
      hasBubbleSign: map['hasBubbleSign'] == 1,
      hasCavity: map['hasCavity'] == 1,
      ctValueMin: map['ctValueMin'],
      ctValueMax: map['ctValueMax'],
      ctValueMean: map['ctValueMean'],
      malignancyProbability: map['malignancyProbability'],
      riskLevel: map['riskLevel'],
      nextFollowUpDate: map['nextFollowUpDate'] != null 
          ? DateTime.parse(map['nextFollowUpDate']) 
          : null,
      followUpPlan: map['followUpPlan'],
      followUpIntervalMonths: map['followUpIntervalMonths'],
      isActive: map['isActive'] == 1,
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // 是否为上叶（梅奥模型参数）
  bool get isUpperLobe => lobe.isUpperLobe;

  // 获取实性成分占比显示文本
  String? get solidComponentDisplay {
    if (density != NoduleDensity.mGGN || solidComponentRatio == null) {
      return null;
    }
    return '${(solidComponentRatio! * 100).toStringAsFixed(1)}%';
  }

  LungNodule copyWith({
    double? diameter,
    NoduleDensity? density,
    double? solidComponentRatio,
    double? solidComponentSize,
    LungLobe? lobe,
    String? segment,
    String? specificLocation,
    bool? hasSpiculation,
    bool? hasLobulation,
    bool? hasPleuralIndentation,
    bool? hasVascularConvergence,
    bool? hasBubbleSign,
    bool? hasCavity,
    double? ctValueMin,
    double? ctValueMax,
    double? ctValueMean,
    double? malignancyProbability,
    String? riskLevel,
    DateTime? nextFollowUpDate,
    String? followUpPlan,
    int? followUpIntervalMonths,
    bool? isActive,
    String? status,
    DateTime? updatedAt,
  }) {
    return LungNodule(
      id: id,
      patientId: patientId,
      discoveryDate: discoveryDate,
      discoveryMethod: discoveryMethod,
      diameter: diameter ?? this.diameter,
      density: density ?? this.density,
      solidComponentRatio: solidComponentRatio ?? this.solidComponentRatio,
      solidComponentSize: solidComponentSize ?? this.solidComponentSize,
      lobe: lobe ?? this.lobe,
      segment: segment ?? this.segment,
      specificLocation: specificLocation ?? this.specificLocation,
      hasSpiculation: hasSpiculation ?? this.hasSpiculation,
      hasLobulation: hasLobulation ?? this.hasLobulation,
      hasPleuralIndentation: hasPleuralIndentation ?? this.hasPleuralIndentation,
      hasVascularConvergence: hasVascularConvergence ?? this.hasVascularConvergence,
      hasBubbleSign: hasBubbleSign ?? this.hasBubbleSign,
      hasCavity: hasCavity ?? this.hasCavity,
      ctValueMin: ctValueMin ?? this.ctValueMin,
      ctValueMax: ctValueMax ?? this.ctValueMax,
      ctValueMean: ctValueMean ?? this.ctValueMean,
      malignancyProbability: malignancyProbability ?? this.malignancyProbability,
      riskLevel: riskLevel ?? this.riskLevel,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      followUpPlan: followUpPlan ?? this.followUpPlan,
      followUpIntervalMonths: followUpIntervalMonths ?? this.followUpIntervalMonths,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}