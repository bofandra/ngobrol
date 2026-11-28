import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DiscussionBackend {
  Future<List<SharedPost>> posts(String topic);
  Future<SharedPost> add(String topic, String kind, String body);
}

class SharedPost {
  const SharedPost({
    required this.id,
    required this.kind,
    required this.body,
    required this.createdAt,
    this.isMine = false,
  });

  final String id;
  final String kind;
  final String body;
  final DateTime createdAt;
  final bool isMine;
}

class DemoBackend implements DiscussionBackend {
  DemoBackend(this.client);

  final SupabaseClient client;

  static const _postColumns = 'id,author_id,kind,body,created_at';

  static Future<DemoBackend?> connect() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (url.isEmpty && key.isEmpty) return null;
    if (url.isEmpty || key.isEmpty) {
      throw StateError('Both Supabase settings are required.');
    }

    await Supabase.initialize(url: url, publishableKey: key);
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) {
      await client.auth.signInAnonymously();
    }
    return DemoBackend(client);
  }

  @override
  Future<List<SharedPost>> posts(String topic) async {
    final rows = await client
        .from('demo_posts')
        .select(_postColumns)
        .eq('topic_id', topic)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .limit(200);
    return rows.reversed.map(_decode).toList();
  }

  @override
  Future<SharedPost> add(String topic, String kind, String body) async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('No Supabase session.');

    final row = await client
        .from('demo_posts')
        .insert({
          'topic_id': topic,
          'author_id': user.id,
          'kind': kind,
          'body': body,
        })
        .select(_postColumns)
        .single();
    return _decode(row);
  }

  SharedPost _decode(Map<String, dynamic> row) => SharedPost(
    id: row['id'] as String,
    kind: row['kind'] as String,
    body: row['body'] as String,
    createdAt: DateTime.parse(row['created_at'] as String),
    isMine: row['author_id'] == client.auth.currentUser?.id,
  );
}
