// lib/services/job/job_api_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intern_management_app/api_key.dart';
import '../../models/job_portal/job_model.dart';

class JobApiService {
  final String _apiKey = jobAPIKey;
  final String _apiHost = 'jsearch.p.rapidapi.com';

  Future<List<Job>> fetchJobs() async {
    List<Job> allJobs = [];

    try {
      final queries = [
        "software engineer OR developer OR programmer",
        "electrical engineer",
        "data scientist OR data science",
        "machine learning OR ML engineer",
        "artificial intelligence OR AI",
        "management sciences OR manager"
      ];

      for (var q in queries) {
        final url = Uri.https(
          _apiHost,
          '/search',
          {
            'query': q,
            'page': '1',
            'num_pages': '1',
            'job_type': 'fulltime,parttime,internship',
            'country': 'PK',
            'date_posted': 'week',
          },
        );

        final response = await http.get(
          url,
          headers: {
            'X-RapidAPI-Key': _apiKey,
            'X-RapidAPI-Host': _apiHost,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<dynamic> jobList = data['data'];
          allJobs.addAll(jobList.map((json) {
            final String title = json['job_title'] ?? 'N/A';
            final String category = _getCategoryFromTitle(title);
            return Job.fromMap({
              ...json,
              'category': category,
            });
          }).toList());
        }
        else {
          print('API request failed: ${response.statusCode}');
        }
      }

    } catch (e) {
      print('API error: $e');
    }

    // ✅ Duplicates remove
    final uniqueJobs = <String, Job>{};
    for (var job in allJobs) {
      if (job.id != 'N/A') {
        final key = "${job.id}_${job.title}_${job.companyName}";
        uniqueJobs[key] = job;
      }
    }

    return uniqueJobs.values.toList();
  }

  /// ✅ Retry helper (429 errors handle karega)
  Future<http.Response?> _retryRequest(Future<http.Response> Function() requestFn,
      {int retries = 3, Duration delay = const Duration(seconds: 2)}) async {
    http.Response? response;
    for (int attempt = 0; attempt < retries; attempt++) {
      response = await requestFn();
      if (response.statusCode != 429) {
        return response;
      }
      print("⚠️ Got 429, retrying in ${delay.inSeconds}s...");
      await Future.delayed(delay);
    }
    return response;
  }

  /// ✅ Stronger category mapping
  String _getCategoryFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('electrical')) return 'Electrical Engineering';
    if (t.contains('machine learning')) return 'Machine Learning';
    if (t.contains('data science') || t.contains('data scientist')) return 'Data Science';
    if (t.contains('artificial intelligence') || t.contains('ai')) return 'Artificial Intelligence';
    if (t.contains('software') || t.contains('developer') || t.contains('programmer') || t.contains('coding')) {
      return 'Programming';
    }
    if (t.contains('management')) return 'Management Sciences';
    return 'General';
  }
}
