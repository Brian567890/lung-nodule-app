import '../models/lung_nodule.dart';
import '../models/follow_up_record.dart';

/// 随访计划生成器
/// 基于《肺结节诊治中国专家共识（2024年版）》
class FollowUpPlanGenerator {
  
  /// 生成随访计划
  /// 返回下次随访日期、随访间隔月数、随访方案描述
  static FollowUpPlan generatePlan(
    LungNodule nodule, {
    FollowUpRecord? lastRecord,
    bool isFirstVisit = true,
  }) {
    // 根据结节类型和大小确定随访方案
    if (nodule.density == NoduleDensity.solid) {
      return _generateSolidNodulePlan(nodule, lastRecord, isFirstVisit);
    } else if (nodule.density == NoduleDensity.pGGN) {
      return _generatePGGNPlan(nodule, lastRecord, isFirstVisit);
    } else {
      return _generateMGGNPlan(nodule, lastRecord, isFirstVisit);
    }
  }
  
  /// 实性结节随访方案
  static FollowUpPlan _generateSolidNodulePlan(
    LungNodule nodule,
    FollowUpRecord? lastRecord,
    bool isFirstVisit,
  ) {
    double diameter = lastRecord?.diameter ?? nodule.diameter;
    int months = 0;
    String planCn = '';
    String planEn = '';
    
    if (diameter <= 4) {
      // ≤4mm：常规年度检查
      months = 12;
      planCn = '结节≤4mm，建议常规年度CT随访';
      planEn = 'Nodule ≤4mm, annual CT surveillance recommended';
    } else if (diameter <= 6) {
      // 4-6mm：6-12个月随访
      if (isFirstVisit) {
        months = 6;
        planCn = '结节4-6mm，建议6-12个月CT随访；如无变化，18-24个月再次随访';
        planEn = 'Nodule 4-6mm, CT at 6-12 months; if stable, repeat at 18-24 months';
      } else {
        // 第二次随访后
        months = 12;
        planCn = '结节稳定，转为常规年度随访';
        planEn = 'Nodule stable, switch to annual surveillance';
      }
    } else if (diameter <= 8) {
      // 6-8mm：3-6个月随访
      if (isFirstVisit) {
        months = 3;
        planCn = '结节6-8mm，建议3-6个月CT随访；随后9-12个月随访，之后每6个月随访，2年后无变化转年度随访';
        planEn = 'Nodule 6-8mm, CT at 3-6 months, then 9-12 months, then every 6 months for 2 years';
      } else {
        months = 6;
        planCn = '继续密切随访，建议6个月后复查';
        planEn = 'Continue close surveillance, repeat CT in 6 months';
      }
    } else {
      // >8mm：根据恶性概率决定
      double? probability = nodule.malignancyProbability;
      
      if (probability == null) {
        months = 3;
        planCn = '结节>8mm，建议先评估恶性概率，必要时3个月复查CT';
        planEn = 'Nodule >8mm, assess malignancy probability, consider CT at 3 months';
      } else if (probability < 5) {
        months = 3;
        planCn = '恶性概率低（<5%），建议CT随访';
        planEn = 'Low malignancy probability (<5%), CT surveillance recommended';
      } else if (probability < 65) {
        months = 1;
        planCn = '恶性概率中低（5-65%），建议PET-CT或非手术活检进一步评估';
        planEn = 'Moderate malignancy probability (5-65%), consider PET-CT or biopsy';
      } else {
        months = 1;
        planCn = '恶性概率高（>65%），建议尽快手术切除或明确病理诊断';
        planEn = 'High malignancy probability (>65%), surgical resection recommended';
      }
    }
    
    return FollowUpPlan(
      months: months,
      planCn: planCn,
      planEn: planEn,
    );
  }
  
  /// 纯磨玻璃结节随访方案
  static FollowUpPlan _generatePGGNPlan(
    LungNodule nodule,
    FollowUpRecord? lastRecord,
    bool isFirstVisit,
  ) {
    double diameter = lastRecord?.diameter ?? nodule.diameter;
    int months = 0;
    String planCn = '';
    String planEn = '';
    
    if (diameter <= 5) {
      // ≤5mm：6个月随访，随后年度随访
      if (isFirstVisit) {
        months = 6;
        planCn = '纯磨玻璃结节≤5mm，建议6个月影像随访，随后年度CT随访';
        planEn = 'pGGN ≤5mm, imaging at 6 months, then annual CT';
      } else {
        months = 12;
        planCn = '继续年度随访';
        planEn = 'Continue annual surveillance';
      }
    } else if (diameter <= 10) {
      // 5-10mm：3个月随访
      if (isFirstVisit) {
        months = 3;
        planCn = '纯磨玻璃结节5-10mm，建议3个月CT随访确认；如无变化，6个月随访；建议AI+MDT评估';
        planEn = 'pGGN 5-10mm, CT at 3 months to confirm; if stable, 6 months; consider AI+MDT';
      } else {
        // 需要评估是否持续存在
        months = 6;
        planCn = '结节持续存在，继续6个月随访；如持续存在，考虑非手术活检或手术';
        planEn = 'Persistent nodule, continue 6-month surveillance; consider biopsy if persistent';
      }
    } else {
      // >10mm：考虑非手术活检或手术
      months = 3;
      planCn = '纯磨玻璃结节>10mm，建议考虑非手术活检和/或手术切除';
      planEn = 'pGGN >10mm, consider non-surgical biopsy and/or surgical resection';
    }
    
    return FollowUpPlan(
      months: months,
      planCn: planCn,
      planEn: planEn,
    );
  }
  
  /// 混杂性结节随访方案
  static FollowUpPlan _generateMGGNPlan(
    LungNodule nodule,
    FollowUpRecord? lastRecord,
    bool isFirstVisit,
  ) {
    double diameter = lastRecord?.diameter ?? nodule.diameter;
    double? solidSize = nodule.solidComponentSize;
    int months = 0;
    String planCn = '';
    String planEn = '';
    
    if (diameter <= 8) {
      // ≤8mm：3、6、12、24个月随访
      if (isFirstVisit) {
        months = 3;
        planCn = '混杂性结节≤8mm，建议3、6、12、24个月影像随访；随访中结节增大或实性成分增多通常提示恶性';
        planEn = 'mGGN ≤8mm, imaging at 3, 6, 12, 24 months; enlargement or solid component increase suggests malignancy';
      } else if (lastRecord != null) {
        // 根据上次随访时间推算
        int followUpCount = _estimateFollowUpCount(lastRecord.checkDate, nodule.discoveryDate);
        if (followUpCount == 1) {
          months = 3; // 6个月时
          planCn = '6个月随访';
        } else if (followUpCount == 2) {
          months = 6; // 12个月时
          planCn = '12个月随访';
        } else if (followUpCount == 3) {
          months = 12; // 24个月时
          planCn = '24个月随访，之后转常规年度检查';
        } else {
          months = 12;
          planCn = '年度随访';
        }
      } else {
        months = 3;
        planCn = '继续随访';
      }
    } else {
      // >8mm
      if (isFirstVisit) {
        months = 3;
        planCn = '混杂性结节>8mm，建议3个月CT复查；如持续存在，建议AI+MDT评估，考虑PET-CT、非手术活检或手术';
        planEn = 'mGGN >8mm, CT at 3 months; if persistent, AI+MDT evaluation, consider PET-CT or biopsy';
      } else {
        months = 3;
        planCn = '结节持续存在，建议进一步评估处理';
        planEn = 'Persistent nodule, further evaluation recommended';
      }
    }
    
    // 实性成分特别提醒
    if (solidSize != null && solidSize > 5) {
      planCn += '\n【注意】实性成分>5mm，需高度警惕，建议积极处理';
      planEn += '\n[Note] Solid component >5mm, high vigilance required, active management recommended';
    }
    
    return FollowUpPlan(
      months: months,
      planCn: planCn,
      planEn: planEn,
    );
  }
  
  /// 估算随访次数
  static int _estimateFollowUpCount(DateTime lastCheck, DateTime discovery) {
    int months = (lastCheck.year - discovery.year) * 12 + (lastCheck.month - discovery.month);
    if (months <= 3) return 0;
    if (months <= 6) return 1;
    if (months <= 12) return 2;
    return 3;
  }
  
  /// 计算下次随访日期
  static DateTime calculateNextFollowUpDate(DateTime fromDate, int months) {
    return DateTime(fromDate.year, fromDate.month + months, fromDate.day);
  }
  
  /// 判断随访中是否出现恶性征象
  static bool hasMalignantSignsInFollowUp(FollowUpRecord record) {
    // 2024共识恶性征象：
    // 1. 直径增大，倍增时间符合肿瘤生长规律（实性20-400天，亚实性400-800天）
    // 2. 病灶稳定或增大并出现实性成分
    // 3. 病灶缩小但出现实性成分或实性成分增加
    // 4. 血管生成符合恶性规律
    // 5. 出现分叶、毛刺和/或胸膜凹陷征
    
    return record.hasEnlargement ||
           record.hasNewSolidComponent ||
           record.hasSolidComponentIncrease ||
           record.isSuspicious;
  }
  
  /// 获取随访提醒文本
  static String getReminderText(LungNodule nodule, DateTime nextDate, String language) {
    int daysUntil = nextDate.difference(DateTime.now()).inDays;
    
    if (language == 'zh') {
      if (daysUntil < 0) {
        return '【逾期】患者${nodule.patientId}的肺结节随访已逾期${-daysUntil}天，请尽快安排复查';
      } else if (daysUntil <= 7) {
        return '【即将到期】患者${nodule.patientId}的肺结节随访将在${daysUntil}天内到期';
      } else {
        return '患者${nodule.patientId}的肺结节随访将于${daysUntil}天后到期';
      }
    } else {
      if (daysUntil < 0) {
        return '[OVERDUE] Patient ${nodule.patientId} nodule follow-up overdue by ${-daysUntil} days';
      } else if (daysUntil <= 7) {
        return '[SOON] Patient ${nodule.patientId} nodule follow-up due in ${daysUntil} days';
      } else {
        return 'Patient ${nodule.patientId} nodule follow-up due in ${daysUntil} days';
      }
    }
  }
}

/// 随访计划数据类
class FollowUpPlan {
  final int months;           // 随访间隔月数
  final String planCn;        // 中文方案
  final String planEn;        // 英文方案
  
  FollowUpPlan({
    required this.months,
    required this.planCn,
    required this.planEn,
  });
  
  String getPlan(String language) {
    return language == 'zh' ? planCn : planEn;
  }
}