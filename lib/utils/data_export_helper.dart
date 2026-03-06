import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/patient.dart';
import '../models/lung_nodule.dart';
import '../models/follow_up_record.dart';

/// 数据导出工具类
class DataExportHelper {
  
  /// 导出所有数据为JSON
  static Future<String> exportAllData() async {
    final db = DatabaseHelper.instance;
    
    // 获取所有数据
    final patients = await db.getAllPatients();
    final nodules = await db.getAllActiveNodules();
    
    // 构建导出数据结构
    final exportData = {
      'exportTime': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'patients': patients.map((p) {
        final map = p.toMap();
        // 添加该患者的结节
        final patientNodules = nodules.where((n) => n.patientId == p.id).toList();
        map['nodules'] = patientNodules.map((n) => n.toMap()).toList();
        return map;
      }).toList(),
    };
    
    return jsonEncode(exportData);
  }
  
  /// 导出为CSV格式（患者列表）
  static Future<String> exportPatientsCSV() async {
    final patients = await DatabaseHelper.instance.getAllPatients();
    
    final StringBuffer csv = StringBuffer();
    // CSV Header
    csv.writeln('姓名,性别,年龄,手机号,身份证号,吸烟史,包年数,肿瘤史,家族史,慢阻肺,结核史,肺纤维化,高危暴露,职业,建档日期,高危人群');
    
    for (final p in patients) {
      csv.writeln('${p.name},'
          '${p.isMale ? '男' : '女'},'
          '${p.age},'
          '${p.phoneNumber ?? ''},'
          '${p.idCardNumber ?? ''},'
          '${p.isSmoker ? '是' : '否'},'
          '${p.packYears},'
          '${p.hasCancerHistory ? '是' : '否'},'
          '${p.hasFamilyHistory ? '是' : '否'},'
          '${p.hasCOPD ? '是' : '否'},'
          '${p.hasTuberculosis ? '是' : '否'},'
          '${p.hasPulmonaryFibrosis ? '是' : '否'},'
          '${p.hasHighRiskExposure ? '是' : '否'},'
          '${p.occupation ?? ''},'
          '${_formatDate(p.createdAt)},'
          '${p.isHighRiskGroup ? '是' : '否'}');
    }
    
    return csv.toString();
  }
  
  /// 导出结节数据为CSV
  static Future<String> exportNodulesCSV() async {
    final nodules = await DatabaseHelper.instance.getAllActiveNodules();
    
    final StringBuffer csv = StringBuffer();
    csv.writeln('患者ID,发现日期,直径(mm),密度类型,实性成分占比,肺叶,毛刺征,分叶征,恶性概率(%),风险等级,下次随访日期,随访计划');
    
    for (final n in nodules) {
      csv.writeln('${n.patientId.substring(0, 8)},'
          '${_formatDate(n.discoveryDate)},'
          '${n.diameter},'
          '${n.density.displayName},'
          '${n.solidComponentRatio != null ? (n.solidComponentRatio! * 100).toStringAsFixed(1) : ''},'
          '${n.lobe.displayName},'
          '${n.hasSpiculation ? '是' : '否'},'
          '${n.hasLobulation ? '是' : '否'},'
          '${n.malignancyProbability?.toStringAsFixed(2) ?? ''},'
          '${n.riskLevel ?? ''},'
          '${n.nextFollowUpDate != null ? _formatDate(n.nextFollowUpDate!) : ''},'
          '${n.followUpPlan ?? ''}');
    }
    
    return csv.toString();
  }
  
  /// 分享导出文件
  static Future<void> shareExport(String content, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '肺结节随访数据导出',
    );
  }
  
  /// 导入数据（JSON格式）
  static Future<ImportResult> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      int importedPatients = 0;
      int importedNodules = 0;
      
      final patientsData = data['patients'] as List<dynamic>?;
      if (patientsData == null) {
        return ImportResult(success: false, error: '无效的导入文件格式');
      }
      
      for (final patientData in patientsData) {
        try {
          // 创建新ID避免冲突
          final originalId = patientData['id'] as String;
          final newId = '${originalId}_imported_${DateTime.now().millisecondsSinceEpoch}';
          
          // 导入患者
          final patientMap = Map<String, dynamic>.from(patientData);
          patientMap['id'] = newId;
          patientMap['createdAt'] = DateTime.now().toIso8601String();
          patientMap['updatedAt'] = DateTime.now().toIso8601String();
          
          final patient = Patient.fromMap(patientMap);
          await DatabaseHelper.instance.insertPatient(patient);
          importedPatients++;
          
          // 导入该患者的结节
          final nodulesData = patientData['nodules'] as List<dynamic>?;
          if (nodulesData != null) {
            for (final noduleData in nodulesData) {
              final noduleMap = Map<String, dynamic>.from(noduleData);
              noduleMap['id'] = '${noduleMap['id']}_imported_${DateTime.now().millisecondsSinceEpoch}';
              noduleMap['patientId'] = newId;
              noduleMap['createdAt'] = DateTime.now().toIso8601String();
              noduleMap['updatedAt'] = DateTime.now().toIso8601String();
              
              final nodule = LungNodule.fromMap(noduleMap);
              await DatabaseHelper.instance.insertNodule(nodule);
              importedNodules++;
            }
          }
        } catch (e) {
          print('导入患者数据时出错: $e');
          continue;
        }
      }
      
      return ImportResult(
        success: true,
        importedPatients: importedPatients,
        importedNodules: importedNodules,
      );
    } catch (e) {
      return ImportResult(success: false, error: '导入失败: $e');
    }
  }
  
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 导入结果类
class ImportResult {
  final bool success;
  final int importedPatients;
  final int importedNodules;
  final String? error;
  
  ImportResult({
    required this.success,
    this.importedPatients = 0,
    this.importedNodules = 0,
    this.error,
  });
}