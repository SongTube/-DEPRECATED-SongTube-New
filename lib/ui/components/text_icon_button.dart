import 'package:flutter/material.dart';
import 'package:songtube/ui/components/custom_inkwell.dart';
import 'package:songtube/ui/text_styles.dart';

class TextIconButton extends StatelessWidget {
  const TextIconButton({
    required this.icon,
    required this.text,
    this.onTap,
    this.selected,
    this.selectedIcon,
    super.key});
  final Icon icon;
  final String text;
  final Function()? onTap;
  final Icon? selectedIcon;
  final bool? selected;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 65,
      child: CustomInkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: (selected ?? false) ? selectedIcon ?? icon : icon),
            const SizedBox(height: 2),
            Text(text, style: tinyTextStyle(context))
          ],
        ),
      ),
    );
  }
}