# 更新日志

所有显著的更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

## [1.0.0] - 2024-03-06

### 新增
- ✅ 患者管理：唯一编号、身份信息、手机号绑定
- ✅ 肺结节录入：大小、位置、密度、影像特征
- ✅ 恶性概率计算：梅奥模型实时计算
- ✅ 随访计划生成：2024版专家共识自动计算
- ✅ 随访提醒：日历视图 + 逾期提醒
- ✅ 随访记录：每次复查数据记录和对比
- ✅ 统计分析：饼图、柱状图、折线图可视化
- ✅ 数据导出：JSON备份、CSV表格导出
- ✅ 数据导入：从JSON恢复数据
- ✅ 中英文切换：完整国际化支持
- ✅ 主题切换：浅色/深色模式
- ✅ 医疗主题：专业UI设计
- ✅ CI/CD：GitHub Actions自动构建和发布

### 技术特性
- Flutter跨平台框架
- SQLite本地数据存储
- Provider状态管理
- FL Chart统计图表
- 完全离线使用

## [0.9.0] - 2024-03-01

### 新增
- 基础项目框架搭建
- 数据库设计
- 患者和结节模型定义
- 梅奥模型算法实现
- 随访计划算法实现

[Unreleased]: https://github.com/yourusername/lung_nodule_app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/lung_nodule_app/compare/v0.9.0...v1.0.0
[0.9.0]: https://github.com/yourusername/lung_nodule_app/releases/tag/v0.9.0