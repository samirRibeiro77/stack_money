enum LogLevel {
  debug('🐛'),
  info('💡'),
  warning('⚠️'),
  error('🚨');

  final String emoji;

  const LogLevel(this.emoji);

  String get level => '[${name.toUpperCase()}]';
}
