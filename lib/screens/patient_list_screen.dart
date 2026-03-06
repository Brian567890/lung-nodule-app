import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/patient.dart';
import '../utils/app_localizations.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await DatabaseHelper.instance.getAllPatients();
    setState(() {
      _patients = patients;
      _filteredPatients = patients;
      _isLoading = false;
    });
  }

  void _filterPatients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPatients = _patients;
      });
      return;
    }

    final filtered = _patients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase()) ||
          (patient.phoneNumber?.contains(query) ?? false) ||
          (patient.idCardNumber?.contains(query) ?? false);
    }).toList();

    setState(() {
      _filteredPatients = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.patientList),
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPatients('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterPatients,
            ),
          ),
          
          // 患者列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, 
                                 size: 64, 
                                 color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              loc.search,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _buildPatientCard(patient, loc);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_patient');
          if (result == true) {
            _loadPatients();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(loc.addPatient),
      ),
    );
  }

  Widget _buildPatientCard(Patient patient, AppLocalizations loc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.isHighRiskGroup ? Colors.red : Colors.blue,
          child: Text(
            patient.name.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Text(patient.name),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: patient.isMale ? Colors.blue[100] : Colors.pink[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                patient.isMale ? loc.male : loc.female,
                style: TextStyle(
                  fontSize: 12,
                  color: patient.isMale ? Colors.blue[800] : Colors.pink[800],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.age}: ${patient.age}'),
            if (patient.phoneNumber != null)
              Text('${loc.phoneNumber}: ${patient.phoneNumber}'),
          ],
        ),
        trailing: patient.isHighRiskGroup
            ? Chip(
                label: Text(
                  loc.isHighRiskGroup,
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.red[100],
                labelStyle: TextStyle(color: Colors.red[800]),
              )
            : null,
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            '/patient_detail',
            arguments: patient.id,
          );
          if (result == true) {
            _loadPatients();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}