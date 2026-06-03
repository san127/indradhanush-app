import 'package:flutter/material.dart';
import 'package:indradhanush/services/supabase_service.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class FinanceDashboardPage extends StatefulWidget {
  const FinanceDashboardPage({super.key});

  @override
  State<FinanceDashboardPage> createState() =>
      _FinanceDashboardPageState();
}

class _FinanceDashboardPageState
    extends State<FinanceDashboardPage> {
  DateTime _selectedMonth = DateTime.now();

  int _cashRevenue = 0;
  int _upiRevenue = 0;
  int _chequeRevenue = 0;
  int _bankTransferRevenue = 0;

  int _actualRevenue = 0;
int _estimatedRevenue = 0;


  int get _totalExpenses {
  return _expenses.fold(
    0,
    (sum, expense) =>
        sum + ((expense['exp_amount'] ?? 0) as int),
  );
}

    int get _profit =>
        _actualRevenue - _totalExpenses;

    int get _outstanding =>
        _estimatedRevenue - _actualRevenue;

  
  List<Map<String, dynamic>> _expenses = [];
  bool _loading = true;

  Future<void> _loadExpenses() async {
  setState(() => _loading = true);

  try {
    final expenses =
        await SupabaseService.getExpensesForMonth(
            _selectedMonth);

    if (mounted) {
      setState(() {
        _expenses = expenses;
      });
    }
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

Future<void> _loadRevenue() async {
  final estimated =
      await SupabaseService
          .getEstimatedRevenueForMonth(
              _selectedMonth);

  final actual =
      await SupabaseService
          .getActualRevenueForMonth(
              _selectedMonth);

  final breakdown =
      await SupabaseService
          .getRevenueBreakdownForMonth(
              _selectedMonth);

  if (!mounted) return;

  setState(() {
    _estimatedRevenue = estimated;
    _actualRevenue = actual;

    _cashRevenue =
        breakdown['cash'] ?? 0;

    _upiRevenue =
        breakdown['upi'] ?? 0;

    _chequeRevenue =
        breakdown['cheque'] ?? 0;

    _bankTransferRevenue =
        breakdown['bank_transfer'] ?? 0;
  });
}


Future<void> _deleteExpense(
    int expenseId) async {

  final confirm =
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                const Text('Delete Expense'),
            content: const Text(
              'Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                      context, false);
                },
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context, true);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

  if (confirm != true) return;

  await SupabaseService
      .deleteExpense(expenseId);

  _loadExpenses();
}


Future<void> _editExpense(
    Map<String, dynamic> expense) async {

  final nameController =
      TextEditingController(
    text: expense['exp_name'],
  );

  final amountController =
      TextEditingController(
    text:
        expense['exp_amount'].toString(),
  );

  String paymentMode =
      expense['exp_pay_mode'];

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title:
                const Text('Edit Expense'),

            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [

                  TextField(
                    controller:
                        nameController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Expense Name',
                    ),
                  ),

                  const SizedBox(
                      height: 12),

                  TextField(
                    controller:
                        amountController,
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Amount',
                    ),
                  ),

                  const SizedBox(
                      height: 12),

                  DropdownButtonFormField<
                      String>(
                    value: paymentMode,
                    items: const [
                      DropdownMenuItem(
                        value: 'Cash',
                        child:
                            Text('Cash'),
                      ),
                      DropdownMenuItem(
                        value: 'UPI',
                        child:
                            Text('UPI'),
                      ),
                      DropdownMenuItem(
                        value: 'Cheque',
                        child:
                            Text('Cheque'),
                      ),
                      DropdownMenuItem(
                        value:
                            'Bank Transfer',
                        child: Text(
                            'Bank Transfer'),
                      ),
                    ],
                    onChanged: (v) {
                      setStateDialog(() {
                        paymentMode = v!;
                      });
                    },
                  ),
                ],
              ),
            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(
                      context);
                },
                child:
                    const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () async {

                  await SupabaseService
                      .updateExpense(
                    expenseId:
                        expense['exp_id'],
                    name:
                        nameController.text,
                    amount:
                        int.parse(
                      amountController
                          .text,
                    ),
                    paymentMode:
                        paymentMode,
                    date:
                        DateTime.parse(
                      expense[
                          'exp_date'],
                    ),
                  );

                  Navigator.pop(
                      context);

                  _loadExpenses();
                },
                child:
                    const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}



Widget _summaryCard(
  String title,
  int amount,
  IconData icon,
) {
  
  return  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.border,
      ),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.lavender,
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "₹${NumberFormat('#,##0').format(amount)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _breakdownRow(
  String label,
  int amount,
) {
  return Padding(
    padding:
        const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          "₹${NumberFormat('#,##0').format(amount)}",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}


@override
void initState() {
  super.initState();
  _loadExpenses();
  _loadRevenue();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lavenderLight,
      appBar: AppBar(
        title: const Text(
          'Finance Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // Month Selector

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1,
                        );
                    });
                    _loadExpenses();  
                    _loadRevenue();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy')
                          .format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                    _loadExpenses();
                    _loadRevenue();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _summaryCard(
              "Estimated Revenue",
              _estimatedRevenue,
              Icons.receipt_long,
            ),

            _summaryCard(
              "Actual Revenue",
              _actualRevenue,
              Icons.payments,
            ),

            _summaryCard(
              "Net Profit",
              _profit,
              Icons.trending_up,
            ),

            _summaryCard(
              "Outstanding Due",
              _outstanding,
              Icons.warning_amber_rounded,
            ),

            _summaryCard(
              "Monthly Expenses",
              _totalExpenses,
              Icons.money_off,
            ),

                  Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "Revenue Breakdown",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            _breakdownRow(
              "Cash",
              _cashRevenue,
            ),

            _breakdownRow(
              "UPI",
              _upiRevenue,
            ),

            _breakdownRow(
              "Cheque",
              _chequeRevenue,
            ),

            _breakdownRow(
              "Bank Transfer",
              _bankTransferRevenue,
            ),
          ],
        ),
      ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Finance Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 12),

                  _loading
    ? const CircularProgressIndicator()
    : Column(
        children: _expenses.map((expense) {
          return Container(
  margin: const EdgeInsets.only(bottom: 8),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppColors.lavenderLight,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense['exp_name']?.toString() ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMM yyyy').format(
                DateTime.parse(expense['exp_date']),
              ),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
// mode of payment information
            Text(
              expense['exp_pay_mode']?.toString() ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

          ],
        ),
      ),
      Column(
  crossAxisAlignment:
      CrossAxisAlignment.end,
  children: [

    Text(
      "₹${expense['exp_amount']}",
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),

    const SizedBox(height: 6),

    Row(
  mainAxisSize: MainAxisSize.min,
  children: [

    InkWell(
      onTap: () {
        _editExpense(expense);
      },
      child: const Icon(
        Icons.edit_outlined,
      ),
    ),

    const SizedBox(width: 12),

    InkWell(
      onTap: () {
        _deleteExpense(
          expense['exp_id'],
        );
      },
      child: const Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
    ),
  ],
),
  ],
),
    ],
  ),
);
        }).toList(),
      )
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/expenses',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Add Expense",
              ),
            ),
          ],
        ),
      ),
    );
  }
}