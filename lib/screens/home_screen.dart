import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../database/database_helper.dart';
import '../utils/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await DatabaseHelper.instance.getStatistics();
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              context.read<LocaleProvider>().toggleLocale();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 统计卡片
                    _buildStatsCards(loc),
                    const SizedBox(height: 24),
                    
                    // 快速操作
                    Text(
                      loc.quickActions,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(loc),
                    const SizedBox(height: 24),
                    
                    // 待随访提醒
                    Text(
                      loc.upcomingFollowUps,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildUpcomingFollowUps(loc),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCards(AppLocalizations loc) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          title: loc.totalPatients,
          value: _statistics['patientCount']?.toString() ?? '0',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _StatCard(
          title: loc.totalNodules,
          value: _statistics['noduleCount']?.toString() ?? '0',
          icon: Icons.favorite,
          color: Colors.red,
        ),
        _StatCard(
          title: loc.activeNodules,
          value: _statistics['activeNoduleCount']?.toString() ?? '0',
          icon: Icons.monitor_heart,
          color: Colors.orange,
        ),
        _StatCard(
          title: loc.overdueFollowUps,
          value: _statistics['overdueCount']?.toString() ?? '0',
          icon: Icons.warning,
          color: _statistics['overdueCount'] > 0 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildQuickActions(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.person_add,
            label: loc.addPatient,
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/add_patient'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.people,
            label: loc.patientList,
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, '/patients'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.calendar_month,
            label: loc.followUpCalendar,
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/calendar'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingFollowUps(AppLocalizations loc) {
    return FutureBuilder<List<dynamic>>(
      future: DatabaseHelper.instance.getUpcomingFollowUps(days: 30),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final nodules = snapshot.data ?? [];
        
        if (nodules.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  loc.noUpcomingFollowUps,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: nodules.length,
          itemBuilder: (context, index) {
            final nodule = nodules[index];
            final daysUntil = nodule.nextFollowUpDate?.difference(DateTime.now()).inDays ?? 0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: daysUntil < 0 ? Colors.red : 
                                   daysUntil <= 7 ? Colors.orange : Colors.blue,
                  child: Icon(
                    daysUntil < 0 ? Icons.warning : Icons.event,
                    color: Colors.white,
                  ),
                ),
                title: Text('${loc.nodule} #${nodule.id.substring(0, 8)}'),
                subtitle: Text(
                  daysUntil < 0 
                    ? loc.daysOverdue(-daysUntil)
                    : loc.daysUntil(daysUntil),
                ),
                trailing: Text(
                  '${nodule.diameter}mm',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // TODO: Navigate to nodule detail
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}