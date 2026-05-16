import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
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
      final data = await SupabaseService.getMonthlyIncome();
      if (mounted) setState(() => _events = data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Build monthly buckets ──────────────────────────────────────────────────

  List<_MonthStat> _buildStats() {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - i, 1);
      return m;
    });

    return months.map((month) {
      final monthEvents = _events.where((e) {
        if (e['evnt_date'] == null) return false;
        final d = DateTime.parse(e['evnt_date']);
        return d.year == month.year && d.month == month.month;
      }).toList();

      final total = monthEvents.fold<int>(
          0, (sum, e) => sum + ((e['amount'] as int?) ?? 0));
      final eventCount = monthEvents.length;

      return _MonthStat(
        month: month,
        totalAmount: total,
        eventCount: eventCount,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _buildStats();
    final maxAmount =
        stats.isEmpty ? 1 : stats.map((s) => s.totalAmount).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      appBar: AppBar(
        title: const Text('Monthly Income',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLighter],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LAST 6 MONTHS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹ ${_fmt(stats.fold<int>(0, (s, e) => s + e.totalAmount))}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats.fold<int>(0, (s, e) => s + e.eventCount)} events total',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Monthly Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Month rows
                    ...stats.map((stat) => _MonthRow(
                          stat: stat,
                          maxAmount: maxAmount == 0 ? 1 : maxAmount,
                        )),
                  ],
                ),
              ),
            ),
    );
  }

  String _fmt(int amount) {
    final f = NumberFormat('#,##,##0');
    return f.format(amount);
  }
}

class _MonthStat {
  final DateTime month;
  final int totalAmount;
  final int eventCount;

  _MonthStat({
    required this.month,
    required this.totalAmount,
    required this.eventCount,
  });
}

class _MonthRow extends StatelessWidget {
  final _MonthStat stat;
  final int maxAmount;

  const _MonthRow({required this.stat, required this.maxAmount});

  String _fmt(int amount) {
    final f = NumberFormat('#,##,##0');
    return f.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount > 0 ? stat.totalAmount / maxAmount : 0.0;
    final isCurrentMonth = DateTime.now().month == stat.month.month &&
        DateTime.now().year == stat.month.year;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentMonth ? AppColors.primary : AppColors.border,
          width: isCurrentMonth ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(stat.month),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isCurrentMonth
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              if (isCurrentMonth) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${stat.eventCount} event${stat.eventCount != 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.toDouble(),
              backgroundColor: AppColors.lavender,
              color: isCurrentMonth ? AppColors.primary : AppColors.primaryLighter,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '₹ ${_fmt(stat.totalAmount)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
