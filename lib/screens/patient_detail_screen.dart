import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/patient.dart';
import '../models/lung_nodule.dart';
import '../utils/app_localizations.dart';
import '../utils/malignancy_calculator.dart';
import 'add_follow_up_screen.dart';
import 'follow_up_history_dialog.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _patientId;
  Patient? _patient;
  List<LungNodule> _nodules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patientId = ModalRoute.of(context)?.settings.arguments as String?;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_patientId == null) return;
    
    final patient = await DatabaseHelper.instance.getPatient(_patientId!);
    final nodules = await DatabaseHelper.instance.getNodulesByPatient(_patientId!);
    
    setState(() {
      _patient = patient;
      _nodules = nodules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.patientInfo)),
        body: const Center(child: Text('Patient not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_patient!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit patient
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirm(context, loc),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc.patientInfo, icon: const Icon(Icons.person)),
            Tab(text: loc.nodule, icon: const Icon(Icons.favorite)),
            Tab(text: loc.followUpHistory, icon: const Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPatientInfoTab(loc),
          _buildNodulesTab(loc),
          _buildFollowUpTab(loc),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context, 
            '/add_nodule', 
            arguments: _patientId
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(loc.addNodule),
      ),
    );
  }

  Widget _buildPatientInfoTab(AppLocalizations loc) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 基本信息卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: _patient!.isHighRiskGroup 
                          ? Colors.red 
                          : Theme.of(context).colorScheme.primary,
                      child: Text(
                        _patient!.name.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 28, 
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _patient!.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_patient!.isMale ? loc.male : loc.female} | ${loc.age}: ${_patient!.age}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (_patient!.isHighRiskGroup)
                            Chip(
                              label: Text(loc.isHighRiskGroup),
                              backgroundColor: Colors.red[100],
                              labelStyle: TextStyle(color: Colors.red[800]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildInfoRow(loc.patientId, _patient!.id.substring(0, 8)),
                if (_patient!.phoneNumber != null)
                  _buildInfoRow(loc.phoneNumber, _patient!.phoneNumber!),
                if (_patient!.idCardNumber != null)
                  _buildInfoRow(loc.idCard, _patient!.idCardNumber!),
                _buildInfoRow(loc.createdAt, _formatDate(_patient!.createdAt)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 危险因素卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.riskFactors,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildRiskChip(loc.smoking, _patient!.isSmoker, 
                    subtitle: _patient!.isSmoker ? '${_patient!.packYears} ${loc.packYears}' : null),
                _buildRiskChip(loc.cancerHistory, _patient!.hasCancerHistory),
                _buildRiskChip(loc.familyHistory, _patient!.hasFamilyHistory),
                _buildRiskChip(loc.copd, _patient!.hasCOPD),
                _buildRiskChip(loc.tuberculosis, _patient!.hasTuberculosis),
                _buildRiskChip(loc.pulmonaryFibrosis, _patient!.hasPulmonaryFibrosis),
                _buildRiskChip(loc.highRiskExposure, _patient!.hasHighRiskExposure,
                    subtitle: _patient!.occupation),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNodulesTab(AppLocalizations loc) {
    if (_nodules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '暂无结节记录',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context, 
                  '/add_nodule', 
                  arguments: _patientId
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(loc.addNodule),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nodules.length,
      itemBuilder: (context, index) {
        final nodule = _nodules[index];
        return _buildNoduleCard(nodule, loc);
      },
    );
  }

  Widget _buildNoduleCard(LungNodule nodule, AppLocalizations loc) {
    final prob = nodule.malignancyProbability;
    final color = prob == null 
        ? Colors.grey 
        : prob < 5 
            ? Colors.green 
            : prob < 65 
                ? Colors.orange 
                : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            '${nodule.diameter.toStringAsFixed(1)}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('${nodule.density.displayName} - ${nodule.lobe.displayName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prob != null)
              Text(
                '${loc.malignancyProbability}: ${prob.toStringAsFixed(1)}% (${nodule.riskLevel})',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            if (nodule.nextFollowUpDate != null)
              Text(
                '${loc.nextFollowUp}: ${_formatDate(nodule.nextFollowUpDate!)}',
                style: TextStyle(
                  color: nodule.nextFollowUpDate!.isBefore(DateTime.now()) 
                      ? Colors.red 
                      : Colors.green,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildInfoRow(loc.discoveryDate, _formatDate(nodule.discoveryDate)),
                _buildInfoRow(loc.diameter, '${nodule.diameter} mm'),
                if (nodule.solidComponentRatio != null)
                  _buildInfoRow(loc.solidComponentRatio, '${(nodule.solidComponentRatio! * 100).toStringAsFixed(1)}%'),
                _buildInfoRow(loc.lobe, nodule.lobe.displayName),
                if (nodule.segment != null)
                  _buildInfoRow(loc.segment, nodule.segment!),
                const SizedBox(height: 8),
                Text(
                  loc.imagingFeatures,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (nodule.hasSpiculation) _buildFeatureChip(loc.spiculation),
                    if (nodule.hasLobulation) _buildFeatureChip(loc.lobulation),
                    if (nodule.hasPleuralIndentation) _buildFeatureChip(loc.pleuralIndentation),
                    if (nodule.hasVascularConvergence) _buildFeatureChip(loc.vascularConvergence),
                    if (nodule.hasBubbleSign) _buildFeatureChip(loc.bubbleSign),
                    if (nodule.hasCavity) _buildFeatureChip(loc.cavity),
                  ],
                ),
                if (nodule.followUpPlan != null) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  Text(
                    loc.followUpPlan,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(nodule.followUpPlan!),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFollowUpScreen(
                              noduleId: nodule.id,
                              patientId: _patientId!,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(loc.addFollowUpRecord),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FollowUpHistoryDialog(noduleId: nodule.id),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: Text(loc.followUpHistory),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpTab(AppLocalizations loc) {
    // TODO: Aggregate all follow-up records
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '随访历史功能开发中',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskChip(String label, bool value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.red : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: value ? Colors.red[800] : Colors.grey[600],
                    fontWeight: value ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (subtitle != null && value)
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.blue[50],
      labelStyle: TextStyle(color: Colors.blue[800]),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirm(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.confirmDelete),
        content: Text('${loc.delete} ${loc.patientInfo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (_patientId != null) {
                await DatabaseHelper.instance.deletePatient(_patientId!);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                }
              }
            },
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}