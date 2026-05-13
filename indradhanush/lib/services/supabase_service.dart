import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // events fetching
  static Future<List<Map<String, dynamic>>> getEvents() async{
    final response = await _client
    .from('events')
    .select()
    .order('evnt_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // add a new event to db
  static Future<String?> createEvent(Map<String, dynamic> data) async{
    final response = await _client
                    .from('events')
                    .insert(data)
                    .select('evnt_id')
                    .single();
  return response['evnt_id'] as String;
  }

  //fetch an event from eventID
  static Future<Map<String, dynamic>?> getEvent(String eventId) async {
    final response = await _client
        .from('events')
        .select()
        .eq('evnt_id', eventId)
        .single();
    return response;
  }

  //update event
  static Future<void> updateEvent(
      String eventId, Map<String, dynamic> data) async {
    await _client.from('events').update(data).eq('evnt_id', eventId);
  }

  //delete an event 
  static Future<void> deleteEvent(String eventId) async {
    await _client.from('events').delete().eq('evnt_id', eventId);
  }

  // advance details table 
  static Future<Map<String,dynamic>?> getAdvanceDetails(String eventId) async{
    final response = await _client
        .from('advanceDetails')
        .select()
        .eq('event_id', eventId)
        .maybeSingle();
    return response;
  }

// create new row if no exist, else update existing
  static Future<void> upsertAdvanceDetails(Map<String, dynamic> data) async {
    await _client.from('advanceDetails').upsert(data);
  }

  // payments
  static Future<Map<String, dynamic>?> getPayment(String eventId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('event_id', eventId)
        .maybeSingle();
    return response;
  }

  static Future<void> upsertPayment(Map<String, dynamic> data) async {
    await _client.from('payments').upsert(data);
  }

  // income and stats
  static Future<List<Map<String, dynamic>>> getMonthlyIncome() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    final response = await _client
                    .from('events')
                    .select('evnt_date, amount')
                    .gte('evnt_date',sixMonthsAgo.toString().split(' ')[0])//del the tiem part of the date string
                    .order('evnt_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

}