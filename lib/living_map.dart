import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game.dart';
import 'playtest_forms.dart';
import 'playtest_theme.dart';

class LivingMap extends StatefulWidget {
  const LivingMap({required this.topic, required this.session, super.key});

  final Topic topic;
  final GameSession session;

  @override
  State<LivingMap> createState() => _LivingMapState();
}

class _LivingMapState extends State<LivingMap> {
  bool _showList = false;

  Future<void> _propose() async {
    final proposal = await showDialog<Proposal>(
      context: context,
      builder: (_) => const ProposalDialog(),
    );
    if (mounted && proposal != null) {
      widget.session.propose(widget.topic, proposal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final relationships = topic.links;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text('Living map', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Causal hypotheses', style: TextStyle(color: lilac)),
        const SizedBox(height: 12),
        if (relationships.isNotEmpty) ...[
          SegmentedButton<bool>(
            segments: [
              const ButtonSegment(
                value: false,
                icon: Icon(Icons.hub_outlined),
                label: Text('Diagram'),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.list),
                label: Text('List (${relationships.length})'),
              ),
            ],
            showSelectedIcon: false,
            selected: {_showList},
            onSelectionChanged: (value) =>
                setState(() => _showList = value.single),
          ),
          const SizedBox(height: 12),
          if (!_showList)
            GamePanel(
              padding: const EdgeInsets.all(10),
              color: const Color(0xff0b2236),
              child: Semantics(
                image: true,
                label: 'Causal diagram. Open List to read each relationship.',
                child: SizedBox(
                  height: 258,
                  child: CustomPaint(
                    painter: _MapPainter(relationships, topic.id == 'shell'),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '+ Same direction   ·   − Opposite direction\n'
              'Votes show community agreement. Evidence is assessed separately.',
              style: TextStyle(color: textMuted, height: 1.4),
            ),
          ),
          if (_showList)
            GamePanel(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < relationships.length; i++) ...[
                    if (i != 0) const Divider(height: 1, color: stroke),
                    _Relationship(
                      link: relationships[i],
                      session: widget.session,
                    ),
                  ],
                ],
              ),
            ),
        ] else
          const GamePanel(
            child: Text('No relationships yet. Suggest one to start the map.'),
          ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _propose,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Suggest map change'),
        ),
        const SizedBox(height: 18),
        Text(
          'Pending proposals (${topic.proposals.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (topic.proposals.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Proposed changes appear here for review.',
              style: TextStyle(color: textMuted),
            ),
          ),
        for (final proposal in topic.proposals)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GamePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proposal.summary, style: const TextStyle(color: lilac)),
                  const SizedBox(height: 6),
                  Text(proposal.rationale),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Relationship extends StatelessWidget {
  const _Relationship({required this.link, required this.session});

  final Link link;
  final GameSession session;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 9, 2, 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${link.from} → ${link.to} (${link.sign})',
          style: TextStyle(
            color: link.positive ? teal : coral,
            fontWeight: FontWeight.w700,
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            _voteButton(1, link.upCount),
            _voteButton(-1, link.downCount),
          ],
        ),
      ],
    ),
  );

  Widget _voteButton(int choice, int count) {
    final up = choice == 1;
    final selected = link.vote == choice;
    final action = selected
        ? (up ? 'Withdraw agreement' : 'Withdraw disagreement')
        : (up ? 'Agree' : 'Disagree');
    final label = '$action on ${link.from} to ${link.to}';
    return Tooltip(
      excludeFromSemantics: true,
      message: label,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          foregroundColor: up ? teal : coral,
          backgroundColor: selected ? stroke : Colors.transparent,
        ),
        onPressed: () => session.vote(link, choice),
        icon: Icon(
          up
              ? (selected ? Icons.thumb_up : Icons.thumb_up_outlined)
              : (selected ? Icons.thumb_down : Icons.thumb_down_outlined),
          size: 16,
        ),
        label: Text(
          '$count',
          semanticsLabel: '$label, $count ${count == 1 ? 'vote' : 'votes'}',
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.links, this.shell);

  final List<Link> links;
  final bool shell;

  @override
  void paint(Canvas canvas, Size size) {
    final names = {
      for (final link in links) link.from,
      for (final link in links) link.to,
    }.toList();
    final grid = Paint()..color = const Color(0xff233e53);
    for (double y = 5; y < size.height; y += 13) {
      for (double x = 5; x < size.width; x += 13) {
        canvas.drawCircle(Offset(x, y), 0.85, grid);
      }
    }

    final points = <String, Offset>{};
    final center = size.width / 2;
    final branchGap = math.min(size.width * .26, 142.0);
    if (shell) {
      points.addAll({
        'Shell size': Offset(center, 26),
        'Protection': Offset(center - branchGap, 92),
        'Shell weight': Offset(center + branchGap, 92),
        'Mobility': Offset(center + branchGap, 160),
        'Survival chance': Offset(center, 230),
      });
    } else {
      for (var i = 0; i < names.length; i++) {
        final y = 28 + (size.height - 56) * i / math.max(1, names.length - 1);
        points[names[i]] = Offset(center, y);
      }
    }

    final width = math.min(132.0, size.width * .42);
    const height = 42.0;
    for (final link in links) {
      final a = points[link.from]!;
      final b = points[link.to]!;
      final delta = b - a;
      if (delta.distance == 0) continue;
      final unit = delta / delta.distance;
      final trim = math.min(
        width / 2 / math.max(unit.dx.abs(), .001),
        height / 2 / math.max(unit.dy.abs(), .001),
      );
      final start = a + unit * trim;
      final end = b - unit * trim;
      final perpendicular = Offset(-unit.dy, unit.dx);
      final color = link.positive ? teal : coral;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, paint);
      final wingA = end - unit * 8 + perpendicular * 4;
      final wingB = end - unit * 8 - perpendicular * 4;
      canvas.drawPath(
        Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(wingA.dx, wingA.dy)
          ..lineTo(wingB.dx, wingB.dy)
          ..close(),
        Paint()..color = color,
      );
      final badge = (start + end) / 2 + perpendicular * 12;
      canvas.drawCircle(badge, 9, Paint()..color = night);
      _label(canvas, link.sign, badge, color, 15, 18);
    }

    for (final entry in points.entries) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: entry.value, width: width, height: height),
        const Radius.circular(13),
      );
      canvas.drawRRect(rect, Paint()..color = panel);
      canvas.drawRRect(
        rect,
        Paint()
          ..color = teal
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
      _label(canvas, entry.key, entry.value, Colors.white, 13, width - 10);
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at,
    Color color,
    double size,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontFamily: playtestFont,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: width);
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.links != links || oldDelegate.shell != shell;
}
