import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:print_app/widgets/RowTransaction.dart';
import 'package:print_app/widgets/user_transaction.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotPage extends StatelessWidget {
  final String phoneNumber;
  final String amount;
  final bool freeOngkir;
  final String timestamp;
  ScreenshotPage(
      {super.key,
      required this.phoneNumber,
      required this.amount,
      required this.freeOngkir,
      required this.timestamp});

  // Controller untuk mengambil screenshot
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    int tax = 3000;

    String totalCost(String amount) {
      int amountValue = int.tryParse(amount) ?? 0;
      if (!freeOngkir) {
        amountValue = -tax;
      }
      return amountValue.toString();
    }

    // Fungsi untuk memformat angka menjadi format Rupiah
    String formatRp(String value) {
      int amountValue = int.tryParse(value) ?? 0;
      final formatter = NumberFormat.currency(
        locale: 'id_ID', // Bahasa Indonesia
        symbol: '', // Tidak menambahkan "Rp" otomatis
        decimalDigits: 2, // Dua angka desimal
      );
      return formatter.format(amountValue);
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  15,
                  MediaQuery.of(context).viewInsets.top + 30,
                  15,
                  0,
                ),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Image.asset(
                          'assets/wchicken.png',
                        ),
                      ),
                      const Text(
                        'Bukti Transaksi',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Rp',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              formatRp(amount),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        const UserTransaction(
                          username: 'Thermal App',
                          phoneNumber: '085604014480',
                          title: 'Dari',
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        UserTransaction(
                          username: 'Orang Lain',
                          phoneNumber: phoneNumber,
                          title: 'Ke',
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        RowTransaction(
                          leftText: 'Jumlah Transaksi',
                          rightText: 'Rp ${formatRp(amount)}',
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Biaya Transfer',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (freeOngkir)
                                const Row(
                                  children: [
                                    Text(
                                      'Rp 3.000',
                                      style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w500,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'GRATIS',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              if (!freeOngkir)
                                Text(
                                  formatRp(tax.toString()),
                                  style: const TextStyle(
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        RowTransaction(
                          leftText: 'Jumlah Total',
                          rightText: 'Rp ${formatRp(totalCost(amount))}',
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        const RowTransaction(
                          leftText: 'No. transaksi',
                          rightText: 'WC2006123456',
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        const RowTransaction(
                          leftText: 'Metode Transaksi',
                          rightText: 'Realtime Online',
                        ),
                        Divider(
                          color: Colors.grey[100],
                          thickness: 1,
                        ),
                        RowTransaction(
                          leftText: 'Waktu Transaksi',
                          rightText: timestamp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.indigo, 
                      backgroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), 
                        side: const BorderSide(
                          color: Colors.indigo, 
                          width: 1, 
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final image = await _screenshotController.capture();
                      if (image != null) {
                        final tempDir = Directory.systemTemp;
                        final file =
                            await File('${tempDir.path}/screenshot.png')
                                .create();
                        await file.writeAsBytes(image);

                        await Share.shareXFiles([XFile(file.path)],
                            text:
                                'Bukti transkaksi senilai: ${formatRp(amount)}');
                      }
                    },
                    child: const Text('Bagikan'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.indigo, 
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), 
                        side: const BorderSide(
                          color: Colors.indigo, 
                          width: 1, 
                        ),
                      ),
                    ),
                    onPressed: () => Get.back(closeOverlays: true),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
