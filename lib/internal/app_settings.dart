import 'package:songtube/internal/ffmpeg/converter.dart';
import 'package:songtube/internal/global.dart';

const defaultFfmpegTaskKey = 'defaultFfmpegTask';

class AppSettings {

  // FFmpeg Default Task
  static FFmpegTask get defaultFfmpegTask {
    if (sharedPreferences.containsKey(defaultFfmpegTaskKey)) {
      final task = sharedPreferences.get(defaultFfmpegTaskKey);
      if (task == 'aac') {
        return FFmpegTask.convertToAAC;
      } else if (task == 'mp3') {
        return FFmpegTask.convertToMP3;
      } else if (task == 'ogg') {
        return FFmpegTask.convertToOGG;
      } else {
        return FFmpegTask.convertToAAC;
      }
    } else {
      return FFmpegTask.convertToAAC;
    }
  }
  static set defaultFfmpegTask(FFmpegTask task) {
    final format = task.toString().split('.').last.split('convertTo').last.toLowerCase();
    sharedPreferences.setString(defaultFfmpegTaskKey, format);
  }


}