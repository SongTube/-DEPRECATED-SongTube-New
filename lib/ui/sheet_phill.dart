import 'package:flutter/material.dart';

class BottomSheetPhill extends StatelessWidget {
  const BottomSheetPhill({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}