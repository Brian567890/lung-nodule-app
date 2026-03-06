import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../database/database_helper.dart';
import '../utils/data_export_helper.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionHeader('外观设置'),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.language),
            subtitle: Text(localeProvider.currentLanguageText),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, loc, localeProvider),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(loc.theme),
            subtitle: Text(_getThemeText(themeProvider.themeMode, loc)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, loc, themeProvider),
          ),
          const Divider(),
          
          // 数据管理
          _buildSectionHeader('数据管理'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('导出数据'),
            subtitle: const Text('导出为JSON或CSV格式'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportOptions(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导入数据'),
            subtitle: const Text('从JSON文件导入'),
            trailing: _isImporting 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isImporting ? null : () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('统计分析'),
            subtitle: const Text('查看数据报表和图表'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/statistics'),
          ),
          const Divider(),
          
          // 系统
          _buildSectionHeader('系统'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(loc.clearAllData, style: const TextStyle(color: Colors.red)),
            onTap: () => _showClearDataConfirm(context, loc),
          ),
          const Divider(),
          
          // 关于
          _buildSectionHeader(loc.about),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('肺结节随访管理系统'),
            subtitle: const Text('基于2024版专家共识'),
          ),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: Text(loc.version),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode mode, AppLocalizations loc) {
    switch (mode) {
      case ThemeMode.light:
        return loc.lightTheme;
      case ThemeMode.dark:
        return loc.darkTheme;
      case ThemeMode.system:
        return loc.systemDefault;
    }
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations loc, LocaleProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('中文'),
              trailing: provider.locale.languageCode == 'zh' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                provider.setLocale(const Locale('zh', 'CN'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: provider.locale.languageCode == 'en' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                provider.setLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, AppLocalizations loc, ThemeProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.lightTheme),
              trailing: provider.themeMode == ThemeMode.light 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(loc.darkTheme),
              trailing: provider.themeMode == ThemeMode.dark 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(loc.systemDefault),
              trailing: provider.themeMode == ThemeMode.system 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('选择导出格式', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.data_object, color: Colors.blue),
              title: const Text('导出为JSON'),
              subtitle: const Text('包含完整数据，可用于备份和恢复'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('json');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('导出患者列表(CSV)'),
              subtitle: const Text('可用Excel打开的表格格式'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('csv_patients');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.orange),
              title: const Text('导出结节数据(CSV)'),
              subtitle: const Text('包含结节详细信息'),
              onTap: () async {
                Navigator.pop(context);
                await _exportData('csv_nodules');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    setState(() => _isExporting = true);
    
    try {
      String content;
      String fileName;
      
      switch (format) {
        case 'json':
          content = await DataExportHelper.exportAllData();
          fileName = 'lung_nodule_backup_${_formatDateTime(DateTime.now())}.json';
          break;
        case 'csv_patients':
          content = await DataExportHelper.exportPatientsCSV();
          fileName = 'patients_${_formatDateTime(DateTime.now())}.csv';
          break;
        case 'csv_nodules':
          content = await DataExportHelper.exportNodulesCSV();
          fileName = 'nodules_${_formatDateTime(DateTime.now())}.csv';
          break;
        default:
          return;
      }
      
      await DataExportHelper.shareExport(content, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导出成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) return;
      
      setState(() => _isImporting = true);
      
      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      
      // 显示确认对话框
      if (!mounted) return;
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认导入'),
          content: const Text('导入数据将与现有数据合并。是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) {
        setState(() => _isImporting = false);
        return;
      }
      
      final importResult = await DataExportHelper.importFromJson(content);
      
      if (mounted) {
        if (importResult.success) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('导入成功'),
              content: Text('成功导入 ${importResult.importedPatients} 位患者，${importResult.importedNodules} 个结节'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(importResult.error ?? '导入失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showClearDataConfirm(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空数据'),
        content: const Text('此操作将删除所有患者和结节数据，不可恢复！\n\n建议先导出备份。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.deleteAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('数据已清空')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
  }
}