import 'package:flutter/material.dart';

class UserTransaction extends StatelessWidget {
  final String phoneNumber;

  final String username;

  final String title;

  const UserTransaction({
    super.key,
    required this.phoneNumber,
    required this.username,
    required this.title,
  });

  String formatPhoneNumber(String phone) {
    if (phone.length > 4) {
      return '**********${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_circle_rounded,
                  size: 40,
                ),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            Text(
              'Nomor: ${formatPhoneNumber(phoneNumber)}',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
