import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    this.borderRadius,
    this.onTap,
    required this.child,
    Key? key}) : super(key: key);
  final BorderRadius? borderRadius;
  final Widget child;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
      highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
      borderRadius: borderRadius ?? BorderRadius.circular(100),
      onTap: onTap,
      child: child,
    );
  }
}