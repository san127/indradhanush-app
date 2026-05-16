import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Map<String, dynamic>? _event;
  Map<String, dynamic>? _advance;
  Map<String, dynamic>? _payment;
  bool _loading = true;
  bool _hasChanges = false;
  bool _saving = false;

  // ── Controllers ─────────────────────────────────────────────────────────────
  final _eventNameCtrl = TextEditingController();
  final _hostNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _requirementsCtrl = TextEditingController();

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _confStatus = 'not-confirmed';
  bool _chairCover = false;
  bool _soundSystem = false;

  // Advance
  final _advAmountCtrl = TextEditingController();
  DateTime? _advDate;
  String? _advMode;
  final _advPaidByCtrl = TextEditingController();
  final _advPaidToCtrl = TextEditingController();
  final _advRefCtrl = TextEditingController();

  // Payment
  final _payeeCtrl = TextEditingController();
  String? _payStatus;
  DateTime? _payDate;
  String? _payMode;
  TimeOfDay? _payTime;
  final _finalAmountCtrl = TextEditingController();

  bool _showAdvance = false;
  bool _showPayment = false;

  final List<String> _payModes = ['cash', 'UPI', 'cheque', 'bank_transfer'];
  final List<String> _payStatuses = [
    'fully paid', 'partially paid', 'not-paid', 'sponsored-free'
  ];
  final List<String> _advModes = ['cash', 'UPI', 'cheque', 'bank_transfer'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        SupabaseService.getEvent(widget.eventId),
        SupabaseService.getAdvanceDetails(widget.eventId),
        SupabaseService.getPayment(widget.eventId),
      ]);
      _event = results[0] as Map<String, dynamic>?;
      _advance = results[1] as Map<String, dynamic>?;
      _payment = results[2] as Map<String, dynamic>?;
      _populateFields();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _populateFields() {
    if (_event == null) return;
    _eventNameCtrl.text = _event!['evnt_name'] ?? '';
    _hostNameCtrl.text = _event!['host_name'] ?? '';
    _phoneCtrl.text = _event!['host_phone'] ?? '';
    _guestsCtrl.text = _event!['no_of_guests'] ?? '';
    _amountCtrl.text = _event!['amount']?.toString() ?? '';
    _requirementsCtrl.text = _event!['requirements'] ?? '';
    _confStatus = _event!['evnt_conf_status'] ?? 'not-confirmed';
    _chairCover = _event!['chair_cover'] ?? false;
    _soundSystem = _event!['sound_system'] ?? false;

    if (_event!['evnt_date'] != null) {
      _eventDate = DateTime.parse(_event!['evnt_date']);
    }
    if (_event!['evnt_startTime'] != null) {
      _startTime = _parseTime(_event!['evnt_startTime']);
    }
    if (_event!['evnt_endTime'] != null) {
      _endTime = _parseTime(_event!['evnt_endTime']);
    }

    if (_advance != null) {
      _advAmountCtrl.text = _advance!['adv_amount']?.toString() ?? '';
      _advPaidByCtrl.text = _advance!['adv_paid_by'] ?? '';
      _advPaidToCtrl.text = _advance!['adv_paid_to'] ?? '';
      _advRefCtrl.text = _advance!['adv_ref_no'] ?? '';
      _advMode = _advance!['adv_mode'];
      if (_advance!['adv_paid_date'] != null) {
        _advDate = DateTime.parse(_advance!['adv_paid_date']);
      }
    }

    if (_payment != null) {
      _payeeCtrl.text = _payment!['pay_by'] ?? '';
      _payStatus = _payment!['pay_status'];
      _payMode = _payment!['pay_mode'];
      _finalAmountCtrl.text = _payment!['final_amount_paid']?.toString() ?? '';
      if (_payment!['pay_date'] != null) {
        _payDate = DateTime.parse(_payment!['pay_date']);
      }
      if (_payment!['pay_time'] != null) {
        _payTime = _parseTime(_payment!['pay_time']);
      }
    }
  }

  TimeOfDay? _parseTime(String? t) {
    if (t == null) return null;
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _pickDate(ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      onPicked(picked);
      _markChanged();
    }
  }

  Future<void> _pickTime(ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      onPicked(picked);
      _markChanged();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final eventData = {
        'evnt_name': _eventNameCtrl.text.trim(),
        'evnt_date': _eventDate != null
            ? DateFormat('yyyy-MM-dd').format(_eventDate!)
            : null,
        'evnt_startTime': _startTime != null
            ? '${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}:00'
            : null,
        'evnt_endTime': _endTime != null
            ? '${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}:00'
            : null,
        'host_name': _hostNameCtrl.text.trim(),
        'host_phone': _phoneCtrl.text.trim(),
        'no_of_guests': _guestsCtrl.text.trim(),
        'amount': int.tryParse(_amountCtrl.text) ?? 0,
        'evnt_conf_status': _confStatus,
        'chair_cover': _chairCover,
        'sound_system': _soundSystem,
        'requirements': _requirementsCtrl.text.trim(),
      };
      await SupabaseService.updateEvent(widget.eventId, eventData);

      if (_advAmountCtrl.text.isNotEmpty) {
        await SupabaseService.upsertAdvanceDetails({
          'event_id': widget.eventId,
          'adv_amount': int.tryParse(_advAmountCtrl.text),
          'adv_paid_date': _advDate != null
              ? DateFormat('yyyy-MM-dd').format(_advDate!)
              : null,
          'adv_mode': _advMode,
          'adv_paid_by': _advPaidByCtrl.text.trim(),
          'adv_paid_to': _advPaidToCtrl.text.trim(),
          'adv_ref_no': _advRefCtrl.text.trim(),
          if (_advance?['id'] != null) 'id': _advance!['id'],
        });
      }

      if (_payeeCtrl.text.isNotEmpty) {
        await SupabaseService.upsertPayment({
          'event_id': widget.eventId,
          'pay_by': _payeeCtrl.text.trim(),
          'pay_status': _payStatus,
          'pay_date': _payDate != null
              ? DateFormat('yyyy-MM-dd').format(_payDate!)
              : null,
          'pay_mode': _payMode,
          'pay_time': _payTime != null
              ? '${_payTime!.hour}:${_payTime!.minute.toString().padLeft(2, '0')}:00'
              : null,
          'final_amount_paid': int.tryParse(_finalAmountCtrl.text),
          if (_payment?['payment_id'] != null)
            'payment_id': _payment!['payment_id'],
        });
      }

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseService.deleteEvent(widget.eventId);
      if (mounted) Navigator.pop(context);
    }
  }

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('d MMM yyyy').format(d) : 'Select date';

  String _fmtTime(TimeOfDay? t) =>
      t != null ? t.format(context) : 'Select time';

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      appBar: AppBar(
        title: Text(
          _event?['evnt_name'] ?? 'Event Details',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _delete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('Delete', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EditableField(
                    label: 'Event Name',
                    controller: _eventNameCtrl,
                    onChanged: (_) => _markChanged(),
                  ),
                  const SizedBox(height: 14),
                  _DatePickerField(
                    label: 'Event Date',
                    value: _fmtDate(_eventDate),
                    onTap: () =>
                        _pickDate((d) => setState(() => _eventDate = d)),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: _TimePickerField(
                        label: 'Start Time',
                        value: _fmtTime(_startTime),
                        onTap: () => _pickTime(
                            (t) => setState(() => _startTime = t)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimePickerField(
                        label: 'End Time',
                        value: _fmtTime(_endTime),
                        onTap: () =>
                            _pickTime((t) => setState(() => _endTime = t)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  _EditableField(
                    label: 'Host Name',
                    controller: _hostNameCtrl,
                    onChanged: (_) => _markChanged(),
                  ),
                  const SizedBox(height: 14),
                  _EditableField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => _markChanged(),
                  ),
                  const SizedBox(height: 14),
                  _EditableField(
                    label: 'Number of Guests',
                    controller: _guestsCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _markChanged(),
                  ),
                  const SizedBox(height: 14),
                  _EditableField(
                    label: 'Amount (₹)',
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _markChanged(),
                  ),
                  const SizedBox(height: 16),

                  // Confirmation status
                  const Text('Confirmation Status',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _RadioChip(
                      label: 'Confirmed',
                      selected: _confStatus == 'confirm',
                      onTap: () {
                        setState(() => _confStatus = 'confirm');
                        _markChanged();
                      },
                    ),
                    const SizedBox(width: 12),
                    _RadioChip(
                      label: 'Not Confirmed',
                      selected: _confStatus == 'not-confirmed',
                      onTap: () {
                        setState(() => _confStatus = 'not-confirmed');
                        _markChanged();
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _BoolField(
                    label: 'Chair Covers',
                    value: _chairCover,
                    onChanged: (v) {
                      setState(() => _chairCover = v);
                      _markChanged();
                    },
                  ),
                  _BoolField(
                    label: 'Sound System',
                    value: _soundSystem,
                    onChanged: (v) {
                      setState(() => _soundSystem = v);
                      _markChanged();
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _requirementsCtrl,
                    maxLines: 3,
                    onChanged: (_) => _markChanged(),
                    decoration: const InputDecoration(
                        labelText: 'Requirements',
                        alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 24),

                  // ── Advance details ──────────────────────────────────────
                  _DropdownSection(
                    title: 'Advance Payment Details',
                    expanded: _showAdvance,
                    onToggle: () =>
                        setState(() => _showAdvance = !_showAdvance),
                    child: Column(children: [
                      _EditableField(
                        label: 'Advance Amount (₹)',
                        controller: _advAmountCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 12),
                      _DatePickerField(
                        label: 'Payment Date',
                        value: _fmtDate(_advDate),
                        onTap: () =>
                            _pickDate((d) => setState(() => _advDate = d)),
                      ),
                      const SizedBox(height: 12),
                      _DropdownInput<String>(
                        label: 'Payment Mode',
                        value: _advMode,
                        items: _advModes,
                        onChanged: (v) {
                          setState(() => _advMode = v);
                          _markChanged();
                        },
                      ),
                      const SizedBox(height: 12),
                      _EditableField(
                        label: 'Paid By',
                        controller: _advPaidByCtrl,
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 12),
                      _EditableField(
                        label: 'Paid To',
                        controller: _advPaidToCtrl,
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 12),
                      _EditableField(
                        label: 'Payment Reference',
                        controller: _advRefCtrl,
                        onChanged: (_) => _markChanged(),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Payment details ──────────────────────────────────────
                  _DropdownSection(
                    title: 'Payment Details',
                    expanded: _showPayment,
                    onToggle: () =>
                        setState(() => _showPayment = !_showPayment),
                    child: Column(children: [
                      _EditableField(
                        label: 'Payee Name',
                        controller: _payeeCtrl,
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 12),
                      _DropdownInput<String>(
                        label: 'Payment Status',
                        value: _payStatus,
                        items: _payStatuses,
                        onChanged: (v) {
                          setState(() => _payStatus = v);
                          _markChanged();
                        },
                      ),
                      const SizedBox(height: 12),
                      _DatePickerField(
                        label: 'Payment Date',
                        value: _fmtDate(_payDate),
                        onTap: () =>
                            _pickDate((d) => setState(() => _payDate = d)),
                      ),
                      const SizedBox(height: 12),
                      _DropdownInput<String>(
                        label: 'Payment Mode',
                        value: _payMode,
                        items: _payModes,
                        onChanged: (v) {
                          setState(() => _payMode = v);
                          _markChanged();
                        },
                      ),
                      const SizedBox(height: 12),
                      _TimePickerField(
                        label: 'Payment Time',
                        value: _fmtTime(_payTime),
                        onTap: () =>
                            _pickTime((t) => setState(() => _payTime = t)),
                      ),
                      const SizedBox(height: 12),
                      _EditableField(
                        label: 'Final Amount Paid (₹)',
                        controller: _finalAmountCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _markChanged(),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: (_hasChanges && !_saving) ? _save : null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.textHint,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ── Editable field with edit icon ─────────────────────────────────────────────

class _EditableField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _EditableField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            enabled: _editing,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              labelText: widget.label,
              filled: true,
              fillColor: _editing
                  ? AppColors.surfaceVariant
                  : AppColors.lavender.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _editing = !_editing),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _editing ? AppColors.primary : AppColors.lavender,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _editing ? Icons.check : Icons.edit_outlined,
              size: 16,
              color: _editing ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared form widgets (duplicated from add_event_page for independence) ─────

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w600)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimePickerField(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w600)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownInput<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownInput(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i.toString())))
          .toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    );
  }
}

class _RadioChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BoolField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BoolField(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _DropdownSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _DropdownSection(
      {required this.title,
      required this.expanded,
      required this.onToggle,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 15)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }
}
