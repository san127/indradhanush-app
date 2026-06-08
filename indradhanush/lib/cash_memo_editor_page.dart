import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../theme.dart';

class _MemoItem {

  final TextEditingController
      particularsCtrl;

  final TextEditingController
      amountCtrl;

  _MemoItem({
    String particulars = '',
    String amount = '',
  })  : particularsCtrl =
            TextEditingController(
                text: particulars),
        amountCtrl =
            TextEditingController(
                text: amount);
}

class CashMemoEditorPage extends StatefulWidget {
  final String? eventId;

  const CashMemoEditorPage({
    super.key,
    this.eventId,
  });

  @override
  State<CashMemoEditorPage> createState() =>
      _CashMemoEditorPageState();
}

class _CashMemoEditorPageState extends State<CashMemoEditorPage> {

  final _soldToCtrl = TextEditingController();
  final _memoNumberCtrl = TextEditingController();
  DateTime _memoDate = DateTime.now();
  Map<String, dynamic>? _event;
  List<_MemoItem> _items = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _items.add(
      _MemoItem(),
    );

    _loadEvent();
  }

  Future<void> _saveMemo() async {
    setState(() => _saving = true);

  try {
    final memoId =
        await SupabaseService.createCashMemo({
             'event_id': widget.eventId,
             'memo_number': _memoNumberCtrl.text,
             'sold_to': _soldToCtrl.text,
             'memo_date': DateFormat(
                   'yyyy-MM-dd',
                 ).format(_memoDate),
    });

    await SupabaseService.addCashMemoItems( _items.map((item) {

        return {
          'memo_id': memoId,
          'particulars':  item.particularsCtrl.text,
          'amount': int.tryParse(
                item.amountCtrl.text,
              ) ??
              0,
        };

      }).toList(),
    );

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Cash Memo Saved'),
        ),
      );

      Navigator.pop(context);
    }

  } catch (e) {

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
        ),
      );
    }

  } finally {

    if (mounted) {
      setState(
        () => _saving = false,
      );
    }
  } 
}

Future<void> _loadEvent() async {

  if (widget.eventId == null) return;

  try {

    final event =
        await SupabaseService.getEvent(widget.eventId!);
        if (event == null) return;

    final memoNumber =
        await SupabaseService.generateMemoNumber(widget.eventId!);

    if (!mounted) return;

    setState(() {

      _event = event;

      _soldToCtrl.text =
          event['host_name'] ?? '';

      _memoNumberCtrl.text =
          memoNumber;

      _items = [
        _MemoItem(
          particulars: event['evnt_name'] ?? '',
          amount: '${event['amount'] ?? 0}',
        ),
      ];
    });

  } catch (e) {
    print(e);
  }

}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title:
          const Text('Cash Memo'),
    ),
    body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [

      TextField(
        controller: _soldToCtrl,
        decoration: const InputDecoration(
          labelText: 'Sold To',
        ),
      ),

      const SizedBox(height: 12),

      TextField(
        controller: _memoNumberCtrl,
        decoration: const InputDecoration(
          labelText: 'Memo Number',
        ),
      ),

      const SizedBox(height: 20),

      Expanded(
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {

            final item = _items[index];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [

                    TextField(
                      controller:
                          item.particularsCtrl,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Particulars',
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller:
                          item.amountCtrl,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Amount',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _items.add(
              _MemoItem(),
            );
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Row'),
      ),

      const SizedBox(height: 12),

      ElevatedButton(
        onPressed:
            _saving ? null : _saveMemo,
        child: Text(
          _saving
              ? 'Saving...'
              : 'Save Memo',
        ),
      ),
    ],
  ),
),
  );
}
}
