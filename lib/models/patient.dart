/// 患者基本信息模型
class Patient {
  final String id;                    // 唯一编号
  final String name;                  // 姓名
  final int age;                      // 年龄
  final bool isMale;                  // 性别
  final String? phoneNumber;          // 手机号
  final String? idCardNumber;         // 身份证号
  
  // 危险因素
  final bool isSmoker;                // 是否吸烟
  final int packYears;                // 包年数
  final bool hasCancerHistory;        // 肿瘤史>5年
  final bool hasFamilyHistory;        // 肺癌家族史
  final bool hasCOPD;                 // 慢阻肺
  final bool hasTuberculosis;         // 肺结核史
  final bool hasPulmonaryFibrosis;    // 弥漫性肺纤维化
  final String? occupation;           // 职业暴露（石棉、铍、铀、氡等）
  final bool hasHighRiskExposure;     // 环境或高危职业暴露史
  
  final DateTime createdAt;           // 建档时间
  final DateTime updatedAt;           // 更新时间

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.isMale,
    this.phoneNumber,
    this.idCardNumber,
    this.isSmoker = false,
    this.packYears = 0,
    this.hasCancerHistory = false,
    this.hasFamilyHistory = false,
    this.hasCOPD = false,
    this.hasTuberculosis = false,
    this.hasPulmonaryFibrosis = false,
    this.occupation,
    this.hasHighRiskExposure = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'isMale': isMale ? 1 : 0,
      'phoneNumber': phoneNumber,
      'idCardNumber': idCardNumber,
      'isSmoker': isSmoker ? 1 : 0,
      'packYears': packYears,
      'hasCancerHistory': hasCancerHistory ? 1 : 0,
      'hasFamilyHistory': hasFamilyHistory ? 1 : 0,
      'hasCOPD': hasCOPD ? 1 : 0,
      'hasTuberculosis': hasTuberculosis ? 1 : 0,
      'hasPulmonaryFibrosis': hasPulmonaryFibrosis ? 1 : 0,
      'occupation': occupation,
      'hasHighRiskExposure': hasHighRiskExposure ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      isMale: map['isMale'] == 1,
      phoneNumber: map['phoneNumber'],
      idCardNumber: map['idCardNumber'],
      isSmoker: map['isSmoker'] == 1,
      packYears: map['packYears'] ?? 0,
      hasCancerHistory: map['hasCancerHistory'] == 1,
      hasFamilyHistory: map['hasFamilyHistory'] == 1,
      hasCOPD: map['hasCOPD'] == 1,
      hasTuberculosis: map['hasTuberculosis'] == 1,
      hasPulmonaryFibrosis: map['hasPulmonaryFibrosis'] == 1,
      occupation: map['occupation'],
      hasHighRiskExposure: map['hasHighRiskExposure'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // 判断是否为肺癌高危人群（2024版共识）
  bool get isHighRiskGroup {
    // 年龄≥40岁 + 任一危险因素
    if (age < 40) return false;
    
    return isSmoker ||
           hasHighRiskExposure ||
           hasCOPD ||
           hasPulmonaryFibrosis ||
           hasTuberculosis ||
           hasCancerHistory ||
           hasFamilyHistory;
  }

  Patient copyWith({
    String? name,
    int? age,
    bool? isMale,
    String? phoneNumber,
    String? idCardNumber,
    bool? isSmoker,
    int? packYears,
    bool? hasCancerHistory,
    bool? hasFamilyHistory,
    bool? hasCOPD,
    bool? hasTuberculosis,
    bool? hasPulmonaryFibrosis,
    String? occupation,
    bool? hasHighRiskExposure,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      isMale: isMale ?? this.isMale,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      isSmoker: isSmoker ?? this.isSmoker,
      packYears: packYears ?? this.packYears,
      hasCancerHistory: hasCancerHistory ?? this.hasCancerHistory,
      hasFamilyHistory: hasFamilyHistory ?? this.hasFamilyHistory,
      hasCOPD: hasCOPD ?? this.hasCOPD,
      hasTuberculosis: hasTuberculosis ?? this.hasTuberculosis,
      hasPulmonaryFibrosis: hasPulmonaryFibrosis ?? this.hasPulmonaryFibrosis,
      occupation: occupation ?? this.occupation,
      hasHighRiskExposure: hasHighRiskExposure ?? this.hasHighRiskExposure,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}