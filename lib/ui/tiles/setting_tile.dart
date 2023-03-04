import 'package:flutter/material.dart';
import 'package:songtube/ui/components/circular_check_box.dart';
import 'package:songtube/ui/text_styles.dart';

class SettingTileCheckbox extends StatelessWidget {
  const SettingTileCheckbox({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.value,
    required this.onChange,
    super.key});
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final bool value;
  final Function(bool) onChange;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onChange(!value),
      leading: SizedBox(
        height: double.infinity,
        child: Icon(leadingIcon, color: Theme.of(context).iconTheme.color),
      ),
      title: Text(title, style: subtitleTextStyle(context, bold: true)),
      subtitle: Text(subtitle, style: tinyTextStyle(context, opacity: 0.7)),
      trailing: CircularCheckbox(
        value: value,
        onChange: onChange
      ),
    );
  }
}

class SettingTileSlider extends StatefulWidget {
  const SettingTileSlider({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChange,
    this.valueTrailingString = '',
    super.key});
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final double value;
  final double min;
  final double max;
  final Function(double) onChange;
  final String valueTrailingString;
  @override
  State<SettingTileSlider> createState() => _SettingTileSliderState();
}

class _SettingTileSliderState extends State<SettingTileSlider> {

  // Drag placeholders
  double? dragValue;
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SizedBox(
            height: double.infinity,
            child: Icon(widget.leadingIcon, color: Theme.of(context).iconTheme.color),
          ),
          title: Text(widget.title, style: subtitleTextStyle(context, bold: true)),
          subtitle: Text(widget.subtitle, style: tinyTextStyle(context, opacity: 0.7)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _slider(),
        )
      ],
    );
  }

  Widget _slider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        valueIndicatorTextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
        trackHeight: 2,
      ),
      child: Row(
        children: [
          Text((dragValue ?? widget.value).round().toString()+widget.valueTrailingString, style: tinyTextStyle(context, opacity: 0.7)),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).cardColor.withOpacity(0.06),
              min: widget.min,
              max: widget.max,
              value: dragValue ?? widget.value,
              onChanged: (value) {
                if (!dragging) {
                  dragging = true;
                }
                setState(() {
                  dragValue = value;
                });
              },
              onChangeEnd: widget.onChange
            ),
          ),
          const SizedBox(width: 4),
          Text(widget.max.round().toString()+widget.valueTrailingString, style: tinyTextStyle(context, opacity: 0.7)),
        ],
      )
    );
  }

}