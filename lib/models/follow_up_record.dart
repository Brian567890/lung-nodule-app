/// 随访记录模型
class FollowUpRecord {
  final String id;
  final String noduleId;            // 关联结节ID
  final String patientId;           // 关联患者ID（冗余，方便查询）
  
  final DateTime checkDate;         // 检查日期
  final String checkMethod;         // 检查方法：CT低剂量/常规CT/薄层CT等
  final String? hospitalName;       // 检查医院
  final String? doctorName;         // 检查医生
  
  // 结节变化数据
  final double diameter;            // 当前直径 mm
  final double? previousDiameter;   // 上次直径 mm
  final double? diameterChange;     // 直径变化 mm
  final double? volumeChangePercent;// 体积变化百分比
  
  // 密度变化
  final String? densityChange;      // 密度变化描述
  final bool hasNewSolidComponent;  // 是否新增实性成分
  final bool hasSolidComponentIncrease; // 实性成分是否增加
  final double? newSolidComponentSize; // 新增实性成分大小
  
  // 形态变化
  final bool hasEnlargement;        // 是否增大
  final bool hasMorphologyChange;   // 形态是否变化
  final String? morphologyChangeDesc; // 形态变化描述
  
  // 倍增时间
  final double? volumeDoublingTime; // 体积倍增时间（天）
  
  // 判断结果
  final bool isStable;              // 是否稳定
  final bool isSuspicious;          // 是否可疑
  final String? assessment;         // 评估结论
  
  // 建议
  final String? doctorAdvice;       // 医生建议
  final DateTime? nextFollowUpDate; // 建议的下次随访日期
  final String? nextFollowUpPlan;   // 下次随访方案
  
  // 对比图像
  final String? imagePath;          // 本地图像路径
  final String? dicomUid;           // DICOM UID（如有）
  
  final String? notes;              // 备注
  final DateTime createdAt;

  FollowUpRecord({
    required this.id,
    required this.noduleId,
    required this.patientId,
    required this.checkDate,
    required this.checkMethod,
    this.hospitalName,
    this.doctorName,
    required this.diameter,
    this.previousDiameter,
    this.diameterChange,
    this.volumeChangePercent,
    this.densityChange,
    this.hasNewSolidComponent = false,
    this.hasSolidComponentIncrease = false,
    this.newSolidComponentSize,
    this.hasEnlargement = false,
    this.hasMorphologyChange = false,
    this.morphologyChangeDesc,
    this.volumeDoublingTime,
    this.isStable = true,
    this.isSuspicious = false,
    this.assessment,
    this.doctorAdvice,
    this.nextFollowUpDate,
    this.nextFollowUpPlan,
    this.imagePath,
    this.dicomUid,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'noduleId': noduleId,
      'patientId': patientId,
      'checkDate': checkDate.toIso8601String(),
      'checkMethod': checkMethod,
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'diameter': diameter,
      'previousDiameter': previousDiameter,
      'diameterChange': diameterChange,
      'volumeChangePercent': volumeChangePercent,
      'densityChange': densityChange,
      'hasNewSolidComponent': hasNewSolidComponent ? 1 : 0,
      'hasSolidComponentIncrease': hasSolidComponentIncrease ? 1 : 0,
      'newSolidComponentSize': newSolidComponentSize,
      'hasEnlargement': hasEnlargement ? 1 : 0,
      'hasMorphologyChange': hasMorphologyChange ? 1 : 0,
      'morphologyChangeDesc': morphologyChangeDesc,
      'volumeDoublingTime': volumeDoublingTime,
      'isStable': isStable ? 1 : 0,
      'isSuspicious': isSuspicious ? 1 : 0,
      'assessment': assessment,
      'doctorAdvice': doctorAdvice,
      'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
      'nextFollowUpPlan': nextFollowUpPlan,
      'imagePath': imagePath,
      'dicomUid': dicomUid,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FollowUpRecord.fromMap(Map<String, dynamic> map) {
    return FollowUpRecord(
      id: map['id'],
      noduleId: map['noduleId'],
      patientId: map['patientId'],
      checkDate: DateTime.parse(map['checkDate']),
      checkMethod: map['checkMethod'],
      hospitalName: map['hospitalName'],
      doctorName: map['doctorName'],
      diameter: map['diameter'],
      previousDiameter: map['previousDiameter'],
      diameterChange: map['diameterChange'],
      volumeChangePercent: map['volumeChangePercent'],
      densityChange: map['densityChange'],
      hasNewSolidComponent: map['hasNewSolidComponent'] == 1,
      hasSolidComponentIncrease: map['hasSolidComponentIncrease'] == 1,
      newSolidComponentSize: map['newSolidComponentSize'],
      hasEnlargement: map['hasEnlargement'] == 1,
      hasMorphologyChange: map['hasMorphologyChange'] == 1,
      morphologyChangeDesc: map['morphologyChangeDesc'],
      volumeDoublingTime: map['volumeDoublingTime'],
      isStable: map['isStable'] == 1,
      isSuspicious: map['isSuspicious'] == 1,
      assessment: map['assessment'],
      doctorAdvice: map['doctorAdvice'],
      nextFollowUpDate: map['nextFollowUpDate'] != null 
          ? DateTime.parse(map['nextFollowUpDate']) 
          : null,
      nextFollowUpPlan: map['nextFollowUpPlan'],
      imagePath: map['imagePath'],
      dicomUid: map['dicomUid'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // 计算直径变化率
  double? get diameterChangePercent {
    if (previousDiameter == null || previousDiameter == 0) return null;
    return ((diameter - previousDiameter!) / previousDiameter!) * 100;
  }

  // 判断是否为恶性征象（2024共识）
  bool get hasMalignantSigns {
    return hasEnlargement ||
           hasNewSolidComponent ||
           hasSolidComponentIncrease ||
           isSuspicious;
  }
}