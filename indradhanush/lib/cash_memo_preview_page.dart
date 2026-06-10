import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

class CashMemoPreviewPage extends StatefulWidget {
  final String soldTo;
  final String memoNumber;
  final String date;
  final List<Map<String, dynamic>> items;
  final int
  total; //final ScreenshotController _screenshotController = ScreenshotController();

  const CashMemoPreviewPage({
    super.key,
    required this.soldTo,
    required this.memoNumber,
    required this.date,
    required this.items,
    required this.total,
  });

  @override
  State<CashMemoPreviewPage> createState() => _CashMemoPreviewPageState();
}

class _CashMemoPreviewPageState extends State<CashMemoPreviewPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<File?> _captureImage() async {
    final image = await _screenshotController.capture();

    if (image == null) return null;

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/cashmemo_${widget.memoNumber}.png');

    await file.writeAsBytes(image);

    return file;
  }

  Future<void> _saveImage() async {
  try {

    final image =
        await _screenshotController.capture();

    if (image == null) return;

    print('Image bytes: ${image.length}');

    final result =
        await ImageGallerySaverPlus.saveImage(
      image,
      quality: 100,
      name:
          'cashmemo_${widget.memoNumber}',
    );

    print('Gallery result: $result');

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Saved to Gallery',
        ),
      ),
    );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _shareImage() async {
    try {
      final file = await _captureImage();

      if (file == null) return;

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Cash Memo ${widget.memoNumber}');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Memo Preview'),

        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            tooltip: 'Save Image',
            onPressed: _saveImage,
          ),

          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _shareImage,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Screenshot(
            controller: _screenshotController,
            child: Material(
              color: Colors.white,
              child: Container(
                width: 700,
                margin: const EdgeInsets.all(20),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 2),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

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

                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'No: ${widget.memoNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'Date: ${widget.date}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Text('Sold To: ${widget.soldTo}'),
                    ),

                    //const Divider(),

                    // const Row(
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         'Particulars',
                    //         style: TextStyle(fontWeight: FontWeight.w700),
                    //       ),
                    //     ),

                    //     Text(
                    //       'Amount',
                    //       style: TextStyle(fontWeight: FontWeight.w700),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 10),

                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(4),

                        1: FixedColumnWidth(80),
                      },

                      border: TableBorder.all(),

                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Particulars',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Amount',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        ...widget.items.map((item) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  item['particulars'],
                                  softWrap: true,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '₹${item['amount']}',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 10),

                    //const Divider(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Row(
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const Spacer(),

                          Text(
                            '₹${widget.total}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 150,
                        child: Column(children: [Divider(), Text('Signature')]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
