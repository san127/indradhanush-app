import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;
  DateTime _focusedMonth = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }


  Future <void> _loadEvents() async{
    setState(() => _loading=true);
    try{
      final events = await SupabaseService.getEvents();
      if(mounted) setState(() => _events = events);
    } catch(_){}
    if (mounted) setState(()=> _loading=false);
  }



  Map<String, dynamic>? get _nextEvent {
    final now = DateTime.now();
    final upcoming = _events.where((e) {
      final d = e['evnt_date'];
      if (d == null) return false;
      final date = DateTime.parse(d);
      return date.isAfter(now) || _isSameDay(date, now);
    }).toList()

    // .. cascade operator 
      ..sort((a, b) =>
          DateTime.parse(a['evnt_date']).compareTo(DateTime.parse(b['evnt_date'])));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  List<Map<String, dynamic>> get _upcomingEvents {
    final now = DateTime.now();
    return _events
        .where((e) {
          final d = e['evnt_date'];
          if (d == null) return false;
          return DateTime.parse(d).isAfter(now);
        })
        .toList()
      ..sort((a, b) =>
          DateTime.parse(a['evnt_date']).compareTo(DateTime.parse(b['evnt_date'])));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _cellColor(Map<String, dynamic> e) {
    final conf = e['evnt_conf_status'] as String? ?? '';
    final completed = e['evnt_compl_status'] == true;
    if (conf == 'not-confirmed') return AppColors.calUnconfirmed;
    if (completed) {
      // check payment
      return AppColors.calCompleted; // refined via payment query if needed
    }
    return AppColors.calUpcoming;
  }

  Map<String, dynamic>? _eventForDay(DateTime day) {
    try {
      return _events.firstWhere(
          (e) => e['evnt_date'] != null && _isSameDay(DateTime.parse(e['evnt_date']), day));
    } catch (_) {
      return null;
    }
  }

  // ── navigation ───────────────────────────────────────────────────────────────

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    if (index == 1) Navigator.pushNamed(context, '/expenses');
    if (index == 2) Navigator.pushNamed(context, '/income');
    // index 0 stays on home (all events)
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final next = _nextEvent;

    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: _loadEvents,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Today's date ──────────────────────────────────────
                      Text(
                        DateFormat('EEEE').format(now),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        DateFormat('d MMMM yyyy').format(now),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Next upcoming event ───────────────────────────────
                      if (next != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLighter
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NEXT UPCOMING EVENT',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                next['evnt_name'] ?? '—',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 13, color: Colors.white70),
                                  const SizedBox(width: 5),
                                  Text(
                                    DateFormat('d MMM yyyy')
                                        .format(DateTime.parse(next['evnt_date'])),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                  if (next['evnt_startTime'] != null) ...[
                                    const SizedBox(width: 12),
                                    const Icon(Icons.access_time_outlined,
                                        size: 13, color: Colors.white70),
                                    const SizedBox(width: 5),
                                    Text(
                                      _formatTime(next['evnt_startTime']),
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _daysLeft(next['evnt_date']),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Calendar ──────────────────────────────────────────
                      _CalendarWidget(
                        events: _events,
                        focusedMonth: _focusedMonth,
                        onMonthChanged: (d) =>
                            setState(() => _focusedMonth = d),
                        cellColor: _cellColor,
                        eventForDay: _eventForDay,
                        onDayTap: (event) {
                          Navigator.pushNamed(context, '/event-details',
                              arguments: event['evnt_id']);
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Add event button ──────────────────────────────────
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/add-event');
                          _loadEvents();
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Add a New Event'),
                      ),
                      const SizedBox(height: 28),

                      // ── Upcoming events list ──────────────────────────────
                      const Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_upcomingEvents.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No upcoming events',
                              style: TextStyle(color: AppColors.textHint),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _upcomingEvents.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final e = _upcomingEvents[i];
                            return _EventListTile(
                              event: e,
                              onTap: () => Navigator.pushNamed(
                                  context, '/event-details',
                                  arguments: e['evnt_id']),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'All Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Monthly Income',
          ),
        ],
      ),
    );
  }

  String _formatTime(String? t) {
    if (t == null) return '';
    try {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final dt = DateTime(0, 0, 0, h, m);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return t;
    }
  }

  String _daysLeft(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.parse(dateStr);
    final today = DateTime.now();
    final diff = date.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff == 0) return 'Today!';
    if (diff == 1) return 'Tomorrow';
    return '$diff days left';
  }
}

class _CalendarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final Color Function(Map<String, dynamic>) cellColor;
  final Map<String, dynamic>? Function(DateTime) eventForDay;
  final ValueChanged<Map<String, dynamic>> onDayTap;

  const _CalendarWidget({
    required this.events,
    required this.focusedMonth,
    required this.onMonthChanged,
    required this.cellColor,
    required this.eventForDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1)),
              ),
              Text(
                DateFormat('MMMM yyyy').format(focusedMonth),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day labels
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          // Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();
              final day = index - startWeekday + 1;
              final date =
                  DateTime(focusedMonth.year, focusedMonth.month, day);
              final event = eventForDay(date);
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: event != null ? () => onDayTap(event) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: event != null
                        ? cellColor(event).withOpacity(0.85)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: event != null || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: event != null
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendItem(color: AppColors.calCompleted, label: 'Completed'),
              _LegendItem(color: AppColors.calUpcoming, label: 'Upcoming'),
              _LegendItem(color: AppColors.calUnpaid, label: 'Unpaid'),
              _LegendItem(color: AppColors.calUnconfirmed, label: 'Unconfirmed'),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Event list tile ──────────────────────────────────────────────────────────

class _EventListTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const _EventListTile({required this.event, required this.onTap});

  String _formatTime(String? t) {
    if (t == null) return '';
    try {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateFormat('h:mm a').format(DateTime(0, 0, 0, h, m));
    } catch (_) {
      return t;
    }
  }
@override
  Widget build(BuildContext context) {
    final dateStr = event['evnt_date'] as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date != null ? DateFormat('d').format(date) : '-',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  Text(
                    date != null ? DateFormat('MMM').format(date) : '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['evnt_name'] ?? 'Unnamed Event',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(event['evnt_startTime']),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}