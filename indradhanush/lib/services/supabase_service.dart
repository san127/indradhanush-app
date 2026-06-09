import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // events fetching
  static Future<List<Map<String, dynamic>>> getEvents() async{
    final response = await _client
    .from('events')
    .select()
    .order('evnt_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // add a new event to db
  static Future<String?> createEvent(Map<String, dynamic> data) async{
    final response = await _client
                    .from('events')
                    .insert(data)
                    .select('evnt_id')
                    .single();
  return response['evnt_id'] as String;
  }

  //fetch an event from eventID
  static Future<Map<String, dynamic>?> getEvent(String eventId) async {
    final response = await _client
        .from('events')
        .select()
        .eq('evnt_id', eventId)
        .single();
    return response;
  }

  //update event
  static Future<void> updateEvent(
      String eventId, Map<String, dynamic> data) async {
    await _client.from('events').update(data).eq('evnt_id', eventId);
  }

  //delete an event 
  static Future<void> deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('evnt_id', eventId);
  }

  // advance details table 
  static Future<Map<String,dynamic>?> getAdvanceDetails(String eventId) async{
    final response = await _client
        .from('advanceDetails')
        .select()
        .eq('event_id', eventId)
        .maybeSingle();
    return response;
  }

// create new row if no exist, else update existing
  static Future<void> upsertAdvanceDetails(Map<String, dynamic> data) async {
    await _client.from('advanceDetails').upsert(data);
  }

  // payments
  static Future<Map<String, dynamic>?> getPayment(String eventId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('event_id', eventId)
        .maybeSingle();
    return response;
  }

  static Future<void> upsertPayment(Map<String, dynamic> data) async {
    await _client.from('payments').upsert(data);
  }

  // income and stats
  static Future<List<Map<String, dynamic>>> getMonthlyIncome() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    final response = await _client
                    .from('events')
                    .select('evnt_date, amount')
                    .gte('evnt_date',sixMonthsAgo.toString().split(' ')[0])//del the tiem part of the date string
                    .order('evnt_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }



// method to check if dates are clashing
//  List <Map<String,dynamic>> _eventsForSelectedDate =[];

  static Future <List<Map<String, dynamic>>> checkEventsForDate(DateTime date) async {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _client
                              .from('events')
                              .select('evnt_name, evnt_startTime, evnt_endTime')
                              .eq('evnt_date', formattedDate);

    return List<Map<String, dynamic>>.from(response);
    // _eventsForSelectedDate = List<Map<String, dynamic>>.from(response);

    // if(_eventsForSelectedDate.isNotEmpty){
    //   final eventNames = _eventsForSelectedDate.map((event){
    //     return "${event['evnt_name']} " "(${event['evnt_startTime']} - ${event['evnt_endTime']})";
    //   }).join('\n');
    // }
  }

  static Stream<List<Map<String, dynamic>>> eventStream() {
  return _client
      .from('events')
      .stream(primaryKey: ['evnt_id']);
}

static Future<void> createExpense(
    Map<String, dynamic> data) async {
  await _client
      .from('Expenses')
      .insert(data);
}

  static Future<List<Map<String, dynamic>>> getExpensesForMonth(
    DateTime month) async {

  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);

  final response = await _client
      .from('Expenses')
      .select()
      .gte('exp_date', start.toIso8601String().split('T')[0])
      .lt('exp_date', end.toIso8601String().split('T')[0])
      .order('exp_date');

  return List<Map<String, dynamic>>.from(response);
}

static Future<int> getEstimatedRevenueForMonth(
    DateTime month) async {

  final start =
      DateTime(month.year, month.month, 1);

  final end =
      DateTime(month.year, month.month + 1, 1);

  final response = await _client
      .from('events')
      .select('amount')
      .gte(
        'evnt_date',
        start.toIso8601String().split('T')[0],
      )
      .lt(
        'evnt_date',
        end.toIso8601String().split('T')[0],
      );

  int total = 0;

  for (final row in response) {
    total += ((row['amount'] ?? 0) as num).toInt();
  }

  return total;
}


// static Future<List<Map<String, dynamic>>>
//     getAdvancesForMonth(DateTime month) async {

//   final start =
//       DateTime(month.year, month.month, 1);

//   final end =
//       DateTime(month.year, month.month + 1, 1);

//   final response = await _client
//       .from('advanceDetails')
//       .select(
//         'adv_amount, adv_mode, adv_paid_date',
//       )
//       .gte(
//         'adv_paid_date',
//         start.toIso8601String().split('T')[0],
//       )
//       .lt(
//         'adv_paid_date',
//         end.toIso8601String().split('T')[0],
//       );

//   return List<Map<String, dynamic>>.from(
//     response,
//   );
// }

static Future<List<Map<String, dynamic>>>
    getAdvancesForMonth(DateTime month) async {

  final start =
      DateTime(month.year, month.month, 1);

  final end =
      DateTime(month.year, month.month + 1, 1);

  final events = await _client
      .from('events')
      .select('evnt_id')
      .gte(
        'evnt_date',
        DateFormat('yyyy-MM-dd').format(start),
      )
      .lt(
        'evnt_date',
        DateFormat('yyyy-MM-dd').format(end),
      );

  if (events.isEmpty) {
    return [];
  }

  final eventIds = events
      .map((e) => e['evnt_id'])
      .toList();

  final advances = await _client
      .from('advanceDetails')
      .select(
        'adv_amount, adv_mode, adv_paid_date, event_id',
      )
      .inFilter(
        'event_id',
        eventIds,
      );

  print('advances = $advances');

  return List<Map<String, dynamic>>.from(
    advances,
  );
}

// static Future<List<Map<String, dynamic>>>
//     getPaymentsForMonth(DateTime month) async {

//   final start =
//       DateTime(month.year, month.month, 1);

//   final end =
//       DateTime(month.year, month.month + 1, 1);

//   final response = await _client
//       .from('payments')
//       .select(
//         'final_amount_paid, pay_mode, pay_date',
//       )
//       .gte(
//         'pay_date',
//         start.toIso8601String().split('T')[0],
//       )
//       .lt(
//         'pay_date',
//         end.toIso8601String().split('T')[0],
//       );

//       print('payments = $response');

//   return List<Map<String, dynamic>>.from(
//     response,
//   );
// }


static Future<List<Map<String, dynamic>>>
    getPaymentsForMonth(DateTime month) async {

  final start =
      DateTime(month.year, month.month, 1);

  final end =
      DateTime(month.year, month.month + 1, 1);

  final events = await _client
      .from('events')
      .select('evnt_id')
      .gte(
        'evnt_date',
        DateFormat('yyyy-MM-dd').format(start),
      )
      .lt(
        'evnt_date',
        DateFormat('yyyy-MM-dd').format(end),
      );

  if (events.isEmpty) {
    return [];
  }

  final eventIds = events
      .map((e) => e['evnt_id'])
      .toList();

  final payments = await _client
      .from('payments')
      .select(
        'final_amount_paid, pay_mode, pay_date, event_id',
      )
      .inFilter(
        'event_id',
        eventIds,
      );

  print('payments = $payments');

  return List<Map<String, dynamic>>.from(
    payments,
  );
}

static Future<int> getActualRevenueForMonth(
    DateTime month) async {

  final advances =
      await getAdvancesForMonth(month);

  final payments =
      await getPaymentsForMonth(month);

  int total = 0;

  for (final row in advances) {
    total +=
        ((row['adv_amount'] ?? 0) as num)
            .toInt();
  }

  for (final row in payments) {
    total += ((row['final_amount_paid'] ?? 0)
            as num)
        .toInt();
  }

  print('total adv + pay = $total');

  return total;
}

static Future<Map<String, int>>
    getRevenueBreakdownForMonth(
        DateTime month) async {

  final advances =
      await getAdvancesForMonth(month);

  final payments =
      await getPaymentsForMonth(month);

  int cash = 0;
  int upi = 0;
  int cheque = 0;
  int bankTransfer = 0;

  void addAmount(
    String? mode,
    int amount,
  ) {
    switch (mode?.toLowerCase()) {
      case 'cash':
        cash += amount;
        break;

      case 'upi':
        upi += amount;
        break;

      case 'cheque':
        cheque += amount;
        break;

      case 'bank_transfer':
        bankTransfer += amount;
        break;
    }
  }

  for (final row in advances) {
    addAmount(
      row['adv_mode']?.toString(),
      ((row['adv_amount'] ?? 0) as num)
          .toInt(),
    );
  }

  for (final row in payments) {
    addAmount(
      row['pay_mode']?.toString(),
      ((row['final_amount_paid'] ?? 0)
              as num)
          .toInt(),
    );
  }

  return {
    'cash': cash,
    'upi': upi,
    'cheque': cheque,
    'bank_transfer': bankTransfer,
  };
}

static Future<void> deleteExpense(
  int expenseId,
) async {
  await _client
      .from('Expenses')
      .delete()
      .eq('exp_id', expenseId);
}

static Future<void> updateExpense({
  required int expenseId,
  required String name,
  required int amount,
  required String paymentMode,
  required DateTime date,
}) async {
  await _client
      .from('Expenses')
      .update({
        'exp_name': name,
        'exp_amount': amount,
        'exp_pay_mode': paymentMode,
        'exp_date':
            DateFormat('yyyy-MM-dd')
                .format(date),
      })
      .eq('exp_id', expenseId);
}

//cash memo method
static Future<int> createCashMemo(
  Map<String, dynamic> memo,
) async {
  final result = await _client
      .from('cash_memos')
      .insert(memo)
      .select()
      .single();

  return result['memo_id'];
}

// adding cash memo items
static Future<void> addCashMemoItems(
  List<Map<String, dynamic>> items,
) async {
  await _client
      .from('cash_memo_items')
      .insert(items);
}


//fetch event specific cash memo
static Future<List<Map<String, dynamic>>>
    getCashMemosForEvent(
  String eventId,
) async {

  final response = await _client
      .from('cash_memos')
      .select()
      .eq('event_id', eventId)
      .order(
        'created_at',
        ascending: false,
      );

  return List<Map<String, dynamic>>
      .from(response);
}

static Future<String> generateMemoNumber(
  String eventId,
) async {

  final events = await _client
      .from('events')
      .select('evnt_id, evnt_date')
      .order(
        'evnt_date',
        ascending: true,
      );

  final eventList =
      List<Map<String, dynamic>>.from(events);

  final index = eventList.indexWhere(
    (e) => e['evnt_id'] == eventId,
  );

  if (index == -1) {
    throw Exception(
      'Event not found',
    );
  }

  final event = eventList[index];

  final date = DateTime.parse(
    event['evnt_date'],
  );

  final eventNumber =
      index + 1;

  return '${eventNumber.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.year.toString().substring(2)}';
}

static Future<Map<String, dynamic>?>
    getCashMemoForEvent(
  String eventId,
) async {

  final response = await _client
      .from('cash_memos')
      .select()
      .eq('event_id', eventId);

  if (response.isEmpty) {
    return null;
  }

  return response.first;
}

static Future<List<Map<String, dynamic>>>
    getCashMemoItems(
  int memoId,
) async {

  final response = await _client
      .from('cash_memo_items')
      .select()
      .eq('memo_id', memoId);

  return List<Map<String, dynamic>>
      .from(response);
}

static Future<void>
    updateCashMemo(
  int memoId,
  Map<String, dynamic> data,
) async {

  await _client
      .from('cash_memos')
      .update(data)
      .eq(
        'memo_id',
        memoId,
      );
}

static Future<void> deleteCashMemoItems(
  int memoId,
) async {

  await _client
      .from('cash_memo_items')
      .delete()
      .eq(
        'memo_id',
        memoId,
      );
}
}