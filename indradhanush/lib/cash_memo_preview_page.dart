import 'package:flutter/material.dart';

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

      body: Center(

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

              const Center(
                child: Text(
                  'CASH MEMO',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                'No : $memoNumber',
              ),

              Text(
                'Date : $date',
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Sold To : $soldTo',
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

              ...items.map((item) {

                return Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 8,
                  ),

                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          item[
                              'particulars'],
                        ),
                      ),

                      Text(
                        '₹${item['amount']}',
                      ),
                    ],
                  ),
                );
              }),

              const Divider(),

              Align(
                alignment:
                    Alignment.centerRight,

                child: Text(
                  'Total : ₹$total',

                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const Spacer(),

              const Align(
                alignment:
                    Alignment.centerRight,

                child: Column(
                  children: [

                    SizedBox(
                      height: 50,
                    ),

                    Text(
                      'Signature',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}