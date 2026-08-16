abstract class Clock {
  DateTime now();

  int nowEpochMs() => now().millisecondsSinceEpoch;
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  int nowEpochMs() => now().millisecondsSinceEpoch;
}
