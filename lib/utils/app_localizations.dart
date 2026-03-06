import 'package:flutter/material.dart';

/// 应用本地化类
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) 
        ?? AppLocalizations(const Locale('zh', 'CN'));
  }
  
  bool get isZh => locale.languageCode == 'zh';
  
  // ==================== 通用 ====================
  String get appTitle => isZh ? '肺结节随访' : 'Lung Nodule Follow-up';
  String get save => isZh ? '保存' : 'Save';
  String get cancel => isZh ? '取消' : 'Cancel';
  String get delete => isZh ? '删除' : 'Delete';
  String get edit => isZh ? '编辑' : 'Edit';
  String get confirm => isZh ? '确认' : 'Confirm';
  String get search => isZh ? '搜索' : 'Search';
  String get loading => isZh ? '加载中...' : 'Loading...';
  String get error => isZh ? '错误' : 'Error';
  String get success => isZh ? '成功' : 'Success';
  
  // ==================== 首页 ====================
  String get quickActions => isZh ? '快速操作' : 'Quick Actions';
  String get upcomingFollowUps => isZh ? '待随访提醒' : 'Upcoming Follow-ups';
  String get totalPatients => isZh ? '患者总数' : 'Total Patients';
  String get totalNodules => isZh ? '结节总数' : 'Total Nodules';
  String get activeNodules => isZh ? '随访中结节' : 'Active Nodules';
  String get overdueFollowUps => isZh ? '逾期随访' : 'Overdue';
  String get noUpcomingFollowUps => isZh ? '暂无待随访患者' : 'No upcoming follow-ups';
  String get nodule => isZh ? '结节' : 'Nodule';
  String daysOverdue(int days) => isZh ? '逾期$days天' : '$days days overdue';
  String daysUntil(int days) => isZh ? '还有$days天' : '$days days until';
  
  // ==================== 患者 ====================
  String get addPatient => isZh ? '添加患者' : 'Add Patient';
  String get patientList => isZh ? '患者列表' : 'Patient List';
  String get patientInfo => isZh ? '患者信息' : 'Patient Information';
  String get patientName => isZh ? '患者姓名' : 'Patient Name';
  String get age => isZh ? '年龄' : 'Age';
  String get gender => isZh ? '性别' : 'Gender';
  String get male => isZh ? '男' : 'Male';
  String get female => isZh ? '女' : 'Female';
  String get phoneNumber => isZh ? '手机号' : 'Phone Number';
  String get idCard => isZh ? '身份证号' : 'ID Card';
  String get patientId => isZh ? '患者编号' : 'Patient ID';
  String get createdAt => isZh ? '建档日期' : 'Created At';
  
  // ==================== 危险因素 ====================
  String get riskFactors => isZh ? '危险因素' : 'Risk Factors';
  String get smoking => isZh ? '吸烟史' : 'Smoking History';
  String get packYears => isZh ? '包年数' : 'Pack-Years';
  String get cancerHistory => isZh ? '肿瘤史(>5年)' : 'Cancer History (>5y)';
  String get familyHistory => isZh ? '肺癌家族史' : 'Family History';
  String get copd => isZh ? '慢阻肺' : 'COPD';
  String get tuberculosis => isZh ? '肺结核史' : 'Tuberculosis';
  String get pulmonaryFibrosis => isZh ? '肺纤维化' : 'Pulmonary Fibrosis';
  String get highRiskExposure => isZh ? '高危职业暴露' : 'High-Risk Exposure';
  String get occupation => isZh ? '职业' : 'Occupation';
  String get isHighRiskGroup => isZh ? '肺癌高危人群' : 'High-Risk Group';
  
  // ==================== 结节 ====================
  String get addNodule => isZh ? '添加结节' : 'Add Nodule';
  String get noduleInfo => isZh ? '结节信息' : 'Nodule Information';
  String get noduleId => isZh ? '结节编号' : 'Nodule ID';
  String get discoveryDate => isZh ? '发现日期' : 'Discovery Date';
  String get diameter => isZh ? '直径(mm)' : 'Diameter (mm)';
  String get density => isZh ? '密度类型' : 'Density';
  String get solid => isZh ? '实性' : 'Solid';
  String get pGGN => isZh ? '纯磨玻璃' : 'Pure GGN';
  String get mGGN => isZh ? '混杂性' : 'Mixed GGN';
  String get solidComponentRatio => isZh ? '实性成分占比' : 'Solid Component %';
  String get solidComponentSize => isZh ? '实性成分大小(mm)' : 'Solid Size (mm)';
  String get location => isZh ? '位置' : 'Location';
  String get lobe => isZh ? '肺叶' : 'Lobe';
  String get segment => isZh ? '肺段' : 'Segment';
  String get rightUpper => isZh ? '右上叶' : 'Right Upper';
  String get rightMiddle => isZh ? '右中叶' : 'Right Middle';
  String get rightLower => isZh ? '右下叶' : 'Right Lower';
  String get leftUpper => isZh ? '左上叶' : 'Left Upper';
  String get leftLower => isZh ? '左下叶' : 'Left Lower';
  
  // ==================== 影像特征 ====================
  String get imagingFeatures => isZh ? '影像特征' : 'Imaging Features';
  String get spiculation => isZh ? '毛刺征' : 'Spiculation';
  String get lobulation => isZh ? '分叶征' : 'Lobulation';
  String get pleuralIndentation => isZh ? '胸膜凹陷征' : 'Pleural Indentation';
  String get vascularConvergence => isZh ? '血管集束征' : 'Vascular Convergence';
  String get bubbleSign => isZh ? '空泡征' : 'Bubble Sign';
  String get cavity => isZh ? '空洞' : 'Cavity';
  String get ctValue => isZh ? 'CT值(HU)' : 'CT Value (HU)';
  String get ctValueMin => isZh ? 'CT值最小' : 'CT Min';
  String get ctValueMax => isZh ? 'CT值最大' : 'CT Max';
  String get ctValueMean => isZh ? 'CT值平均' : 'CT Mean';
  
  // ==================== 恶性概率 ====================
  String get malignancyProbability => isZh ? '恶性概率' : 'Malignancy Probability';
  String get calculateProbability => isZh ? '计算概率' : 'Calculate Probability';
  String get riskLevel => isZh ? '风险等级' : 'Risk Level';
  String get lowRisk => isZh ? '低风险' : 'Low Risk';
  String get moderateRisk => isZh ? '中风险' : 'Moderate Risk';
  String get highRisk => isZh ? '高风险' : 'High Risk';
  String get mayoModel => isZh ? '梅奥模型' : 'Mayo Model';
  String get recommendation => isZh ? '处理建议' : 'Recommendation';
  
  // ==================== 随访 ====================
  String get followUpPlan => isZh ? '随访方案' : 'Follow-up Plan';
  String get nextFollowUp => isZh ? '下次随访' : 'Next Follow-up';
  String get followUpInterval => isZh ? '随访间隔' : 'Follow-up Interval';
  String get addFollowUpRecord => isZh ? '添加随访记录' : 'Add Follow-up Record';
  String get followUpHistory => isZh ? '随访历史' : 'Follow-up History';
  String get checkDate => isZh ? '检查日期' : 'Check Date';
  String get checkMethod => isZh ? '检查方法' : 'Check Method';
  String get noduleChanges => isZh ? '结节变化' : 'Nodule Changes';
  String get hasEnlargement => isZh ? '结节增大' : 'Enlargement';
  String get hasNewSolid => isZh ? '新增实性成分' : 'New Solid Component';
  String get solidIncreased => isZh ? '实性成分增加' : 'Solid Increased';
  String get isStable => isZh ? '结节稳定' : 'Stable';
  String get isSuspicious => isZh ? '可疑恶性征象' : 'Suspicious';
  String get doctorAdvice => isZh ? '医生建议' : 'Doctor Advice';
  String get notes => isZh ? '备注' : 'Notes';
  String get followUpCalendar => isZh ? '随访日历' : 'Follow-up Calendar';
  String months(int m) => isZh ? '$m个月' : '$m months';
  
  // ==================== 设置 ====================
  String get settings => isZh ? '设置' : 'Settings';
  String get language => isZh ? '语言' : 'Language';
  String get theme => isZh ? '主题' : 'Theme';
  String get lightTheme => isZh ? '浅色' : 'Light';
  String get darkTheme => isZh ? '深色' : 'Dark';
  String get systemDefault => isZh ? '跟随系统' : 'System Default';
  String get about => isZh ? '关于' : 'About';
  String get version => isZh ? '版本' : 'Version';
  String get dataManagement => isZh ? '数据管理' : 'Data Management';
  String get exportData => isZh ? '导出数据' : 'Export Data';
  String get importData => isZh ? '导入数据' : 'Import Data';
  String get clearAllData => isZh ? '清空所有数据' : 'Clear All Data';
  
  // ==================== 提示信息 ====================
  String get confirmDelete => isZh ? '确认删除？' : 'Confirm Delete?';
  String get confirmClearData => isZh ? '确认清空所有数据？此操作不可恢复！' : 'Clear all data? This cannot be undone!';
  String get saveSuccess => isZh ? '保存成功' : 'Saved successfully';
  String get deleteSuccess => isZh ? '删除成功' : 'Deleted successfully';
  String get pleaseEnterName => isZh ? '请输入姓名' : 'Please enter name';
  String get pleaseEnterAge => isZh ? '请输入年龄' : 'Please enter age';
  String get pleaseEnterDiameter => isZh ? '请输入直径' : 'Please enter diameter';
  String get invalidInput => isZh ? '输入无效' : 'Invalid input';
}