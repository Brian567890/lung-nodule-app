import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/follow_up_record.dart';
import '../utils/app_localizations.dart';

class FollowUpHistoryDialog extends StatelessWidget {
  final String noduleId;

  const FollowUpHistoryDialog({
    super.key,
    required this.noduleId,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(loc.followUpHistory),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<FollowUpRecord>>(
                future: DatabaseHelper.instance.getFollowUpRecordsByNodule(noduleId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final records = snapshot.data ?? [];
                  
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '暂无随访记录',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _buildRecordCard(record, loc, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(FollowUpRecord record, AppLocalizations loc, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: record.isSuspicious ? Colors.red[100] : Colors.green[100],
          child: Icon(
            record.isSuspicious ? Icons.warning : Icons.check,
            color: record.isSuspicious ? Colors.red : Colors.green,
          ),
        ),
        title: Text(_formatDate(record.checkDate)),
        subtitle: Text('${record.diameter}mm | ${record.checkMethod}'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (record.previousDiameter != null) ...[
                  _buildInfoRow('上次直径', '${record.previousDiameter}mm'),
                  _buildInfoRow('直径变化', '${record.diameterChange?.toStringAsFixed(1) ?? '0'}mm'),
                ],
                _buildInfoRow('检查方法', record.checkMethod),
                if (record.hospitalName != null)
                  _buildInfoRow('检查医院', record.hospitalName!),
                if (record.doctorName != null)
                  _buildInfoRow('检查医生', record.doctorName!),
                const SizedBox(height: 8),
                if (record.hasEnlargement)
                  _buildWarningChip('结节增大', Colors.red),
                if (record.hasNewSolidComponent)
                  _buildWarningChip('新增实性成分', Colors.orange),
                if (record.hasSolidComponentIncrease)
                  _buildWarningChip('实性成分增加', Colors.orange),
                if (record.isSuspicious)
                  _buildWarningChip('可疑恶性征象', Colors.red),
                if (record.assessment != null) ...[
                  const SizedBox(height: 8),
                  Text('评估结论:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(record.assessment!),
                ],
                if (record.doctorAdvice != null) ...[
                  const SizedBox(height: 8),
                  Text('医生建议:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(record.doctorAdvice!),
                ],
                if (record.nextFollowUpDate != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('建议下次随访', _formatDate(record.nextFollowUpDate!)),
                ],
                if (record.notes != null) ...[
                  const SizedBox(height: 8),
                  Text('备注:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(record.notes!, style: TextStyle(color: Colors.grey[600])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}