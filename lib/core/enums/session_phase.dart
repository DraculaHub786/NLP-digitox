// Copyright (c) 2026 NLP digitox

/// Where a shared session is in its lifecycle, as derived from the stored
/// `state` plus the *server* clock.
///
/// This is never persisted. The host writes exactly one thing when they tap
/// Start — a `state` of `running` and a `runStartAt` server timestamp — and every
/// device (including the host's own) derives the phase from it. That is what
/// keeps a session synchronised without streaming anything every second, and it
/// is why a phase cannot be read straight out of the database: two phones must
/// agree on "running" even when their own clocks disagree by minutes.
enum SessionPhase {
  /// Members are gathering and marking themselves ready.
  lobby,

  /// The host has started; the shared countdown is ticking down.
  countdown,

  /// The focus run is in progress.
  running,

  /// The run reached `endAt`.
  finished,

  /// The host cancelled before the run finished.
  cancelled;

  /// Whether the timer is actively counting down or down.
  bool get hasStarted =>
      this == SessionPhase.countdown ||
      this == SessionPhase.running ||
      this == SessionPhase.finished;

  /// Whether members should be blocking distractions right now.
  bool get shouldBlockApps => this == SessionPhase.running;

  /// Whether the session is over, either way.
  bool get isOver => this == SessionPhase.finished || this == SessionPhase.cancelled;

  /// The label shown on the session's status chip.
  String get label {
    switch (this) {
      case SessionPhase.lobby:
        return 'Lobby';
      case SessionPhase.countdown:
        return 'Starting';
      case SessionPhase.running:
        return 'Focusing';
      case SessionPhase.finished:
        return 'Finished';
      case SessionPhase.cancelled:
        return 'Cancelled';
    }
  }
}
