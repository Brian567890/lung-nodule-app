import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/lung_nodule.dart';
import '../utils/app_localizations.dart';

/// 统计分析页面
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<LungNodule> _nodules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await DatabaseHelper.instance.getStatistics();
    final nodules = await DatabaseHelper.instance.getAllActiveNodules();
    
    setState(() {
      _stats = stats;
      _nodules = nodules;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 24),
                    _buildRiskDistributionChart(),
                    const SizedBox(height: 24),
                    _buildDensityDistributionChart(),
                    const SizedBox(height: 24),
                    _buildSizeDistributionChart(),
                    const SizedBox(height: 24),
                    _buildMonthlyTrendChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _OverviewCard(
          title: '患者总数',
          value: _stats['patientCount']?.toString() ?? '0',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _OverviewCard(
          title: '活跃结节',
          value: _stats['activeNoduleCount']?.toString() ?? '0',
          icon: Icons.favorite,
          color: Colors.red,
        ),
        _OverviewCard(
          title: '高危结节',
          value: _nodules.where((n) => (n.malignancyProbability ?? 0) >= 65).length.toString(),
          icon: Icons.warning,
          color: Colors.red[700]!,
        ),
        _OverviewCard(
          title: '本月待随访',
          value: _stats['upcomingCount']?.toString() ?? '0',
          icon: Icons.calendar_today,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRiskDistributionChart() {
    final lowRisk = _nodules.where((n) => (n.malignancyProbability ?? 0) < 5).length;
    final moderateRisk = _nodules.where((n) {
      final p = n.malignancyProbability ?? 0;
      return p >= 5 && p < 65;
    }).length;
    final highRisk = _nodules.where((n) => (n.malignancyProbability ?? 0) >= 65).length;
    final unassessed = _nodules.where((n) => n.malignancyProbability == null).length;
    
    final total = _nodules.length;
    if (total == 0) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '风险等级分布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: lowRisk.toDouble(),
                      title: '低风险\n$lowRisk',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: moderateRisk.toDouble(),
                      title: '中风险\n$moderateRisk',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: highRisk.toDouble(),
                      title: '高风险\n$highRisk',
                      color: Colors.red,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unassessed > 0)
                      PieChartSectionData(
                        value: unassessed.toDouble(),
                        title: '未评估\n$unassessed',
                        color: Colors.grey,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('低风险', Colors.green),
                _buildLegend('中风险', Colors.orange),
                _buildLegend('高风险', Colors.red),
                if (unassessed > 0) _buildLegend('未评估', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDensityDistributionChart() {
    final solid = _nodules.where((n) => n.density == NoduleDensity.solid).length;
    final pGGN = _nodules.where((n) => n.density == NoduleDensity.pGGN).length;
    final mGGN = _nodules.where((n) => n.density == NoduleDensity.mGGN).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '结节密度分布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [solid, pGGN, mGGN].reduce((a, b) => a > b ? a : b).toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['实性', '纯磨玻璃', '混杂性'];
                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(titles[value.toInt()]),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: solid.toDouble(),
                          color: Colors.blue,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: pGGN.toDouble(),
                          color: Colors.teal,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: mGGN.toDouble(),
                          color: Colors.purple,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeDistributionChart() {
    final ranges = [
      {'label': '≤4mm', 'min': 0.0, 'max': 4.0},
      {'label': '4-6mm', 'min': 4.0, 'max': 6.0},
      {'label': '6-8mm', 'min': 6.0, 'max': 8.0},
      {'label': '8-15mm', 'min': 8.0, 'max': 15.0},
      {'label': '>15mm', 'min': 15.0, 'max': 999.0},
    ];

    final counts = ranges.map((range) {
      return _nodules.where((n) {
        return n.diameter >= (range['min'] as double) && 
               n.diameter < (range['max'] as double);
      }).length;
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '结节大小分布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: counts.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < ranges.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                ranges[value.toInt()]['label'] as String,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(ranges.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: counts[index].toDouble(),
                          color: Colors.indigo,
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendChart() {
    // 获取最近6个月的发现趋势
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      return DateTime(now.year, now.month - i, 1);
    }).reversed.toList();

    final counts = months.map((month) {
      return _nodules.where((n) {
        return n.discoveryDate.year == month.year && 
               n.discoveryDate.month == month.month;
      }).length;
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '近6个月发现趋势',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            final month = months[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${month.month}月',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(counts.length, (index) {
                        return FlSpot(index.toDouble(), counts[index].toDouble());
                      }),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}