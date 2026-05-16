import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.getEvents();
      if (mounted) setState(() => _events = data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Color _statusColor(Map<String, dynamic> e) {
    final conf = e['evnt_conf_status'] as String? ?? '';
    final completed = e['evnt_compl_status'] == true;
    if (conf == 'not-confirmed') return AppColors.calUnconfirmed;
    if (completed) return AppColors.calCompleted;
    return AppColors.calUpcoming;
  }

  String _statusLabel(Map<String, dynamic> e) {
    final conf = e['evnt_conf_status'] as String? ?? '';
    final completed = e['evnt_compl_status'] == true;
    if (conf == 'not-confirmed') return 'Unconfirmed';
    if (completed) return 'Completed';
    return 'Upcoming';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      appBar: AppBar(
        title: const Text('All Events',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: _events.isEmpty
                  ? const Center(
                      child: Text('No events found.',
                          style: TextStyle(color: AppColors.textHint)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final e = _events[i];
                        final dateStr = e['evnt_date'] as String?;
                        final date =
                            dateStr != null ? DateTime.parse(dateStr) : null;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/event-details',
                              arguments: e['evnt_id']),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: _statusColor(e).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        date != null
                                            ? DateFormat('d').format(date)
                                            : '-',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: _statusColor(e),
                                          height: 1,
                                        ),
                                      ),
                                      Text(
                                        date != null
                                            ? DateFormat('MMM').format(date)
                                            : '',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _statusColor(e),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e['evnt_name'] ?? 'Unnamed',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        e['host_name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            _statusColor(e).withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _statusLabel(e),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _statusColor(e),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (e['amount'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹ ${e['amount']}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
