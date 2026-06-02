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


  int get _totalExpenses {
  return _expenses.fold(
    0,
    (sum, expense) =>
        sum + ((expense['exp_amount'] ?? 0) as int),
  );
}

  
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

@override
void initState() {
  super.initState();
  _loadExpenses();
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
      body: Padding(
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
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _summaryCard(
              "Monthly Expenses",
              _totalExpenses,
              Icons.money_off,
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
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              expense['exp_date']?.toString() ?? '',
            ),
            subtitle: Text(
              expense['exp_date']?.toString() ?? '',
            ),
            trailing: Text(
              "₹${expense['exp_amount'] ?? 0}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
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