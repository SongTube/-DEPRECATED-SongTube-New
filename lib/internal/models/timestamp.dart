// ignore_for_file: public_member_api_docs, sort_constructors_first
class Timestamp {

  final String text;
  final Duration duration;
  Timestamp({
    required this.text,
    required this.duration,
  });
  
  // Parse duration from String
  static Duration _parseDuration(String string) {
    final durationList = string.split(':');
    final Duration duration;
    if (durationList.length == 2) {
      final minutes = int.parse(durationList.first);
      final seconds = int.parse(durationList[1]);
      duration = Duration(minutes: minutes, seconds: seconds);
    } else {
      final hours = int.parse(durationList.first);
      final minutes = int.parse(durationList[1]);
      final seconds = int.parse(durationList[2]);
      duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return duration;
  }

  // Process comment to extract timestamps
  static List<dynamic> parseStringForTimestamps(String message) {
    final parsedStrings = <dynamic>[];
    // Split our message into separate words in a list
    final strings = message.split(' ');
    for (final item in strings) {
      // If this word contains ":", this might be a timestamp
      if (item.contains(':')) {
        // Some words might not be separated by a empty space but by a new line, in this case we need to split
        // our word again, count and save the new lines, then we check if we have a timestamp
        if (item.contains('\n')) {
          final newLineCount = '\n'.allMatches(item);
          final newLineItems = item.split('\n');
          String text = newLineItems.first;
          for (var _ in newLineCount) {
            text = '$text\n';
          }
          final durationText = newLineItems.last;
          parsedStrings.add(text);
          try {
            final duration = _parseDuration(durationText);
            parsedStrings.add(Timestamp(text: durationText, duration: duration));
          } catch (_) {
            parsedStrings.add(text);
          }
        } else {
          try {
            final duration = _parseDuration(item);
            parsedStrings.add(Timestamp(text: item, duration: duration));
          } catch (_) {
            parsedStrings.add(item);
          }
        }
      } else {
        parsedStrings.add(item);
      }
    }
    return parsedStrings;
  }

}
