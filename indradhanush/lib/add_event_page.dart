import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  // Event fields
  final _eventNameCtrl = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _hostNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _confStatus = 'not-confirmed';
  bool _chairCover = false;
  bool _soundSystem = false;
  final _requirementsCtrl = TextEditingController();

  // Advance details
  bool _showAdvance = false;
  final _advAmountCtrl = TextEditingController();
  DateTime? _advDate;
  String? _advMode;
  final _advPaidByCtrl = TextEditingController();
  final _advPaidToCtrl = TextEditingController();
  final _advRefCtrl = TextEditingController();

  // Payment details
  bool _showPayment = false;
  final _payeeCtrl = TextEditingController();
  String? _payStatus;
  DateTime? _payDate;
  String? _payMode;
  TimeOfDay? _payTime;
  final _finalAmountCtrl = TextEditingController();

  final List<String> _payModes = ['cash', 'UPI', 'cheque', 'bank_transfer'];
  final List<String> _payStatuses = [
    'fully paid',
    'partially paid',
    'not-paid',
    'sponsored-free'
  ];
  final List<String> _advModes = ['cash', 'UPI', 'cheque', 'bank_transfer'];

  @override
  void dispose() {
    _eventNameCtrl.dispose();
    _hostNameCtrl.dispose();
    _phoneCtrl.dispose();
    _guestsCtrl.dispose();
    _amountCtrl.dispose();
    _requirementsCtrl.dispose();
    _advAmountCtrl.dispose();
    _advPaidByCtrl.dispose();
    _advPaidToCtrl.dispose();
    _advRefCtrl.dispose();
    _payeeCtrl.dispose();
    _finalAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime(ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  String _fmtDate(DateTime? d) =>
      d != null ? DateFormat('d MMM yyyy').format(d) : 'Select date';

  String _fmtTime(TimeOfDay? t) =>
      t != null ? t.format(context) : 'Select time';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
      _showSnack('Please select an event date');
      return;
    }
    setState(() => _saving = true);
    try {
      final eventData = {
        'evnt_name': _eventNameCtrl.text.trim(),
        'evnt_date': DateFormat('yyyy-MM-dd').format(_eventDate!),
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
        'evnt_compl_status': false,
      };

      final eventId = await SupabaseService.createEvent(eventData);

      if (eventId != null) {
        if (_showAdvance && _advAmountCtrl.text.isNotEmpty) {
          await SupabaseService.upsertAdvanceDetails({
            'event_id': eventId,
            'adv_amount': int.tryParse(_advAmountCtrl.text),
            'adv_paid_date': _advDate != null
                ? DateFormat('yyyy-MM-dd').format(_advDate!)
                : null,
            'adv_mode': _advMode,
            'adv_paid_by': _advPaidByCtrl.text.trim(),
            'adv_paid_to': _advPaidToCtrl.text.trim(),
            'adv_ref_no': _advRefCtrl.text.trim(),
          });
        }

        if (_showPayment && _payeeCtrl.text.isNotEmpty) {
          await SupabaseService.upsertPayment({
            'event_id': eventId,
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
          });
        }
      }

      if (mounted) {
        _showSnack('Event saved successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      appBar: AppBar(
        title: const Text(
          'Add New Event',
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Event Details'),
              _TextInput(
                  controller: _eventNameCtrl,
                  label: 'Event Name',
                  required: true),
              const SizedBox(height: 14),
              _DatePickerField(
                  label: 'Event Date',
                  value: _fmtDate(_eventDate),
                  onTap: () => _pickDate((d) => setState(() => _eventDate = d))),
              const SizedBox(height: 14),
              Row(
                children: [
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
                ],
              ),
              const SizedBox(height: 14),
              _TextInput(controller: _hostNameCtrl, label: 'Host Name'),
              const SizedBox(height: 14),
              _TextInput(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _TextInput(
                  controller: _guestsCtrl,
                  label: 'Number of Guests',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _TextInput(
                  controller: _amountCtrl,
                  label: 'Amount (₹)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              // Confirmation status
              _label('Confirmation Status'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RadioChip(
                    label: 'Confirmed',
                    selected: _confStatus == 'confirm',
                    onTap: () => setState(() => _confStatus = 'confirm'),
                  ),
                  const SizedBox(width: 12),
                  _RadioChip(
                    label: 'Not Confirmed',
                    selected: _confStatus == 'not-confirmed',
                    onTap: () =>
                        setState(() => _confStatus = 'not-confirmed'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Booleans
              _BoolField(
                  label: 'Chair Covers',
                  value: _chairCover,
                  onChanged: (v) => setState(() => _chairCover = v)),
              _BoolField(
                  label: 'Sound System',
                  value: _soundSystem,
                  onChanged: (v) => setState(() => _soundSystem = v)),
              const SizedBox(height: 14),
              TextFormField(
                controller: _requirementsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Requirements',
                    alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),

              // ── Advance payment ────────────────────────────────────────────
              _DropdownSection(
                title: 'Advance Payment Details',
                expanded: _showAdvance,
                onToggle: () =>
                    setState(() => _showAdvance = !_showAdvance),
                child: Column(
                  children: [
                    _TextInput(
                        controller: _advAmountCtrl,
                        label: 'Advance Amount (₹)',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _DatePickerField(
                        label: 'Payment Date',
                        value: _fmtDate(_advDate),
                        onTap: () =>
                            _pickDate((d) => setState(() => _advDate = d))),
                    const SizedBox(height: 12),
                    _DropdownInput<String>(
                      label: 'Payment Mode',
                      value: _advMode,
                      items: _advModes,
                      onChanged: (v) => setState(() => _advMode = v),
                    ),
                    const SizedBox(height: 12),
                    _TextInput(
                        controller: _advPaidByCtrl, label: 'Paid By'),
                    const SizedBox(height: 12),
                    _TextInput(
                        controller: _advPaidToCtrl, label: 'Paid To'),
                    const SizedBox(height: 12),
                    _TextInput(
                        controller: _advRefCtrl,
                        label: 'Payment Reference'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Payment details ─────────────────────────────────────────────
              _DropdownSection(
                title: 'Payment Details',
                expanded: _showPayment,
                onToggle: () =>
                    setState(() => _showPayment = !_showPayment),
                child: Column(
                  children: [
                    _TextInput(
                        controller: _payeeCtrl, label: 'Payee Name'),
                    const SizedBox(height: 12),
                    _DropdownInput<String>(
                      label: 'Payment Status',
                      value: _payStatus,
                      items: _payStatuses,
                      onChanged: (v) => setState(() => _payStatus = v),
                    ),
                    const SizedBox(height: 12),
                    _DatePickerField(
                        label: 'Payment Date',
                        value: _fmtDate(_payDate),
                        onTap: () =>
                            _pickDate((d) => setState(() => _payDate = d))),
                    const SizedBox(height: 12),
                    _DropdownInput<String>(
                      label: 'Payment Mode',
                      value: _payMode,
                      items: _payModes,
                      onChanged: (v) => setState(() => _payMode = v),
                    ),
                    const SizedBox(height: 12),
                    _TimePickerField(
                      label: 'Payment Time',
                      value: _fmtTime(_payTime),
                      onTap: () =>
                          _pickTime((t) => setState(() => _payTime = t)),
                    ),
                    const SizedBox(height: 12),
                    _TextInput(
                        controller: _finalAmountCtrl,
                        label: 'Final Amount Paid (₹)',
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Event'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary));
}

// ── Reusable form widgets ─────────────────────────────────────────────────────

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool required;

  const _TextInput({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }
}

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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
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
