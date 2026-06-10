import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

class CashMemoPreviewPage extends StatelessWidget {

  final String soldTo;
  final String memoNumber;
  final String date;
  final List<Map<String, dynamic>> items;
  final int total;

  const CashMemoPreviewPage({
    super.key,
    required this.soldTo,
    required this.memoNumber,
    required this.date,
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Cash Memo Preview',
        ),
      ),

    body: SingleChildScrollView(
      padding:
      const EdgeInsets.all(20),
      child: Center(

        child: Container(

          width: 700,
          margin: const EdgeInsets.all(20),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  const Text(
                    'INDRADHANUSH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const Text(
                    'CASH MEMO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

              const SizedBox(
                height: 20,
              ),

              Row(
                children: [
                
                  Expanded(
                    child: Text(
                      'No: $memoNumber',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      'Date: $date',
                      textAlign:
                          TextAlign.right,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Text(
                  'Sold To: $soldTo',
                ),
              ),

              const Divider(),

              const Row(
                children: [

                  Expanded(
                    child: Text(
                      'Particulars',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Table(
                columnWidths: const {
                
                  0: FlexColumnWidth(4),

                  1: FixedColumnWidth(90),
                },

                border: TableBorder.all(),

                children: [
                
                  const TableRow(
                    children: [
                    
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Particulars',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Amount',
                          textAlign:
                              TextAlign.right,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  ...items.map((item) {
                  
                    return TableRow(
                      children: [
                      
                        Padding(
                          padding:
                              const EdgeInsets.all(
                                  8),
                          child: Text(
                            item['particulars'],
                            softWrap: true,
                          ),
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.all(
                                  8),
                          child: Text(
                            '₹${item['amount']}',
                            textAlign:
                                TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              const Divider(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                  
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '₹$total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              const Align(
                alignment:
                    Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                    
                      Divider(),

                      Text(
                        'Signature',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
  );
  }
}