import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart';
import '../models/lung_nodule.dart';
import '../utils/app_localizations.dart';
import '../utils/follow_up_plan_generator.dart';

class FollowUpCalendarScreen extends StatefulWidget {
  const FollowUpCalendarScreen({super.key});

  @override
  State<FollowUpCalendarScreen> createState() => _FollowUpCalendarScreenState();
}

class _FollowUpCalendarScreenState extends State<FollowUpCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<LungNodule> _allNodules = [];
  Map<DateTime, List<LungNodule>> _followUpMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  Future<void> _loadData() async {
    final nodules = await DatabaseHelper.instance.getAllActiveNodules();
    
    // 构建随访日期映射
    final Map<DateTime, List<LungNodule>> followUpMap = {};
    for (final nodule in nodules) {
      if (nodule.nextFollowUpDate != null) {
        final date = DateTime(
          nodule.nextFollowUpDate!.year,
          nodule.nextFollowUpDate!.month,
          nodule.nextFollowUpDate!.day,
        );
        if (!followUpMap.containsKey(date)) {
          followUpMap[date] = [];
        }
        followUpMap[date]!.add(nodule);
      }
    }
    
    setState(() {
      _allNodules = nodules;
      _followUpMap = followUpMap;
      _isLoading = false;
    });
  }

  List<LungNodule> _getNodulesForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _followUpMap[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.followUpCalendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const Divider(),
                Expanded(
                  child: _buildEventList(loc),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<LungNodule>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      eventLoader: _getNodulesForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
    );
  }

  Widget _buildEventList(AppLocalizations loc) {
    final nodules = _getNodulesForDay(_selectedDay!);
    
    if (nodules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedDay != null 
                  ? '${_selectedDay!.month}月${_selectedDay!.day}日 无随访安排'
                  : '请选择日期',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nodules.length,
      itemBuilder: (context, index) {
        final nodule = nodules[index];
        return _buildFollowUpCard(nodule, loc);
      },
    );
  }

  Widget _buildFollowUpCard(LungNodule nodule, AppLocalizations loc) {
    final daysUntil = nodule.nextFollowUpDate!.difference(DateTime.now()).inDays;
    final isOverdue = daysUntil < 0;
    final isToday = daysUntil == 0;
    final isSoon = daysUntil <= 7 && daysUntil > 0;
    
    Color statusColor;
    String statusText;
    
    if (isOverdue) {
      statusColor = Colors.red;
      statusText = '逾期 ${-daysUntil} 天';
    } else if (isToday) {
      statusColor = Colors.orange;
      statusText = '今天';
    } else if (isSoon) {
      statusColor = Colors.amber;
      statusText = '$daysUntil 天后';
    } else {
      statusColor = Colors.green;
      statusText = '$daysUntil 天后';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            isOverdue ? Icons.warning : Icons.event,
            color: statusColor,
          ),
        ),
        title: Text('结节 #${nodule.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${nodule.density.displayName} - ${nodule.lobe.displayName}'),
            Text(
              '${nodule.diameter}mm | ${_getRiskText(nodule)}',
              style: TextStyle(
                color: nodule.malignancyProbability != null 
                    ? (nodule.malignancyProbability! < 5 
                        ? Colors.green 
                        : nodule.malignancyProbability! < 65 
                            ? Colors.orange 
                            : Colors.red)
                    : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
        ),
        onTap: () {
          // TODO: Navigate to patient detail
        },
      ),
    );
  }

  String _getRiskText(LungNodule nodule) {
    if (nodule.malignancyProbability == null) return '未评估';
    return '${nodule.malignancyProbability!.toStringAsFixed(1)}% ${nodule.riskLevel ?? ''}';
  }
}