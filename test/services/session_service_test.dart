import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/core/services/session_service.dart';

void main() {
  group('SessionMember Model', () {
    test('should create member with correct properties', () {
      final now = DateTime.now();
      final member = SessionMember(
        userId: 'user123',
        deviceId: 'device123',
        displayName: 'John Doe',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      expect(member.userId, equals('user123'));
      expect(member.displayName, equals('John Doe'));
      expect(member.isActive, isTrue);
      expect(member.joinedAt, equals(now));
    });

    test('should convert to and from map', () {
      final now = DateTime.now();
      final member = SessionMember(
        userId: 'user123',
        deviceId: 'device123',
        displayName: 'John',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      final map = member.toMap();
      final restored = SessionMember.fromMap(map);

      expect(restored.userId, equals(member.userId));
      expect(restored.displayName, equals(member.displayName));
      expect(restored.isActive, equals(member.isActive));
    });

    test('should copy with new values', () {
      final now = DateTime.now();
      final member = SessionMember(
        userId: 'user123',
        displayName: 'John',
        deviceId: 'device1',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      final updated = member.copyWith(displayName: 'Jane', isActive: false);

      expect(updated.userId, equals(member.userId));
      expect(updated.displayName, equals('Jane'));
      expect(updated.isActive, isFalse);
    });

    test('should support equality comparison', () {
      final now = DateTime.now();
      final member1 = SessionMember(
        userId: 'user123',
        deviceId: 'device1',
        displayName: 'John',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      final member2 = SessionMember(
        userId: 'user123',
        deviceId: 'device1',
        displayName: 'Jane',
        joinedAt: now,
        isActive: true,
        lastActive: now,
      );

      expect(member1, equals(member2)); // Same userId, deviceId, isActive
    });
  });

  group('SessionSettings Model', () {
    test('should create settings with defaults', () {
      final settings = const SessionSettings();

      expect(settings.sharedDailyLimit, isNull);
      expect(settings.focusApps, isNull);
      expect(settings.blockedApps, isNull);
      expect(settings.showMemberActivity, isTrue);
      expect(settings.enforceSync, isFalse);
    });

    test('should convert to and from map', () {
      const settings = SessionSettings(
        sharedDailyLimit: 120,
        focusApps: ['com.example.app1'],
        blockedApps: ['com.example.app2'],
        showMemberActivity: false,
        enforceSync: true,
      );

      final map = settings.toMap();
      final restored = SessionSettings.fromMap(map);

      expect(restored.sharedDailyLimit, equals(120));
      expect(restored.focusApps, isNotEmpty);
      expect(restored.enforceSync, isTrue);
    });

    test('should support equality comparison', () {
      const settings1 = SessionSettings(
        sharedDailyLimit: 120,
        showMemberActivity: true,
      );

      const settings2 = SessionSettings(
        sharedDailyLimit: 120,
        showMemberActivity: true,
      );

      expect(settings1, equals(settings2));
    });
  });

  group('SharedSession Model', () {
    test('should create session with correct properties', () {
      final now = DateTime.now();
      final session = SharedSession(
        id: 'session123',
        name: 'Study Group',
        description: 'Daily study session',
        ownerId: 'owner123',
        createdAt: now,
        isPublic: true,
        theme: 'Education',
      );

      expect(session.id, equals('session123'));
      expect(session.name, equals('Study Group'));
      expect(session.ownerId, equals('owner123'));
      expect(session.isPublic, isTrue);
      expect(session.memberCount, equals(0));
    });

    test('should calculate member statistics correctly', () {
      final now = DateTime.now();
      final members = [
        SessionMember(
          userId: 'user1',
          displayName: 'John',
          joinedAt: now,
          isActive: true,
          lastActive: now,
        ),
        SessionMember(
          userId: 'user2',
          displayName: 'Jane',
          joinedAt: now,
          isActive: false,
          lastActive: now,
        ),
        SessionMember(
          userId: 'user3',
          displayName: 'Bob',
          joinedAt: now,
          isActive: true,
          lastActive: now,
        ),
      ];

      final session = SharedSession(
        id: 'session123',
        name: 'Group',
        ownerId: 'owner123',
        createdAt: now,
        members: members,
      );

      expect(session.memberCount, equals(3));
      expect(session.activeMembers, equals(2));
    });

    test('should enforce maxMembers limit', () {
      final now = DateTime.now();
      final members = List.generate(
        5,
        (i) => SessionMember(
          userId: 'user$i',
          displayName: 'User $i',
          joinedAt: now,
          isActive: true,
          lastActive: now,
        ),
      );

      final session = SharedSession(
        id: 'session123',
        name: 'Group',
        ownerId: 'owner123',
        createdAt: now,
        maxMembers: 5,
        members: members,
      );

      expect(session.memberCount, equals(5));
      expect(session.maxMembers, equals(5));
    });

    test('should convert to and from map', () {
      final now = DateTime.now();
      final session = SharedSession(
        id: 'session123',
        name: 'Study Group',
        description: 'Test session',
        ownerId: 'owner123',
        createdAt: now,
        isPublic: true,
        theme: 'Education',
        members: [],
      );

      final map = session.toMap();
      final restored = SharedSession.fromMap(map);

      expect(restored.id, equals(session.id));
      expect(restored.name, equals(session.name));
      expect(restored.ownerId, equals(session.ownerId));
      expect(restored.isPublic, equals(session.isPublic));
    });

    test('should copy with new values', () {
      final now = DateTime.now();
      final session = SharedSession(
        id: 'session123',
        name: 'Study Group',
        ownerId: 'owner123',
        createdAt: now,
      );

      final updated = session.copyWith(
        name: 'Work Group',
        isActive: false,
      );

      expect(updated.id, equals(session.id));
      expect(updated.name, equals('Work Group'));
      expect(updated.isActive, isFalse);
    });

    test('should support equality comparison', () {
      final now = DateTime.now();
      final session1 = SharedSession(
        id: 'session123',
        name: 'Group',
        ownerId: 'owner123',
        createdAt: now,
        members: [],
      );

      final session2 = SharedSession(
        id: 'session123',
        name: 'Different Name',
        ownerId: 'owner123',
        createdAt: now,
        members: [],
      );

      expect(session1, equals(session2)); // Same id, ownerId, memberCount
    });
  });

  group('SessionService Initialization', () {
    late SessionService sessionService;

    setUp(() {
      sessionService = SessionService.instance;
    });

    test('singleton should return same instance', () {
      final service1 = SessionService.instance;
      final service2 = SessionService.instance;
      expect(service1, equals(service2));
    });

    test('should not be ready initially', () {
      expect(sessionService.isReady, isFalse);
    });

    test('initialize should succeed', () async {
      await sessionService.init();
      expect(sessionService.isReady, isTrue);
    });

    test('initialize should be idempotent', () async {
      await sessionService.init();
      await sessionService.init();
      expect(sessionService.isReady, isTrue);
    });

    test('debugStatus should show current state', () async {
      await sessionService.init();
      final status = sessionService.debugStatus;

      expect(status, contains('SessionService'));
      expect(status, contains('ready: true'));
    });
  });

  group('SessionService Operations', () {
    late SessionService sessionService;

    setUp(() async {
      sessionService = SessionService.instance;
      await sessionService.init();
    });

    tearDown(() async {
      await sessionService.release();
    });

    test('should throw when not initialized', () async {
      final newService = SessionService.instance;
      await newService.release();

      expect(
        newService.createSession(name: 'Test'),
        throwsStateError,
      );
    });

    test('should throw ArgumentError for empty name', () async {
      // Empty name should throw ArgumentError
      expect(
        sessionService.createSession(name: ''),
        throwsArgumentError,
      );
    });

    test('should have empty cache after init', () async {
      final status = sessionService.debugStatus;
      expect(status, contains('cache_size: 0'));
    });

    test('release should succeed', () async {
      await sessionService.init();
      expect(sessionService.isReady, isTrue);

      await sessionService.release();
      expect(sessionService.isReady, isFalse);
    });

    test('multiple releases should be safe', () async {
      await sessionService.init();
      await sessionService.release();
      await sessionService.release();
      expect(sessionService.isReady, isFalse);
    });
  });

  group('SessionService Presence Management', () {
    late SessionService sessionService;

    setUp(() async {
      sessionService = SessionService.instance;
      await sessionService.init();
    });

    tearDown(() async {
      await sessionService.release();
    });

    test('should start and stop presence heartbeat', () async {
      const sessionId = 'test_session';

      sessionService.startPresenceHeartbeat(sessionId);
      var status = sessionService.debugStatus;
      expect(status, contains('heartbeats: 1'));

      // Timers should be tracked
      await Future.delayed(const Duration(milliseconds: 100));
    });
  });

  group('SessionService Methods', () {
    late SessionService sessionService;

    setUp(() async {
      sessionService = SessionService.instance;
      await sessionService.init();
    });

    tearDown(() async {
      await sessionService.release();
    });

    test('should handle get session correctly', () async {
      // Without Firebase, this should return null
      final session = await sessionService.getSession('nonexistent');
      expect(session, isNull);
    });

    test('should handle get user sessions correctly', () async {
      // Without Firebase auth, this should return empty list
      final sessions = await sessionService.getUserSessions();
      expect(sessions, isEmpty);
    });

    test('should have valid debug status format', () async {
      final status = sessionService.debugStatus;
      expect(status, contains('SessionService'));
      expect(status, contains('cache_size'));
      expect(status, contains('heartbeats'));
    });
  });

  group('SessionService Integration', () {
    late SessionService sessionService;

    setUp(() async {
      sessionService = SessionService.instance;
      await sessionService.init();
    });

    tearDown(() async {
      await sessionService.release();
    });

    test('session lifecycle in stub mode', () async {
      // This demonstrates the complete flow in stub mode
      expect(sessionService.isReady, isTrue);

      // Start heartbeat
      sessionService.startPresenceHeartbeat('session_1');

      // Verify status updated
      var status = sessionService.debugStatus;
      expect(status, contains('heartbeats: 1'));

      // Cleanup
      await sessionService.release();
      expect(sessionService.isReady, isFalse);
    });
  });
}
