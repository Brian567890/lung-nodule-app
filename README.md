# 肺结节随访管理APP - Lung Nodule Follow-up

[![Flutter CI](https://github.com/yourusername/lung_nodule_app/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/yourusername/lung_nodule_app/actions/workflows/flutter_ci.yml)

基于《肺结节诊治中国专家共识（2024年版）》开发的肺结节随访管理应用程序。

## 📱 功能特点

### 核心功能
- ✅ **患者管理**：唯一编号、身份信息、手机号绑定
- ✅ **肺结节录入**：大小、位置、密度、影像特征
- ✅ **恶性概率计算**：梅奥模型（Mayo Clinic Model）
- ✅ **随访计划生成**：2024版专家共识自动计算
- ✅ **随访提醒**：日历视图 + 逾期提醒
- ✅ **统计分析**：图表可视化数据分布

### 数据管理
- 📤 导出JSON（完整备份）
- 📤 导出CSV（Excel兼容）
- 📥 导入JSON数据恢复
- 🔒 本地存储，隐私安全

### 界面特性
- 🌐 中英文一键切换
- 🎨 专业医疗风格主题
- 🌙 深色/浅色模式
- 📊 统计图表可视化

## 🚀 快速开始

### 下载安装
从 [Releases](https://github.com/yourusername/lung_nodule_app/releases) 页面下载最新版APK。

### 构建运行

```bash
# 克隆仓库
git clone https://github.com/yourusername/lung_nodule_app.git
cd lung_nodule_app

# 安装依赖
flutter pub get

# 运行调试
flutter run

# 构建发布版APK
flutter build apk --release
```

## 📖 使用文档

详见 [使用手册](docs/USER_MANUAL.md)

## 🏥 医疗专业性

### 参考指南
- 《肺结节诊治中国专家共识（2024年版）》
- 中华医学会呼吸病学分会
- 中国肺癌防治联盟专家组

### 算法依据
**梅奥恶性概率模型**：
```
恶性概率 = e^x / (1 + e^x)

x = -6.8272 + 
    (0.0391 × 年龄) + 
    (0.7917 × 吸烟史) + 
    (1.3388 × 肿瘤史) + 
    (0.1274 × 直径) + 
    (1.0407 × 毛刺征) + 
    (0.7838 × 上叶位置)
```

## 📸 界面预览

| 首页 | 患者列表 | 结节录入 |
|------|---------|---------|
| 统计卡片 + 待随访提醒 | 搜索 + 高危标识 | 实时概率计算 |

| 随访日历 | 统计分析 | 设置 |
|---------|---------|------|
| 月视图提醒 | 图表可视化 | 导入导出 |

## 🛠️ 技术栈

- **Flutter** - 跨平台UI框架
- **Dart** - 编程语言
- **SQLite** - 本地数据存储
- **Provider** - 状态管理
- **FL Chart** - 统计图表

## 🔄 CI/CD

### 自动构建
- 每次推送到main分支自动构建APK
- 创建tag时自动发布Release

### 部署渠道
- GitHub Releases
- Firebase App Distribution（可选）

## 📁 项目结构

```
lung_nodule_app/
├── lib/
│   ├── main.dart                 # 入口文件
│   ├── models/                   # 数据模型
│   │   ├── patient.dart
│   │   ├── lung_nodule.dart
│   │   └── follow_up_record.dart
│   ├── database/                 # SQLite数据库
│   │   └── database_helper.dart
│   ├── screens/                  # 页面
│   │   ├── home_screen.dart
│   │   ├── patient_list_screen.dart
│   │   ├── add_patient_screen.dart
│   │   ├── add_nodule_screen.dart
│   │   ├── patient_detail_screen.dart
│   │   ├── follow_up_calendar_screen.dart
│   │   ├── statistics_screen.dart
│   │   └── settings_screen.dart
│   ├── providers/                # 状态管理
│   ├── utils/                    # 工具类
│   │   ├── medical_theme.dart
│   │   ├── malignancy_calculator.dart
│   │   ├── follow_up_plan_generator.dart
│   │   └── data_export_helper.dart
│   └── l10n/                     # 国际化
├── android/                      # Android配置
├── docs/                         # 文档
│   └── USER_MANUAL.md
├── .github/workflows/            # CI/CD配置
│   ├── flutter_ci.yml
│   └── deploy_firebase.yml
└── README.md
```

## 🤝 贡献

欢迎提交Issue和PR！

### 开发计划
- [ ] DICOM文件查看
- [ ] 三维重建支持
- [ ] AI辅助分析
- [ ] 云端数据同步
- [ ] 患者端APP

## 📝 许可证

MIT License

## ⚠️ 免责声明

本APP仅供参考，不能替代医生的专业判断。诊疗决策应基于完整的临床信息和多学科讨论。

---

**Made with ❤️ for healthcare professionals**