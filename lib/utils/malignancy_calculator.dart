import 'dart:math';
import '../models/patient.dart';
import '../models/lung_nodule.dart';

/// 梅奥恶性概率计算工具
/// 基于梅奥诊所模型（Mayo Clinic Model）
/// 公式：恶性概率 = e^x / (1 + e^x)
/// 其中 x = -6.8272 + 0.0391×年龄 + 0.7917×吸烟史 + 1.3388×肿瘤史 + 
///           0.1274×直径 + 1.0407×毛刺征 + 0.7838×上叶位置
class MalignancyCalculator {
  
  /// 计算恶性概率（返回0-100的百分比）
  static double calculateProbability(Patient patient, LungNodule nodule) {
    // 梅奥模型线性预测值
    double x = -6.8272 +
        (0.0391 * patient.age) +
        (0.7917 * (patient.isSmoker ? 1 : 0)) +
        (1.3388 * (patient.hasCancerHistory ? 1 : 0)) +
        (0.1274 * nodule.diameter) +
        (1.0407 * (nodule.hasSpiculation ? 1 : 0)) +
        (0.7838 * (nodule.isUpperLobe ? 1 : 0));
    
    // Logistic函数转换为概率
    double probability = exp(x) / (1 + exp(x));
    
    // 转换为百分比并保留两位小数
    return double.parse((probability * 100).toStringAsFixed(2));
  }
  
  /// 获取风险等级
  static String getRiskLevel(double probability) {
    if (probability < 5) {
      return '低风险';
    } else if (probability < 65) {
      return '中风险';
    } else {
      return '高风险';
    }
  }
  
  static String getRiskLevelEn(double probability) {
    if (probability < 5) {
      return 'Low Risk';
    } else if (probability < 65) {
      return 'Moderate Risk';
    } else {
      return 'High Risk';
    }
  }
  
  /// 获取风险颜色（用于UI显示）
  static String getRiskColor(double probability) {
    if (probability < 5) {
      return '#4CAF50'; // 绿色
    } else if (probability < 65) {
      return '#FF9800'; // 橙色
    } else {
      return '#F44336'; // 红色
    }
  }
  
  /// 获取处理建议（基于ACCP指南）
  static String getRecommendation(double probability, LungNodule nodule) {
    if (probability < 5) {
      return '建议CT随访观察';
    } else if (probability < 65) {
      if (nodule.diameter > 8) {
        return '建议PET-CT检查或非手术活检';
      }
      return '建议CT随访或进一步检查';
    } else {
      return '建议手术切除或明确病理诊断';
    }
  }
  
  static String getRecommendationEn(double probability, LungNodule nodule) {
    if (probability < 5) {
      return 'CT surveillance recommended';
    } else if (probability < 65) {
      if (nodule.diameter > 8) {
        return 'PET-CT or non-surgical biopsy recommended';
      }
      return 'CT surveillance or further examination';
    } else {
      return 'Surgical resection or pathological diagnosis recommended';
    }
  }
}

/// 中国LCBP模型（可选，更适合中国人群）
/// 基于复旦大学附属中山医院白春学教授团队研究
class LCBPCalculator {
  /// LCBP模型计算（简化版）
  /// 结合肿瘤标志物（ProGRP、CEA、SCC、Cyfra21-1）和临床信息
  static double calculateProbability(
    Patient patient, 
    LungNodule nodule,
    Map<String, double>? biomarkers, // 肿瘤标志物
  ) {
    // 基础临床评分
    double clinicalScore = 0;
    
    // 年龄评分
    if (patient.age >= 50) clinicalScore += 1;
    if (patient.age >= 60) clinicalScore += 1;
    
    // 吸烟评分
    if (patient.isSmoker) clinicalScore += 2;
    if (patient.packYears >= 20) clinicalScore += 1;
    
    // 家族史和肿瘤史
    if (patient.hasFamilyHistory) clinicalScore += 1;
    if (patient.hasCancerHistory) clinicalScore += 2;
    
    // 结节特征评分
    if (nodule.diameter >= 8) clinicalScore += 1;
    if (nodule.diameter >= 15) clinicalScore += 1;
    if (nodule.hasSpiculation) clinicalScore += 2;
    if (nodule.isUpperLobe) clinicalScore += 1;
    if (nodule.density == NoduleDensity.mGGN) clinicalScore += 1;
    
    // 肿瘤标志物评分（如有）
    double biomarkerScore = 0;
    if (biomarkers != null) {
      if (biomarkers['ProGRP'] != null && biomarkers['ProGRP']! > 65) {
        biomarkerScore += 1; // 小细胞肺癌相关
      }
      if (biomarkers['CEA'] != null && biomarkers['CEA']! > 5) {
        biomarkerScore += 1; // 腺癌相关
      }
      if (biomarkers['SCC'] != null && biomarkers['SCC']! > 1.5) {
        biomarkerScore += 1; // 鳞癌相关
      }
      if (biomarkers['Cyfra21-1'] != null && biomarkers['Cyfra21-1']! > 3.3) {
        biomarkerScore += 1; // 非小细胞肺癌相关
      }
    }
    
    double totalScore = clinicalScore + biomarkerScore;
    
    // 转换为概率（简化线性映射）
    double probability = (totalScore / 15) * 100;
    return probability.clamp(0, 100);
  }
}