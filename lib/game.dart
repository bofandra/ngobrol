import 'dart:async';

import 'package:flutter/foundation.dart';

import 'backend.dart';

const contributionKinds = ['Question', 'Answer', 'Suggestion'];
const contributionLimit = 2000;

class Topic {
  Topic({
    required this.id,
    required this.title,
    required this.category,
    required this.context,
    this.art,
    this.shared = false,
    this.seedPosts = const [],
    this.links = const [],
  });

  final String id;
  final String title;
  final String category;
  final String context;
  final String? art;
  final bool shared;
  final List<Contribution> seedPosts;
  final List<Link> links;
  final proposals = <Proposal>[];

  final _localPosts = <Contribution>[];
  final _unconfirmedPosts = <String, SharedPost>{};
  List<SharedPost> _sharedPosts = [];
  int _refreshVersion = 0;

  String draft = '';
  String kind = contributionKinds.first;
  String? refreshError;
  bool refreshing = false;
  bool sending = false;

  List<Contribution> get feed {
    final recent = [
      ..._localPosts,
      for (final row in _sharedPosts)
        Contribution(
          row.isMine ? 'You' : 'Community player',
          row.kind,
          row.body,
          time: row.createdAt,
        ),
    ]..sort((a, b) => a.time!.compareTo(b.time!));
    return [...seedPosts, ...recent];
  }
}

class Contribution {
  const Contribution(
    this.author,
    this.kind,
    this.body, {
    this.time,
    this.keptLocally = false,
  });

  final String author;
  final String kind;
  final String body;
  final DateTime? time;
  final bool keptLocally;

  bool get isFacilitator => kind == 'Prompt';
}

class Link {
  Link(this.from, this.to, this.positive, {this.up = 0, this.down = 0});

  final String from;
  final String to;
  final bool positive;
  final int up;
  final int down;
  int vote = 0;

  String get sign => positive ? '+' : '−';
  int get upCount => up + (vote == 1 ? 1 : 0);
  int get downCount => down + (vote == -1 ? 1 : 0);
  void choose(int next) => vote = vote == next ? 0 : next;
}

class Proposal {
  const Proposal(this.from, this.to, this.positive, this.rationale);

  final String from;
  final String to;
  final bool positive;
  final String rationale;

  String get summary => '$from → $to (${positive ? '+' : '−'})';
}

class GameSession extends ChangeNotifier {
  GameSession(this.backend);

  final DiscussionBackend? backend;
  final topics = _seedTopics();
  final history = <String>[];
  int xp = 0;
  bool _disposed = false;

  int get level => 1 + xp ~/ 100;

  void _award(int points, String reason) {
    xp += points;
    history.insert(0, '+$points XP · $reason');
  }

  Topic createTopic(String title, String context) {
    final topic = Topic(
      id: 'local-${topics.length}',
      title: title,
      category: 'Your world',
      context: context,
    );
    topics.insert(0, topic);
    _award(10, 'Started a topic');
    notifyListeners();
    return topic;
  }

  void vote(Link link, int choice) {
    link.choose(choice);
    notifyListeners();
  }

  void propose(Topic topic, Proposal proposal) {
    topic.proposals.add(proposal);
    _award(10, 'Proposed relationship');
    notifyListeners();
  }

  Future<void> refresh(Topic topic) async {
    final service = backend;
    if (service == null || !topic.shared) return;

    final version = ++topic._refreshVersion;
    topic.refreshing = true;
    topic.refreshError = null;
    notifyListeners();

    try {
      final rows = await service.posts(topic.id);
      if (_disposed || version != topic._refreshVersion) return;

      final byId = {for (final row in rows) row.id: row};
      topic._unconfirmedPosts.removeWhere((id, _) => byId.containsKey(id));
      topic._sharedPosts = {
        ...byId,
        ...topic._unconfirmedPosts,
      }.values.toList();
    } catch (_) {
      if (_disposed || version != topic._refreshVersion) return;
      topic.refreshError = 'Could not refresh shared posts. Try Refresh again.';
    }

    topic.refreshing = false;
    notifyListeners();
  }

  Future<void> send(Topic topic, String body) async {
    if (topic.sending ||
        body.isEmpty ||
        body.runes.length > contributionLimit) {
      return;
    }

    final kind = topic.kind;
    final service = backend;
    final shouldShare = service != null && topic.shared;
    topic.draft = '';
    topic.sending = true;
    notifyListeners();

    SharedPost? shared;
    if (shouldShare) {
      try {
        shared = await service.add(topic.id, kind, body);
      } catch (_) {
        // Keep the contribution on this device and do not retry the write.
      }
      if (_disposed) return;
    }

    final postedAt = DateTime.now();
    if (shared == null) {
      topic._localPosts.add(
        Contribution(
          'You',
          kind,
          body,
          time: postedAt,
          keptLocally: shouldShare,
        ),
      );
    } else {
      topic._unconfirmedPosts[shared.id] = shared;
      topic._sharedPosts = [
        for (final row in topic._sharedPosts)
          if (row.id != shared.id) row,
        shared,
      ];
    }

    topic._localPosts.add(
      Contribution(
        'Ngobrol AI',
        'Prompt',
        'What factor could change this relationship? Is there evidence or an alternative explanation?',
        time: (shared?.createdAt ?? postedAt).add(
          const Duration(microseconds: 1),
        ),
      ),
    );
    _award(5, kind);
    topic.sending = false;
    if (shared != null) {
      unawaited(refresh(topic));
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

List<Topic> _seedTopics() => [
  Topic(
    id: 'shell',
    title: 'What makes a good home for a hermit crab?',
    category: 'Everyday life',
    art: 'hermit-crab',
    shared: true,
    context: 'A little hermit crab needs a new shell. Explore the trade-offs.',
    seedPosts: const [
      Contribution(
        'Rina',
        'Answer',
        'A larger shell might offer more protection, but it could also be heavier.',
      ),
      Contribution(
        'Dimas',
        'Question',
        'Would a heavy shell make it harder to escape predators?',
      ),
      Contribution(
        'Ngobrol AI',
        'Prompt',
        'Could shell weight affect survival through mobility? Let’s review that hypothesis.',
      ),
    ],
    links: [
      Link('Shell size', 'Protection', true, up: 24, down: 3),
      Link('Shell size', 'Shell weight', true, up: 18, down: 2),
      Link('Shell weight', 'Mobility', false, up: 27, down: 6),
      Link('Protection', 'Survival chance', true, up: 15, down: 1),
      Link('Mobility', 'Survival chance', true, up: 20, down: 3),
    ],
  ),
  Topic(
    id: 'transport',
    title: 'Which transportation is right for me?',
    category: 'Mobility',
    art: 'transport',
    shared: true,
    context:
        'Compare speed, cost, comfort, safety and the purpose of the journey.',
    seedPosts: const [
      Contribution(
        'Maya',
        'Question',
        'How does rush-hour traffic change the best choice?',
      ),
    ],
    links: [
      Link('Traffic', 'Travel time', true),
      Link('Travel time', 'Convenience', false),
    ],
  ),
  Topic(
    id: 'heat',
    title: 'How can we reduce urban heat?',
    category: 'Environment',
    art: 'urban-heat',
    shared: true,
    context: 'Explore shade, vegetation, buildings and energy demand.',
    links: [
      Link('Tree cover', 'Shade', true),
      Link('Shade', 'Street temperature', false),
    ],
  ),
];
