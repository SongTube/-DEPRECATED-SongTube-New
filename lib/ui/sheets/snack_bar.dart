import 'package:flutter/material.dart';
import 'package:songtube/main.dart';
import 'package:songtube/ui/sheet_phill.dart';
import 'package:songtube/ui/text_styles.dart';

void showSnackbar({required CustomSnackBar customSnackBar}) {
  ScaffoldMessenger.of(snackbarKey.currentContext!).showSnackBar(
    SnackBar(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: customSnackBar));
}

class CustomSnackBar extends StatelessWidget {
  const CustomSnackBar({
    required this.icon,
    required this.title,
    this.trailing,
    super.key});
  final IconData icon;
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20)
      ),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8).copyWith(left: 8, right: 8),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.center,
            child: BottomSheetPhill(color: Colors.white.withOpacity(0.6))),
          ListTile(
            contentPadding: const EdgeInsets.only(bottom: 0, left: 12, right: 12, top: 6),
            leading: Icon(icon, color: Colors.white),
            title: Text(title, style: textStyle(context, bold: true).copyWith(color: Colors.white.withOpacity(0.8), fontSize: 16)),
            trailing: trailing,
          ),
        ],
      ),
    );
  }
}