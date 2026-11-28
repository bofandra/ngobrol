import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'backend.dart';

const bg = Color(0xff101e31);
const panel = Color(0xff1b3046);
const mint = Color(0xff50dfcb);
const gold = Color(0xffffca55);

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

class Topic {
  Topic(this.id, this.title, this.category, this.icon, this.context,
      {this.shared = false, List<Post>? posts, List<Link>? links})
      : posts = posts ?? [], links = links ?? [];
  final String id, title, category, icon, context;
  final bool shared;
  final List<Post> posts;
  final List<Link> links;
  final List<Post> remote = [];
  final List<String> proposals = [];
}

class Post {
  const Post(this.author, this.kind, this.body);
  final String author, kind, body;
}

class Link {
  Link(this.from, this.to, this.positive, {this.up = 0, this.down = 0});
  final String from, to;
  final bool positive;
  int up, down, vote = 0;
  void choose(int next) {
    vote = vote == next ? 0 : next;
  }
}

List<Topic> seedTopics() => [
  Topic('shell', 'What makes a good home for a hermit crab?', 'Everyday life', '🐚',
    'A little hermit crab needs a new shell. Explore the trade-offs.', shared: true,
    posts: const [
      Post('Rina', 'Answer', 'A larger shell might offer more protection, but it could also be heavier.'),
      Post('Dimas', 'Question', 'Would a heavy shell make it harder to escape predators?'),
      Post('Ngobrol AI · demo', 'Prompt', 'Could shell weight affect survival through mobility? Let’s review that hypothesis.'),
    ],
    links: [
      Link('Shell size', 'Protection', true, up: 24, down: 3),
      Link('Shell size', 'Shell weight', true, up: 18, down: 2),
      Link('Shell weight', 'Mobility', false, up: 27, down: 6),
      Link('Protection', 'Survival chance', true, up: 15, down: 1),
      Link('Mobility', 'Survival chance', true, up: 20, down: 3),
    ]),
  Topic('transport', 'Which transportation is right for me?', 'Mobility', '🚆',
    'Compare speed, cost, comfort, safety and the purpose of the journey.', shared: true,
    posts: const [Post('Maya', 'Question', 'How does rush-hour traffic change the best choice?')],
    links: [Link('Traffic', 'Travel time', true), Link('Travel time', 'Convenience', false)]),
  Topic('heat', 'How can we reduce urban heat?', 'Environment', '🌳',
    'Explore shade, vegetation, buildings and energy demand.', shared: true,
    links: [Link('Tree cover', 'Shade', true), Link('Shade', 'Street temperature', false)]),
];

class NgobrolApp extends StatelessWidget {
  const NgobrolApp({super.key, this.backend, this.connectionError});
  final DemoBackend? backend;
  final String? connectionError;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ngobrol.',
    theme: ThemeData(
      brightness: Brightness.dark, useMaterial3: true, scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: mint, secondary: gold, surface: panel),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
    ),
    home: GameHome(backend: backend, connectionError: connectionError),
  );
}

class GameHome extends StatefulWidget {
  const GameHome({super.key, this.backend, this.connectionError});
  final DemoBackend? backend;
  final String? connectionError;
  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  final topics = seedTopics();
  final history = <String>[];
  final composer = TextEditingController();
  int xp = 0, tab = 0, roomTab = 0;
  String kind = 'Question', query = '';
  Topic? active;
  bool busy = false;
  String? notice;

  @override
  void initState() { super.initState(); notice = widget.connectionError; }
  @override
  void dispose() { composer.dispose(); super.dispose(); }

  void award(int points, String why) {
    xp += points;
    history.insert(0, '+$points XP · $why');
  }

  void open(Topic topic) {
    setState(() { active = topic; roomTab = 0; composer.clear(); notice = widget.connectionError; });
    refresh(topic);
  }

  Future<void> refresh(Topic topic) async {
    final backend = widget.backend;
    if (backend == null || !topic.shared) return;
    try {
      final rows = await backend.posts(topic.id);
      if (!mounted) return;
      setState(() {
        topic.remote
          ..clear()
          ..addAll(rows.map((r) => Post('Community player', r['kind'] as String, r['body'] as String)));
        if (active == topic) notice = null;
      });
    } catch (_) {
      if (mounted && active == topic) setState(() => notice = 'Could not refresh shared posts.');
    }
  }

  Future<void> send() async {
    final topic = active;
    final body = composer.text.trim();
    final selected = kind;
    if (topic == null || body.isEmpty || busy) return;
    if (body.length > 2000) {
      setState(() => notice = 'Please use 2,000 characters or fewer.');
      return;
    }
    setState(() => busy = true);
    bool synced = false;
    final backend = widget.backend;
    if (backend != null && topic.shared) {
      try {
        await backend.add(topic.id, selected, body);
        synced = true;
      } catch (_) {
        if (mounted) setState(() => notice = 'Post kept locally; sharing failed.');
      }
    }
    if (!mounted) return;
    setState(() {
      if (!synced) topic.posts.add(Post('You', selected, body));
      award(5, selected);
      topic.posts.add(const Post('Ngobrol AI · demo', 'Prompt',
        'What factor could change this relationship? Is there evidence or an alternative explanation?'));
      if (active == topic) composer.clear();
      busy = false;
    });
    if (synced) await refresh(topic);
  }

  Future<void> createTopic() async {
    final title = TextEditingController(), detail = TextEditingController();
    final created = await showDialog<Topic>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Start a new discussion'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, maxLength: 120, decoration: const InputDecoration(labelText: 'Main question')),
        const SizedBox(height: 12),
        TextField(controller: detail, maxLength: 500, maxLines: 3, decoration: const InputDecoration(labelText: 'Context')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (title.text.trim().isEmpty) return;
          Navigator.pop(ctx, Topic('local-${DateTime.now().microsecondsSinceEpoch}', title.text.trim(),
            'Your world', '💬', detail.text.trim()));
        }, child: const Text('Start Ngobrol')),
      ],
    ));
    title.dispose(); detail.dispose();
    if (created != null && mounted) {
      setState(() { topics.insert(0, created); award(10, 'Started a topic'); });
      open(created);
    }
  }

  Future<void> propose(Topic topic) async {
    final from = TextEditingController(), to = TextEditingController(), why = TextEditingController();
    bool positive = true;
    final result = await showDialog<String>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, change) => AlertDialog(title: const Text('Propose a causal relationship'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: from, maxLength: 60, decoration: const InputDecoration(labelText: 'Cause / factor')),
          TextField(controller: to, maxLength: 60, decoration: const InputDecoration(labelText: 'Effect / factor')),
          SwitchListTile(title: Text(positive ? 'Positive (+)' : 'Negative (−)'), value: positive,
            onChanged: (v) => change(() => positive = v)),
          TextField(controller: why, maxLength: 500, maxLines: 2, decoration: const InputDecoration(labelText: 'Reason or evidence')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (from.text.trim().isEmpty || to.text.trim().isEmpty || why.text.trim().isEmpty ||
                from.text.trim().toLowerCase() == to.text.trim().toLowerCase()) return;
            Navigator.pop(ctx, '${from.text.trim()} → ${to.text.trim()} (${positive ? '+' : '−'})\n${why.text.trim()}');
          }, child: const Text('Submit for review')),
        ],
      ),
    ));
    from.dispose(); to.dispose(); why.dispose();
    if (result != null && mounted) setState(() {
      topic.proposals.add(result);
      award(10, 'Proposed relationship');
    });
  }

  Widget surface(Widget child) => Card(color: panel, margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(16), child: child));

  Widget discover() => ListView(padding: const EdgeInsets.all(16), children: [
    surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('A world of questions', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Play together. Connect ideas. Understand the world.'),
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: createTopic, icon: const Icon(Icons.add), label: const Text('Create new topic')),
    ])),
    TextField(onChanged: (value) => setState(() => query = value), decoration:
      const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Explore discussions')),
    const SizedBox(height: 16),
    for (final topic in topics.where((t) => '${t.title} ${t.category}'.toLowerCase().contains(query.toLowerCase())))
      surface(ListTile(contentPadding: EdgeInsets.zero, onTap: () => open(topic),
        leading: Text(topic.icon, style: const TextStyle(fontSize: 34)),
        title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${topic.category} · Open discussion'),
        trailing: const Icon(Icons.chevron_right, color: mint))),
  ]);

  Widget profile() => ListView(padding: const EdgeInsets.all(16), children: [
    surface(Column(children: [
      const CircleAvatar(radius: 35, child: Icon(Icons.explore, size: 35)),
      const SizedBox(height: 12), const Text('Systems Explorer', style: TextStyle(fontSize: 23)),
      Text('Level ${1 + xp ~/ 100} · $xp XP', style: const TextStyle(color: gold, fontSize: 18)),
      const SizedBox(height: 12), LinearProgressIndicator(value: (xp % 100) / 100),
      const SizedBox(height: 8), const Text('Prototype XP is local and provisional.'),
    ])),
    const Text('Contribution history', style: TextStyle(fontSize: 20)),
    const SizedBox(height: 12),
    if (history.isEmpty) const Text('Your adventure starts with a question.'),
    for (final h in history) surface(Text(h)),
  ]);

  Widget talk(Topic t) => Column(children: [
    Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
      surface(Text(t.context.isEmpty ? 'Explore different perspectives together.' : t.context)),
      for (final p in [...t.posts, ...t.remote])
        surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.author, style: const TextStyle(color: mint, fontWeight: FontWeight.bold)),
          Text(p.kind, style: const TextStyle(color: gold, fontSize: 12)),
          const SizedBox(height: 8), Text(p.body),
        ])),
    ])),
    SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Wrap(spacing: 8, children: [
        for (final option in ['Question', 'Answer', 'Suggestion'])
          ChoiceChip(label: Text(option), selected: kind == option, onSelected: (_) => setState(() => kind = option)),
      ]),
      Row(children: [
        Expanded(child: TextField(controller: composer, enabled: !busy, minLines: 1, maxLines: 3,
          decoration: const InputDecoration(hintText: 'Share your thoughts…'))),
        IconButton.filled(onPressed: busy ? null : send, icon: const Icon(Icons.send), tooltip: 'Send contribution'),
      ]),
    ]))),
  ]);

  Widget map(Topic t) => ListView(padding: const EdgeInsets.all(16), children: [
    surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Living system map', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const Text('AI demo · causal hypotheses, not established facts'),
      const SizedBox(height: 12),
      if (t.links.isEmpty) const Text('No relationships yet. Add a proposal to begin.')
      else SizedBox(height: 280, child: CustomPaint(painter: MapPainter(t.links), child: const SizedBox.expand())),
      const Text('+ same direction   ·   − opposite direction', style: TextStyle(color: mint)),
      const Text('Votes show agreement, not causal proof.'),
    ])),
    const Text('Review relationships', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    for (final link in t.links) surface(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${link.from} → ${link.to} (${link.positive ? '+' : '−'})'),
      Row(children: [
        TextButton.icon(onPressed: () => setState(() => link.choose(1)),
          icon: Icon(link.vote == 1 ? Icons.thumb_up : Icons.thumb_up_outlined), label: Text('${link.up + (link.vote == 1 ? 1 : 0)}')),
        TextButton.icon(onPressed: () => setState(() => link.choose(-1)),
          icon: Icon(link.vote == -1 ? Icons.thumb_down : Icons.thumb_down_outlined), label: Text('${link.down + (link.vote == -1 ? 1 : 0)}')),
      ]),
    ])),
    FilledButton.icon(onPressed: () => propose(t), icon: const Icon(Icons.edit), label: const Text('Suggest map change')),
    const SizedBox(height: 12),
    Text('Pending proposals (${t.proposals.length})', style: const TextStyle(fontSize: 18)),
    for (final p in t.proposals) surface(Text(p)),
  ]);

  Widget room(Topic t) => Column(children: [
    Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Text('${t.icon} ${t.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      SegmentedButton<int>(segments: const [
        ButtonSegment(value: 0, label: Text('Talk'), icon: Icon(Icons.chat)),
        ButtonSegment(value: 1, label: Text('Map'), icon: Icon(Icons.hub)),
        ButtonSegment(value: 2, label: Text('Insights'), icon: Icon(Icons.lightbulb_outline)),
      ], selected: {roomTab}, onSelectionChanged: (s) => setState(() => roomTab = s.first)),
    ])),
    Expanded(child: roomTab == 0 ? talk(t) : roomTab == 1 ? map(t) :
      ListView(padding: const EdgeInsets.all(16), children: [
        surface(const Text('This discussion never ends. Return when new perspectives or evidence emerge.')),
        surface(Text('${t.links.length} causal hypotheses · ${t.proposals.length} proposed changes')),
        surface(const Text('Next question: Under what conditions might a proposed relationship stop being true?')),
      ])),
  ]);

  @override
  Widget build(BuildContext context) {
    final topic = active;
    return Scaffold(
      appBar: AppBar(backgroundColor: bg,
        leading: topic == null ? null : IconButton(onPressed: () => setState(() { active = null; notice = widget.connectionError; }), icon: const Icon(Icons.arrow_back)),
        title: const Text('ngobrol.', style: TextStyle(color: mint, fontWeight: FontWeight.w900, fontSize: 27)),
        actions: [
          if (topic != null && topic.shared && widget.backend != null)
            IconButton(onPressed: () => refresh(topic), icon: const Icon(Icons.refresh), tooltip: 'Refresh shared posts'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Center(child: Text('🏆 $xp XP', style: const TextStyle(color: gold)))),
        ]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Column(children: [
        Text(widget.backend == null ? 'OFFLINE PLAYTEST' : 'SUPABASE SANDBOX · public demo posts',
          style: const TextStyle(color: mint, fontSize: 11, letterSpacing: 1.2)),
        if (notice != null) Padding(padding: const EdgeInsets.all(8), child: Text(notice!, style: const TextStyle(color: gold))),
        Expanded(child: topic != null ? room(topic) : tab == 0 ? discover() : profile()),
      ]))),
      bottomNavigationBar: topic == null ? NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ]) : null,
    );
  }
}

class MapPainter extends CustomPainter {
  MapPainter(this.links);
  final List<Link> links;

  @override
  void paint(Canvas canvas, Size size) {
    final names = <String>{for (final l in links) l.from, for (final l in links) l.to}.toList();
    if (names.isEmpty) return;
    final points = <String, Offset>{};
    final shell = names.contains('Shell size') && names.length == 5;
    if (shell) {
      points.addAll({
        'Shell size': Offset(size.width * .5, 26),
        'Protection': Offset(size.width * .23, 104),
        'Shell weight': Offset(size.width * .77, 104),
        'Mobility': Offset(size.width * .77, 177),
        'Survival chance': Offset(size.width * .5, 253),
      });
    } else {
      for (var i = 0; i < names.length; i++) {
        final angle = -math.pi / 2 + 2 * math.pi * i / names.length;
        points[names[i]] = Offset(size.width / 2 + math.cos(angle) * size.width * .28,
          size.height / 2 + math.sin(angle) * size.height * .35);
      }
    }
    final nodeWidth = math.min(116.0, size.width * .32);
    const nodeHeight = 38.0;
    for (final l in links) {
      final a = points[l.from]!, b = points[l.to]!;
      final delta = b - a;
      if (delta.distance == 0) continue;
      final unit = delta / delta.distance;
      final trim = math.min(nodeWidth / 2 / math.max(unit.dx.abs(), .001),
        nodeHeight / 2 / math.max(unit.dy.abs(), .001));
      final start = a + unit * trim, end = b - unit * trim;
      final color = l.positive ? mint : const Color(0xffff8787);
      final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, paint);
      final perp = Offset(-unit.dy, unit.dx);
      final tip = Path()..moveTo(end.dx, end.dy)
        ..lineTo((end - unit * 9 + perp * 5).dx, (end - unit * 9 + perp * 5).dy)
        ..lineTo((end - unit * 9 - perp * 5).dx, (end - unit * 9 - perp * 5).dy)..close();
      canvas.drawPath(tip, Paint()..color = color);
      label(canvas, l.positive ? '+' : '−', (start + end) / 2 + perp * 10, color, 16);
    }
    for (final entry in points.entries) {
      final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: entry.value, width: nodeWidth, height: nodeHeight), const Radius.circular(10));
      canvas.drawRRect(rect, Paint()..color = panel);
      canvas.drawRRect(rect, Paint()..color = mint..style = PaintingStyle.stroke..strokeWidth = 1.5);
      label(canvas, entry.key, entry.value, Colors.white, 12, maxWidth: nodeWidth - 8);
    }
  }

  void label(Canvas canvas, String text, Offset center, Color color, double fontSize, {double maxWidth = 100}) {
    final p = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center, maxLines: 2, ellipsis: '…')..layout(maxWidth: maxWidth);
    p.paint(canvas, center - Offset(p.width / 2, p.height / 2));
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}
