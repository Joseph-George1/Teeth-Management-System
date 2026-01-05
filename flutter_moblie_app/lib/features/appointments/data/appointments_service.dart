import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentsService {
  static const String _key = 'appointments_data';

  Future<List<Map<String, dynamic>>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> addAppointment(Map<String, dynamic> appointment) async {
    final prefs = await SharedPreferences.getInstance();
    final appointments = await getAppointments();
    appointments.add(appointment);
    await prefs.setString(_key, jsonEncode(appointments));
  }
}

