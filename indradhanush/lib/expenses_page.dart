import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _formKey = GlobalKey<FormState>();

  final _expenseNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  DateTime? _expenseDate;
  String? _paymentMode;

  bool _saving = false;

  final List<String> _paymentModes = [
    'cash',
    'UPI',
    'cheque',
    'bank_transfer'
  ];

  @override
  void dispose() {
    _expenseNameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  String _fmtDate() {
    if (_expenseDate == null) return 'Select date';
    return DateFormat('d MMM yyyy').format(_expenseDate!);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expenseDate == null) {
      _showSnack('Please select expense date');
      return;
    }

    if (_paymentMode == null) {
      _showSnack('Please select payment mode');
      return;
    }

    setState(() => _saving = true);

    try {
      await SupabaseService.createExpense({
        'exp_name': _expenseNameCtrl.text.trim(),
        'exp_amount': int.parse(_amountCtrl.text),
        'exp_pay_mode': _paymentMode,
        'exp_date':
            DateFormat('yyyy-MM-dd').format(_expenseDate!),
      });

      if (mounted) {
        _showSnack('Expense added');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const Text(
                'Expense Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _expenseNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                ),
                validator: (v) =>
                    v == null || v.isEmpty
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty
                        ? 'Required'
                        : null,
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                ),
                items: _paymentModes
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _paymentMode = v;
                  });
                },
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(_fmtDate()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed:
                    _saving ? null : _saveExpense,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Expense',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}