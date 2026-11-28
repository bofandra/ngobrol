import 'dart:async';

import 'package:flutter/material.dart';

import 'backend.dart';
import 'game.dart';
import 'living_map.dart';
import 'playtest_forms.dart';
import 'playtest_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DemoBackend? backend;
  String? error;
  try {
    backend = await DemoBackend.connect();
  } catch (_) {
    error = 'Supabase unavailable. Playing offline.';
  }
  runApp(NgobrolApp(backend: backend, connectionError: error));
}

class NgobrolApp extends StatelessWidget {
  const NgobrolApp({super.key, this.backend, this.connectionError});

  final DiscussionBackend? backend;
  final String? connectionError;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ngobrol.',
    theme: playtestTheme(),
    home: _GameHome(backend: backend, connectionError: connectionError),
  );
}

class _GameHome extends StatefulWidget {
  const _GameHome({this.backend, this.connectionError});

  final DiscussionBackend? backend;
  final String? connectionError;

  @override
  State<_GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<_GameHome> {
  late final _session = GameSession(widget.backend);
  final _search = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _search.dispose();
    _session.dispose();
    super.dispose();
  }

  void _open(Topic topic) {
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(_session.refresh(topic));
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _TopicRoom(topic: topic, session: _session),
      ),
    );
  }

  Future<void> _createTopic() async {
    final created = await Navigator.push<(String, String)>(
      context,
      MaterialPageRoute(builder: (_) => const CreateTopicScreen()),
    );
    if (!mounted || created == null) return;
    _open(_session.createTopic(created.$1, created.$2));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_rounded, color: teal, size: 25),
            SizedBox(width: 8),
            Text('ngobrol.', style: TextStyle(fontSize: 27, letterSpacing: -1)),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: PlaytestFrame(
          child: _tab == 0 ? _discover(context) : _profile(context),
        ),
      ),
      bottomNavigationBar: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore, color: teal),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: teal),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _discover(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final matches = _session.topics.where(
      (topic) =>
          '${topic.title} ${topic.category}'.toLowerCase().contains(query),
    );
    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const PageStorageKey('discover'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _ProgressCard(session: _session),
              if (widget.connectionError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.connectionError!,
                    style: const TextStyle(color: gold),
                  ),
                ),
              const SizedBox(height: 22),
              Text(
                'Explore discussions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Search discussions',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => setState(_search.clear),
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear search',
                        ),
                ),
              ),
              const SizedBox(height: 13),
              if (matches.isEmpty)
                Semantics(
                  container: true,
                  liveRegion: true,
                  child: const GamePanel(
                    child: Text('No discussions match this search.'),
                  ),
                ),
              for (final topic in matches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _TopicCard(topic: topic, onTap: () => _open(topic)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 7),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _createTopic,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create new topic'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profile(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _ProgressCard(session: _session),
      const SizedBox(height: 20),
      Text(
        'Contribution history',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'XP is provisional for this playtest session.',
        style: TextStyle(color: textMuted),
      ),
      const SizedBox(height: 12),
      if (_session.history.isEmpty)
        const GamePanel(child: Text('Your adventure starts with a question.')),
      for (final entry in _session.history)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GamePanel(child: Text(entry)),
        ),
    ],
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) => GamePanel(
    color: const Color(0xff123647),
    border: const Color(0xff2e646e),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xff245761),
          foregroundColor: teal,
          child: Icon(Icons.explore, size: 27),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Systems Explorer',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              Text(
                'Level ${session.level}',
                style: const TextStyle(color: textMuted),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (session.xp % 100) / 100,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: const Color(0xff305569),
                semanticsLabel: 'Progress to next level',
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _XpTotal(session.xp),
      ],
    ),
  );
}

class _XpTotal extends StatelessWidget {
  const _XpTotal(this.xp);

  final int xp;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.emoji_events_rounded, size: 18, color: gold),
      const SizedBox(width: 4),
      Text(
        '$xp XP',
        style: const TextStyle(color: gold, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});

  final Topic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: panel,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: stroke),
      borderRadius: BorderRadius.circular(18),
    ),
    clipBehavior: Clip.antiAlias,
    child: Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(width: 103, height: 96, child: TopicArt(topic.art)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.category,
                      style: const TextStyle(
                        color: sky,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: teal),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TopicRoom extends StatefulWidget {
  const _TopicRoom({required this.topic, required this.session});

  final Topic topic;
  final GameSession session;

  @override
  State<_TopicRoom> createState() => _TopicRoomState();
}

class _TopicRoomState extends State<_TopicRoom> {
  late final _composer = TextEditingController(text: widget.topic.draft);
  final _feedScroll = ScrollController();
  int _tab = 0;
  String? _composerError;

  Topic get _topic => widget.topic;
  GameSession get _session => widget.session;
  bool get _shared => _topic.shared && _session.backend != null;

  @override
  void dispose() {
    _composer.dispose();
    _feedScroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_topic.sending) return;
    final body = _composer.text.trim();
    final error = body.isEmpty
        ? 'Write a contribution first.'
        : body.runes.length > contributionLimit
        ? 'Use 2,000 characters or fewer.'
        : null;
    setState(() => _composerError = error);
    if (error != null) return;

    _composer.clear();
    await _session.send(_topic, body);
    if (!mounted || _tab != 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_feedScroll.hasClients) {
        _feedScroll.animateTo(
          _feedScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _session,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
        actions: [
          if (_shared)
            IconButton(
              onPressed: () => _session.refresh(_topic),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh shared posts',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _XpTotal(_session.xp),
          ),
        ],
      ),
      body: SafeArea(
        child: PlaytestFrame(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  MediaQuery.viewInsetsOf(context).bottom > 0 ||
                  constraints.maxHeight < 460;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!compact && _tab == 0)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              height: 110,
                              child: TopicArt(_topic.art),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _topic.title,
                          maxLines: compact ? 1 : null,
                          overflow: compact ? TextOverflow.ellipsis : null,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: compact ? 16 : 21,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (!compact)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            child: Text(
                              _shared
                                  ? '${_topic.category} · Shared sandbox'
                                  : '${_topic.category} · Session playtest',
                              style: const TextStyle(color: textMuted),
                            ),
                          ),
                        const SizedBox(height: 5),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 0, label: Text('Talk')),
                            ButtonSegment(value: 1, label: Text('Map')),
                            ButtonSegment(value: 2, label: Text('Insights')),
                          ],
                          showSelectedIcon: false,
                          selected: {_tab},
                          onSelectionChanged: (tabs) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() => _tab = tabs.single);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_shared && _topic.refreshing)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      semanticsLabel: 'Refreshing shared posts',
                    ),
                  if (_topic.refreshError case final error?)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(error, style: const TextStyle(color: gold)),
                      ),
                    ),
                  Expanded(
                    child: switch (_tab) {
                      0 => _talk(),
                      1 => LivingMap(topic: _topic, session: _session),
                      _ => _insights(),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _talk() => Column(
    children: [
      Expanded(
        child: ListView(
          key: const PageStorageKey('talk'),
          controller: _feedScroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          children: [
            if (_topic.context.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _topic.context,
                  style: const TextStyle(color: textMuted, height: 1.4),
                ),
              ),
            for (final post in _topic.feed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PostCard(post),
              ),
          ],
        ),
      ),
      DecoratedBox(
        decoration: const BoxDecoration(
          color: night,
          border: Border(top: BorderSide(color: stroke)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 7,
                children: [
                  for (final (index, option) in contributionKinds.indexed)
                    ChoiceChip(
                      label: Text(option),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: [lilac, sky, gold][index],
                        fontWeight: _topic.kind == option
                            ? FontWeight.w800
                            : null,
                      ),
                      selectedColor: const Color(0xff26465f),
                      selected: _topic.kind == option,
                      onSelected: _topic.sending
                          ? null
                          : (_) => setState(() => _topic.kind = option),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _composer,
                      enabled: !_topic.sending,
                      minLines: 1,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        _topic.draft = value;
                        if (_composerError != null) {
                          setState(() => _composerError = null);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Share your thoughts…',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _topic.sending ? null : _send,
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                    icon: _topic.sending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: 'Sharing contribution',
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    tooltip: 'Send contribution',
                  ),
                ],
              ),
              if (_composerError case final error?)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(error, style: const TextStyle(color: coral)),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _insights() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      GamePanel(
        child: Text(
          '${_topic.links.length} causal hypotheses · '
          '${_topic.proposals.length} proposed changes',
        ),
      ),
      const SizedBox(height: 10),
      const GamePanel(
        child: Text(
          'Under what conditions might a proposed relationship stop being true? '
          'Revisit this discussion when you have a new perspective.',
        ),
      ),
    ],
  );
}

class _PostCard extends StatelessWidget {
  const _PostCard(this.post);

  final Contribution post;

  @override
  Widget build(BuildContext context) {
    final ai = post.isFacilitator;
    return GamePanel(
      color: ai ? const Color(0xff113f4b) : panel,
      border: ai ? const Color(0xff36777b) : stroke,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: ai ? const Color(0xff256667) : stroke,
            child: Icon(
              ai ? Icons.auto_awesome_rounded : Icons.person,
              size: 18,
              color: ai ? teal : sky,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 3,
                  children: [
                    Text(
                      post.author,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      ai ? 'Simulated facilitator' : post.kind,
                      style: TextStyle(color: ai ? teal : lilac),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(post.body, style: const TextStyle(height: 1.35)),
                if (post.keptLocally)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      'Kept on this device · Sharing failed',
                      style: TextStyle(color: gold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
