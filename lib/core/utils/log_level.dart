enum LogLevel {
  debug('🐛'),
  info('💡'),
  warning('⚠️'),
  error('🚨');

  final String _emoji;

  const LogLevel(this._emoji);

  String get message => '$_emoji [${name.toUpperCase()}]';
}
