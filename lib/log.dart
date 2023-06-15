import 'package:logger/logger.dart';

Logger get logger => Log.instance;

class Log extends Logger {
  Log._()
      : super(
          printer: PrettyPrinter(
            printTime: true,
            excludeBox: {
              Level.nothing: true,
              Level.verbose: true,
              Level.debug: true,
              Level.info: true,
              Level.warning: true,
              Level.error: false,
              Level.wtf: false,
            },
            methodCount: 0,
          ),
        );
  static final instance = Log._();
}
