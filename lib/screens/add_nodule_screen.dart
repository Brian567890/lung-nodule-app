import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/lung_nodule.dart';
import '../models/patient.dart';
import '../utils/malignancy_calculator.dart';
import '../utils/follow_up_plan_generator.dart';
import '../utils/app_localizations.dart';

class AddNoduleScreen extends StatefulWidget {
  const AddNoduleScreen({super.key});

  @override
  State<AddNoduleScreen> createState() => _AddNoduleScreenState();
}

class _AddNoduleScreenState extends State<AddNoduleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _patientId;
  Patient? _patient;
  bool _isLoading = true;
  
  // 表单控制器
  final _diameterController = TextEditingController();
  final _solidRatioController = TextEditingController();
  final _solidSizeController = TextEditingController();
  final _segmentController = TextEditingController();
  final _locationController = TextEditingController();
  final _ctMinController = TextEditingController();
  final _ctMaxController = TextEditingController();
  final _ctMeanController = TextEditingController();
  
  // 选择值
  NoduleDensity _density = NoduleDensity.solid;
  LungLobe _lobe = LungLobe.rightUpper;
  DateTime _discoveryDate = DateTime.now();
  String _discoveryMethod = '机会性筛查';
  
  // 影像特征开关
  bool _hasSpiculation = false;
  bool _hasLobulation = false;
  bool _hasPleuralIndentation = false;
  bool _hasVascularConvergence = false;
  bool _hasBubbleSign = false;
  bool _hasCavity = false;
  
  bool _isSaving = false;
  double? _calculatedProbability;
  FollowUpPlan? _generatedPlan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _patientId = ModalRoute.of(context)?.settings.arguments as String?;
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    if (_patientId == null) return;
    
    final patient = await DatabaseHelper.instance.getPatient(_patientId!);
    setState(() {
      _patient = patient;
      _isLoading = false;
    });
    
    if (patient != null) {
      _calculateProbability();
    }
  }

  void _calculateProbability() {
    if (_patient == null || _diameterController.text.isEmpty) return;
    
    final diameter = double.tryParse(_diameterController.text);
    if (diameter == null) return;
    
    // 创建临时结节对象用于计算
    final tempNodule = LungNodule(
      id: '',
      patientId: _patientId!,
      discoveryDate: _discoveryDate,
      diameter: diameter,
      density: _density,
      lobe: _lobe,
      hasSpiculation: _hasSpiculation,
      hasLobulation: _hasLobulation,
      hasPleuralIndentation: _hasPleuralIndentation,
      hasVascularConvergence: _hasVascularConvergence,
      hasBubbleSign: _hasBubbleSign,
      hasCavity: _hasCavity,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final probability = MalignancyCalculator.calculateProbability(_patient!, tempNodule);
    final plan = FollowUpPlanGenerator.generatePlan(tempNodule, isFirstVisit: true);
    
    setState(() {
      _calculatedProbability = probability;
      _generatedPlan = plan;
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
        appBar: AppBar(title: Text(loc.addNodule)),
        body: const Center(child: Text('Patient not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addNodule),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveNodule,
            child: _isSaving 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                : Text(loc.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 患者信息卡片
            _buildPatientCard(loc),
            const SizedBox(height: 24),
            
            // 基本信息
            _buildSectionTitle(loc.noduleInfo),
            _buildDatePicker(loc),
            const SizedBox(height: 16),
            
            // 密度类型选择
            _buildDensitySelector(loc),
            const SizedBox(height: 16),
            
            // 直径
            _buildTextField(
              controller: _diameterController,
              label: loc.diameter,
              keyboardType: TextInputType.number,
              suffix: 'mm',
              onChanged: (_) => _calculateProbability(),
            ),
            
            // 实性成分（仅mGGN显示）
            if (_density == NoduleDensity.mGGN) ...[
              _buildTextField(
                controller: _solidRatioController,
                label: loc.solidComponentRatio,
                keyboardType: TextInputType.number,
                suffix: '%',
              ),
              _buildTextField(
                controller: _solidSizeController,
                label: loc.solidComponentSize,
                keyboardType: TextInputType.number,
                suffix: 'mm',
              ),
            ],
            
            const SizedBox(height: 24),
            
            // 位置
            _buildSectionTitle(loc.location),
            _buildLobeSelector(loc),
            _buildTextField(
              controller: _segmentController,
              label: loc.segment,
              hint: '如：S1, S2...',
            ),
            _buildTextField(
              controller: _locationController,
              label: '具体位置描述',
              hint: '如：胸膜下、血管旁等',
            ),
            
            const SizedBox(height: 24),
            
            // 影像特征
            _buildSectionTitle(loc.imagingFeatures),
            _buildFeatureSwitches(loc),
            
            const SizedBox(height: 24),
            
            // CT值
            _buildSectionTitle(loc.ctValue),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ctMinController,
                    label: loc.ctValueMin,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _ctMaxController,
                    label: loc.ctValueMax,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _ctMeanController,
                    label: loc.ctValueMean,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 计算结果
            if (_calculatedProbability != null) ...[
              _buildSectionTitle('${loc.malignancyProbability} (${loc.mayoModel})'),
              _buildProbabilityCard(loc),
              const SizedBox(height: 24),
            ],
            
            if (_generatedPlan != null) ...[
              _buildSectionTitle(loc.followUpPlan),
              _buildFollowUpPlanCard(loc),
              const SizedBox(height: 32),
            ],
            
            // 保存按钮
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveNodule,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? loc.loading : loc.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(AppLocalizations loc) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _patient!.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _patient!.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text('${loc.age}: ${_patient!.age} | ${_patient!.isMale ? loc.male : loc.female}'),
                  if (_patient!.isHighRiskGroup)
                    Chip(
                      label: Text(loc.isHighRiskGroup, style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.red[100],
                      labelStyle: TextStyle(color: Colors.red[800]),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDatePicker(AppLocalizations loc) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(loc.discoveryDate),
      subtitle: Text(
        '${_discoveryDate.year}-${_discoveryDate.month.toString().padLeft(2, '0')}-${_discoveryDate.day.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _discoveryDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _discoveryDate = date;
          });
          _calculateProbability();
        }
      },
    );
  }

  Widget _buildDensitySelector(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.density, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SegmentedButton<NoduleDensity>(
          segments: [
            ButtonSegment(
              value: NoduleDensity.solid,
              label: Text(loc.solid),
            ),
            ButtonSegment(
              value: NoduleDensity.pGGN,
              label: Text(loc.pGGN),
            ),
            ButtonSegment(
              value: NoduleDensity.mGGN,
              label: Text(loc.mGGN),
            ),
          ],
          selected: {_density},
          onSelectionChanged: (Set<NoduleDensity> newSelection) {
            setState(() {
              _density = newSelection.first;
            });
            _calculateProbability();
          },
        ),
      ],
    );
  }

  Widget _buildLobeSelector(AppLocalizations loc) {
    return DropdownButtonFormField<LungLobe>(
      value: _lobe,
      decoration: InputDecoration(
        labelText: loc.lobe,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: LungLobe.values.map((lobe) {
        String label;
        switch (lobe) {
          case LungLobe.rightUpper:
            label = loc.rightUpper;
            break;
          case LungLobe.rightMiddle:
            label = loc.rightMiddle;
            break;
          case LungLobe.rightLower:
            label = loc.rightLower;
            break;
          case LungLobe.leftUpper:
            label = loc.leftUpper;
            break;
          case LungLobe.leftLower:
            label = loc.leftLower;
            break;
        }
        return DropdownMenuItem(
          value: lobe,
          child: Text(label),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _lobe = value!;
        });
        _calculateProbability();
      },
    );
  }

  Widget _buildFeatureSwitches(AppLocalizations loc) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFeatureChip(loc.spiculation, _hasSpiculation, (v) {
          setState(() => _hasSpiculation = v);
          _calculateProbability();
        }),
        _buildFeatureChip(loc.lobulation, _hasLobulation, (v) {
          setState(() => _hasLobulation = v);
        }),
        _buildFeatureChip(loc.pleuralIndentation, _hasPleuralIndentation, (v) {
          setState(() => _hasPleuralIndentation = v);
        }),
        _buildFeatureChip(loc.vascularConvergence, _hasVascularConvergence, (v) {
          setState(() => _hasVascularConvergence = v);
        }),
        _buildFeatureChip(loc.bubbleSign, _hasBubbleSign, (v) {
          setState(() => _hasBubbleSign = v);
        }),
        _buildFeatureChip(loc.cavity, _hasCavity, (v) {
          setState(() => _hasCavity = v);
        }),
      ],
    );
  }

  Widget _buildFeatureChip(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildProbabilityCard(AppLocalizations loc) {
    final prob = _calculatedProbability!;
    final color = prob < 5 
        ? Colors.green 
        : prob < 65 
            ? Colors.orange 
            : Colors.red;
    
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${prob.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              MalignancyCalculator.getRiskLevel(prob),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(height: 24),
            Text(
              '${loc.recommendation}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              MalignancyCalculator.getRecommendation(prob, LungNodule(
                id: '',
                patientId: '',
                discoveryDate: DateTime.now(),
                diameter: double.tryParse(_diameterController.text) ?? 0,
                density: _density,
                lobe: _lobe,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpPlanCard(AppLocalizations loc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${loc.nextFollowUp}: ${loc.months(_generatedPlan!.months)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_generatedPlan!.planCn),
            const SizedBox(height: 8),
            Text(
              _generatedPlan!.planEn,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNodule() async {
    if (!_formKey.currentState!.validate()) return;
    
    final diameter = double.tryParse(_diameterController.text);
    if (diameter == null) return;

    setState(() => _isSaving = true);

    try {
      final nodule = LungNodule(
        id: const Uuid().v4(),
        patientId: _patientId!,
        discoveryDate: _discoveryDate,
        discoveryMethod: _discoveryMethod,
        diameter: diameter,
        density: _density,
        solidComponentRatio: double.tryParse(_solidRatioController.text),
        solidComponentSize: double.tryParse(_solidSizeController.text),
        lobe: _lobe,
        segment: _segmentController.text.isEmpty ? null : _segmentController.text,
        specificLocation: _locationController.text.isEmpty ? null : _locationController.text,
        hasSpiculation: _hasSpiculation,
        hasLobulation: _hasLobulation,
        hasPleuralIndentation: _hasPleuralIndentation,
        hasVascularConvergence: _hasVascularConvergence,
        hasBubbleSign: _hasBubbleSign,
        hasCavity: _hasCavity,
        ctValueMin: double.tryParse(_ctMinController.text),
        ctValueMax: double.tryParse(_ctMaxController.text),
        ctValueMean: double.tryParse(_ctMeanController.text),
        malignancyProbability: _calculatedProbability,
        riskLevel: _calculatedProbability != null 
            ? MalignancyCalculator.getRiskLevel(_calculatedProbability!)
            : null,
        nextFollowUpDate: _generatedPlan != null
            ? FollowUpPlanGenerator.calculateNextFollowUpDate(
                DateTime.now(), 
                _generatedPlan!.months
              )
            : null,
        followUpPlan: _generatedPlan?.planCn,
        followUpIntervalMonths: _generatedPlan?.months,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertNodule(nodule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).saveSuccess}')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _diameterController.dispose();
    _solidRatioController.dispose();
    _solidSizeController.dispose();
    _segmentController.dispose();
    _locationController.dispose();
    _ctMinController.dispose();
    _ctMaxController.dispose();
    _ctMeanController.dispose();
    super.dispose();
  }
}