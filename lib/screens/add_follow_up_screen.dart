import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/patient.dart';
import '../models/lung_nodule.dart';
import '../models/follow_up_record.dart';
import '../utils/follow_up_plan_generator.dart';
import '../utils/app_localizations.dart';

class AddFollowUpScreen extends StatefulWidget {
  final String noduleId;
  final String patientId;

  const AddFollowUpScreen({
    super.key,
    required this.noduleId,
    required this.patientId,
  });

  @override
  State<AddFollowUpScreen> createState() => _AddFollowUpScreenState();
}

class _AddFollowUpScreenState extends State<AddFollowUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Patient? _patient;
  LungNodule? _nodule;
  FollowUpRecord? _previousRecord;
  
  final _diameterController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _doctorController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _adviceController = TextEditingController();
  final _notesController = TextEditingController();
  final _newSolidSizeController = TextEditingController();
  
  DateTime _checkDate = DateTime.now();
  String _checkMethod = '胸部CT平扫';
  
  bool _hasEnlargement = false;
  bool _hasNewSolidComponent = false;
  bool _hasSolidComponentIncrease = false;
  bool _hasMorphologyChange = false;
  bool _isStable = true;
  bool _isSuspicious = false;
  
  String? _densityChange;
  String? _morphologyChangeDesc;
  
  bool _isSaving = false;
  FollowUpPlan? _nextPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patient = await DatabaseHelper.instance.getPatient(widget.patientId);
    final nodule = await DatabaseHelper.instance.getNodule(widget.noduleId);
    final previousRecord = await DatabaseHelper.instance.getLatestFollowUpRecord(widget.noduleId);
    
    setState(() {
      _patient = patient;
      _nodule = nodule;
      _previousRecord = previousRecord;
      
      // 默认填入上次直径
      if (previousRecord != null) {
        _diameterController.text = previousRecord.diameter.toString();
      } else if (nodule != null) {
        _diameterController.text = nodule.diameter.toString();
      }
    });
  }

  void _calculateNextPlan() {
    if (_nodule == null) return;
    
    final currentDiameter = double.tryParse(_diameterController.text) ?? _nodule!.diameter;
    
    // 创建更新的结节对象用于计算
    final updatedNodule = _nodule!.copyWith(
      diameter: currentDiameter,
    );
    
    // 根据是否有变化判断是否是首次随访
    final isFirstVisit = _previousRecord == null;
    
    final plan = FollowUpPlanGenerator.generatePlan(
      updatedNodule,
      isFirstVisit: isFirstVisit,
    );
    
    setState(() {
      _nextPlan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    if (_patient == null || _nodule == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addFollowUpRecord),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveRecord,
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
            // 患者和结节信息
            _buildInfoCard(loc),
            const SizedBox(height: 24),
            
            // 检查信息
            _buildSectionTitle(loc.checkDate),
            _buildDatePicker(loc),
            const SizedBox(height: 16),
            
            _buildSectionTitle(loc.checkMethod),
            _buildMethodSelector(),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _hospitalController,
              label: '检查医院',
            ),
            _buildTextField(
              controller: _doctorController,
              label: '检查医生',
            ),
            const SizedBox(height: 24),
            
            // 结节测量
            _buildSectionTitle(loc.noduleChanges),
            _buildDiameterField(),
            const SizedBox(height: 16),
            
            // 变化开关
            _buildChangeSwitches(loc),
            const SizedBox(height: 16),
            
            if (_hasMorphologyChange)
              _buildTextField(
                controller: TextEditingController(text: _morphologyChangeDesc),
                label: '形态变化描述',
                hint: '描述分叶、毛刺等变化情况',
                onChanged: (v) => _morphologyChangeDesc = v,
              ),
            
            if (_hasNewSolidComponent || _hasSolidComponentIncrease)
              _buildTextField(
                controller: _newSolidSizeController,
                label: '实性成分大小(mm)',
                keyboardType: TextInputType.number,
              ),
            
            const SizedBox(height: 24),
            
            // 评估
            _buildSectionTitle('本次评估'),
            _buildAssessmentChips(),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _assessmentController,
              label: '评估结论',
              hint: '如：结节稳定，建议继续随访',
              maxLines: 2,
            ),
            _buildTextField(
              controller: _adviceController,
              label: loc.doctorAdvice,
              hint: '如：建议3个月后复查CT',
              maxLines: 2,
            ),
            _buildTextField(
              controller: _notesController,
              label: loc.notes,
              hint: '其他备注信息',
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // 下次随访计划
            if (_nextPlan != null) ...[
              _buildSectionTitle('建议下次随访'),
              _buildNextPlanCard(),
              const SizedBox(height: 32),
            ],
            
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveRecord,
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

  Widget _buildInfoCard(AppLocalizations loc) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text('${loc.age}: ${_patient!.age}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              '当前结节: ${_nodule!.density.displayName} - ${_nodule!.lobe.displayName}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text('初始直径: ${_nodule!.diameter}mm'),
            if (_previousRecord != null)
              Text('上次直径: ${_previousRecord!.diameter}mm (${_formatDate(_previousRecord!.checkDate)})'),
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
      title: Text(_formatDate(_checkDate)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _checkDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _checkDate = date;
          });
        }
      },
    );
  }

  Widget _buildMethodSelector() {
    final methods = ['胸部CT平扫', '胸部CT增强', '低剂量CT', '薄层CT', 'PET-CT'];
    
    return DropdownButtonFormField<String>(
      value: _checkMethod,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: methods.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _checkMethod = value!;
        });
      },
    );
  }

  Widget _buildDiameterField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _diameterController,
          decoration: InputDecoration(
            labelText: '本次测量直径(mm)',
            suffixText: 'mm',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _calculateNextPlan(),
        ),
        if (_previousRecord != null) ...[
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final current = double.tryParse(_diameterController.text);
              if (current == null) return const SizedBox();
              
              final change = current - _previousRecord!.diameter;
              final changePercent = (change / _previousRecord!.diameter) * 100;
              
              return Text(
                '较上次变化: ${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}mm (${changePercent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: change > 0 ? Colors.red : (change < 0 ? Colors.green : Colors.grey),
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildChangeSwitches(AppLocalizations loc) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('结节增大'),
          subtitle: const Text('直径增加或体积增大'),
          value: _hasEnlargement,
          onChanged: (v) => setState(() => _hasEnlargement = v),
        ),
        SwitchListTile(
          title: const Text('新增实性成分'),
          value: _hasNewSolidComponent,
          onChanged: (v) => setState(() => _hasNewSolidComponent = v),
        ),
        SwitchListTile(
          title: const Text('实性成分增加'),
          value: _hasSolidComponentIncrease,
          onChanged: (v) => setState(() => _hasSolidComponentIncrease = v),
        ),
        SwitchListTile(
          title: const Text('形态变化'),
          value: _hasMorphologyChange,
          onChanged: (v) => setState(() => _hasMorphologyChange = v),
        ),
      ],
    );
  }

  Widget _buildAssessmentChips() {
    return Wrap(
      spacing: 12,
      children: [
        ChoiceChip(
          label: const Text('结节稳定'),
          selected: _isStable && !_isSuspicious,
          onSelected: (v) {
            setState(() {
              _isStable = true;
              _isSuspicious = false;
            });
          },
        ),
        ChoiceChip(
          label: const Text('可疑恶性征象'),
          selected: _isSuspicious,
          selectedColor: Colors.red[100],
          onSelected: (v) {
            setState(() {
              _isSuspicious = v;
              _isStable = !v;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNextPlanCard() {
    return Card(
      color: Colors.blue[50],
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
                  '${_nextPlan!.months}个月后',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_nextPlan!.planCn),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: maxLines > 1,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _saveRecord() async {
    final diameter = double.tryParse(_diameterController.text);
    if (diameter == null) return;

    setState(() => _isSaving = true);

    try {
      final record = FollowUpRecord(
        id: const Uuid().v4(),
        noduleId: widget.noduleId,
        patientId: widget.patientId,
        checkDate: _checkDate,
        checkMethod: _checkMethod,
        hospitalName: _hospitalController.text.isEmpty ? null : _hospitalController.text,
        doctorName: _doctorController.text.isEmpty ? null : _doctorController.text,
        diameter: diameter,
        previousDiameter: _previousRecord?.diameter ?? _nodule?.diameter,
        diameterChange: _previousRecord != null 
            ? diameter - _previousRecord!.diameter 
            : null,
        hasEnlargement: _hasEnlargement,
        hasNewSolidComponent: _hasNewSolidComponent,
        hasSolidComponentIncrease: _hasSolidComponentIncrease,
        hasMorphologyChange: _hasMorphologyChange,
        morphologyChangeDesc: _morphologyChangeDesc,
        isStable: _isStable,
        isSuspicious: _isSuspicious,
        assessment: _assessmentController.text.isEmpty ? null : _assessmentController.text,
        doctorAdvice: _adviceController.text.isEmpty ? null : _adviceController.text,
        nextFollowUpDate: _nextPlan != null
            ? FollowUpPlanGenerator.calculateNextFollowUpDate(_checkDate, _nextPlan!.months)
            : null,
        nextFollowUpPlan: _nextPlan?.planCn,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertFollowUpRecord(record);

      // 更新结节的下次随访日期
      if (_nextPlan != null && _nodule != null) {
        final updatedNodule = _nodule!.copyWith(
          nextFollowUpDate: FollowUpPlanGenerator.calculateNextFollowUpDate(
            _checkDate, 
            _nextPlan!.months
          ),
          followUpPlan: _nextPlan?.planCn,
          followUpIntervalMonths: _nextPlan?.months,
        );
        await DatabaseHelper.instance.updateNodule(updatedNodule);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('随访记录保存成功')),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}