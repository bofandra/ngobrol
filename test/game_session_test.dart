import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ngobrol/backend.dart';
import 'package:ngobrol/game.dart';

class _Backend implements DiscussionBackend {
  final reads = <(String, Completer<List<SharedPost>>)>[];
  final writes = <(String, String, String, Completer<SharedPost>)>[];

  @override
  Future<SharedPost> add(String topic, String kind, String body) {
    final response = Completer<SharedPost>();
    writes.add((topic, kind, body, response));
    return response.future;
  }

  @override
  Future<List<SharedPost>> posts(String topic) {
    final response = Completer<List<SharedPost>>();
    reads.add((topic, response));
    return response.future;
  }
}

void main() {
  test('Show acknowledged posts immediately and reconcile by ID', () async {
    final backend = _Backend();
    final session = GameSession(backend);
    addTearDown(session.dispose);
    final topic = session.topics.first;
    final originalRefresh = session.refresh(topic);

    final send = session.send(topic, 'A rising tide changes the shoreline.');
    await session.send(topic, 'Tap again');
    expect(backend.writes.length, 1);

    final post = SharedPost(
      id: 'server-id',
      body: backend.writes.single.$3,
      kind: 'Question',
      isMine: true,
      createdAt: DateTime.utc(2026, 11, 28),
    );
    backend.writes.single.$4.complete(post);
    await send;
    expect(topic.feed.where((entry) => entry.body == post.body).length, 1);
    expect(
      topic.feed.singleWhere((entry) => entry.body == post.body).author,
      'You',
    );
    expect(session.xp, 5);

    backend.reads.first.$2.completeError(StateError('stale refresh failed'));
    await originalRefresh;
    expect(topic.refreshError, isNull);
    backend.reads.last.$2.complete([]);
    await Future<void>.delayed(Duration.zero);
    expect(topic.feed.where((entry) => entry.body == post.body).length, 1);

    final refresh = session.refresh(topic);
    backend.reads.last.$2.complete([post, post]);
    await refresh;
    expect(topic.feed.where((entry) => entry.body == post.body).length, 1);
    expect(session.history, ['+5 XP · Question']);
  });

  test(
    'Pending writes and local fallback belong to their original topic',
    () async {
      final backend = _Backend();
      final session = GameSession(backend);
      addTearDown(session.dispose);
      final shell = session.topics[0];
      final mobility = session.topics[1];

      final shellSend = session.send(
        shell,
        'Do high tides change shell choice?',
      );
      expect(shell.sending, isTrue);
      expect(mobility.sending, isFalse);
      mobility.kind = 'Answer';
      final mobilitySend = session.send(mobility, 'A bike avoids queues.');
      expect(backend.writes.map((write) => write.$1), ['shell', 'transport']);
      expect(backend.writes.last.$2, 'Answer');

      backend.writes.last.$4.completeError(StateError('offline'));
      await mobilitySend;
      expect(shell.sending, isTrue);
      expect(mobility.sending, isFalse);
      expect(
        mobility.feed.singleWhere((entry) => entry.keptLocally).body,
        'A bike avoids queues.',
      );

      backend.writes.first.$4.completeError(StateError('offline'));
      await shellSend;
      expect(
        shell.feed.singleWhere((entry) => entry.keptLocally).body,
        'Do high tides change shell choice?',
      );
      expect(mobility.feed.where((entry) => entry.keptLocally).length, 1);
      expect(session.xp, 10);
      expect(backend.writes.length, 2);
    },
  );
}
