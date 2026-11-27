import 'package:supabase_flutter/supabase_flutter.dart';

class DemoBackend {
  final SupabaseClient client;
  DemoBackend(this.client);

  static Future<DemoBackend?> connect() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (url.isEmpty || key.isEmpty) return null;
    await Supabase.initialize(url: url, publishableKey: key);
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) {
      await client.auth.signInAnonymously();
    }
    return DemoBackend(client);
  }

  Future<List<Map<String, dynamic>>> posts(String topic) async {
    final result = await client.from('demo_posts').select()
        .eq('topic_id', topic).order('created_at').limit(200);
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> add(String topic, String kind, String body) async {
    await client.from('demo_posts').insert({
      'topic_id': topic,
      'author_id': client.auth.currentUser!.id,
      'kind': kind,
      'body': body,
    });
  }
}
