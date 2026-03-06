# 开发者指南

## 环境配置

### 必需工具
- Flutter SDK (>=3.16.0)
- Android Studio / VS Code
- Git

### 推荐配置
```bash
# Flutter版本
flutter --version

# 检查环境
flutter doctor

# 启用桌面支持（可选）
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
```

## 代码规范

### 命名规范
- 文件：小写下划线命名 `patient_list_screen.dart`
- 类：大驼峰 `PatientListScreen`
- 方法/变量：小驼峰 `patientName`
- 常量：大写下划线 `MAX_RETRY_COUNT`

### 目录组织
```
lib/
├── main.dart              # 入口
├── models/                # 数据模型
├── database/              # 数据库
├── screens/               # 页面
├── widgets/               # 公共组件（新增）
├── providers/             # 状态管理
├── utils/                 # 工具类
└── l10n/                  # 国际化
```

### 提交规范
```
feat: 添加新功能
fix: 修复bug
docs: 文档更新
style: 代码格式（不影响功能）
refactor: 重构
test: 测试相关
chore: 构建/工具相关
```

## 添加新功能流程

1. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **开发测试**
   ```bash
   flutter test
   flutter run
   ```

3. **提交代码**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/your-feature-name
   ```

4. **创建PR**
   - 目标分支：develop
   - 填写PR描述
   - 关联相关Issue

## 数据库迁移

如需修改数据库结构：

1. 修改 `database_helper.dart` 中的 `_createDB` 方法
2. 增加数据库版本号
3. 在 `onUpgrade` 中处理迁移逻辑

```dart
// 版本升级示例
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE patients ADD COLUMN new_field TEXT');
  }
}
```

## 发布流程

### 版本号规范
遵循语义化版本：MAJOR.MINOR.PATCH
- MAJOR：不兼容的API修改
- MINOR：向下兼容的功能添加
- PATCH：向下兼容的问题修复

### 发布步骤
1. 更新版本号（`pubspec.yaml`）
2. 更新 `CHANGELOG.md`
3. 创建tag并推送
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
4. CI自动构建并发布Release

## 调试技巧

### 数据库调试
```bash
# Android数据库位置
/data/data/com.example.lung_nodule_app/databases/lung_nodule.db

# 导出查看
adb shell run-as com.example.lung_nodule_app cp databases/lung_nodule.db /sdcard/
adb pull /sdcard/lung_nodule.db
```

### 性能分析
```bash
flutter run --profile
flutter build apk --analyze-size
```

## 常见问题

### Q: 依赖冲突
```bash
flutter pub deps
flutter pub upgrade
```

### Q: 代码生成
```bash
flutter pub run build_runner build
```

### Q: 清理重建
```bash
flutter clean
flutter pub get
flutter run
```