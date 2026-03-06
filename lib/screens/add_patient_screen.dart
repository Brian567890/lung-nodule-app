import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/patient.dart';
import '../utils/app_localizations.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idCardController = TextEditingController();
  final _occupationController = TextEditingController();
  final _packYearsController = TextEditingController();
  
  bool _isMale = true;
  bool _isSmoker = false;
  bool _hasCancerHistory = false;
  bool _hasFamilyHistory = false;
  bool _hasCOPD = false;
  bool _hasTuberculosis = false;
  bool _hasPulmonaryFibrosis = false;
  bool _hasHighRiskExposure = false;
  
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.addPatient),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 基本信息
            _buildSectionTitle(loc.patientInfo),
            _buildTextField(
              controller: _nameController,
              label: loc.patientName,
              validator: (value) => value?.isEmpty ?? true ? loc.pleaseEnterName : null,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: loc.age,
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? loc.pleaseEnterAge : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.gender),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _isMale,
                            onChanged: (value) => setState(() => _isMale = value!),
                          ),
                          Text(loc.male),
                          Radio<bool>(
                            value: false,
                            groupValue: _isMale,
                            onChanged: (value) => setState(() => _isMale = value!),
                          ),
                          Text(loc.female),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: _phoneController,
              label: loc.phoneNumber,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _idCardController,
              label: loc.idCard,
            ),
            const SizedBox(height: 24),
            
            // 危险因素
            _buildSectionTitle(loc.riskFactors),
            _buildSwitchTile(
              title: loc.smoking,
              value: _isSmoker,
              onChanged: (value) => setState(() => _isSmoker = value),
            ),
            if (_isSmoker)
              _buildTextField(
                controller: _packYearsController,
                label: loc.packYears,
                keyboardType: TextInputType.number,
              ),
            _buildSwitchTile(
              title: loc.cancerHistory,
              value: _hasCancerHistory,
              onChanged: (value) => setState(() => _hasCancerHistory = value),
            ),
            _buildSwitchTile(
              title: loc.familyHistory,
              value: _hasFamilyHistory,
              onChanged: (value) => setState(() => _hasFamilyHistory = value),
            ),
            _buildSwitchTile(
              title: loc.copd,
              value: _hasCOPD,
              onChanged: (value) => setState(() => _hasCOPD = value),
            ),
            _buildSwitchTile(
              title: loc.tuberculosis,
              value: _hasTuberculosis,
              onChanged: (value) => setState(() => _hasTuberculosis = value),
            ),
            _buildSwitchTile(
              title: loc.pulmonaryFibrosis,
              value: _hasPulmonaryFibrosis,
              onChanged: (value) => setState(() => _hasPulmonaryFibrosis = value),
            ),
            _buildSwitchTile(
              title: loc.highRiskExposure,
              value: _hasHighRiskExposure,
              onChanged: (value) => setState(() => _hasHighRiskExposure = value),
            ),
            if (_hasHighRiskExposure)
              _buildTextField(
                controller: _occupationController,
                label: loc.occupation,
                hint: '如：石棉、铍、铀、氡等',
              ),
            const SizedBox(height: 32),
            
            // 保存按钮
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _savePatient,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final patient = Patient(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        isMale: _isMale,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        idCardNumber: _idCardController.text.isEmpty ? null : _idCardController.text,
        isSmoker: _isSmoker,
        packYears: int.tryParse(_packYearsController.text) ?? 0,
        hasCancerHistory: _hasCancerHistory,
        hasFamilyHistory: _hasFamilyHistory,
        hasCOPD: _hasCOPD,
        hasTuberculosis: _hasTuberculosis,
        hasPulmonaryFibrosis: _hasPulmonaryFibrosis,
        occupation: _occupationController.text.isEmpty ? null : _occupationController.text,
        hasHighRiskExposure: _hasHighRiskExposure,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DatabaseHelper.instance.insertPatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).saveSuccess)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _occupationController.dispose();
    _packYearsController.dispose();
    super.dispose();
  }
}