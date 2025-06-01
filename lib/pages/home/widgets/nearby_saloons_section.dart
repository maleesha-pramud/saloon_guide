import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saloon_guide/config/api_config.dart';
import 'package:saloon_guide/models/saloon_list/saloon_list_item.dart';
import 'package:saloon_guide/pages/home/widgets/nearby_saloon_card.dart';

class NearbySaloonsSection extends StatefulWidget {
  const NearbySaloonsSection({super.key});

  @override
  State<NearbySaloonsSection> createState() => _NearbySaloonsSectionState();
}

class _NearbySaloonsSectionState extends State<NearbySaloonsSection> {
  final _storage = const FlutterSecureStorage();
  List<SaloonListItem> _saloonList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final Map<String, String> _saloonData = {
    'latitude': '6.723482562686678',
    'longitude': '80.08269267296515',
  };

  @override
  void initState() {
    super.initState();
    _fetchNearbySaloons();
  }

  Future<void> _fetchNearbySaloons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      final requestUrl = Uri.parse(
          '${ApiConfig.nearbySaloonListUrl}?latitude=${_saloonData['latitude']}&longitude=${_saloonData['longitude']}');

      final response = await http.get(requestUrl, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response: $responseData');
      }
      if (responseData['status'] == true) {
        setState(() {
          _saloonList = (responseData['data'] as List)
              .map((item) => SaloonListItem.fromJson(item))
              .toList();
        });
      } else {
        if (kDebugMode) {
          print('Error fetching nearby saloons: ${responseData['message']}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching nearby saloons: $error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEARBY BABERSHOPS',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
        SizedBox(height: 10),
        _isLoading
            ? _buildLoadingIndicator()
            : _saloonList.isEmpty
                ? _buildEmptyView()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _saloonList
                          .map((saloon) => NearbySaloonCard(saloonData: saloon))
                          .toList(),
                    ),
                  )
      ],
    );
  }
}

Widget _buildLoadingIndicator() {
  return Center(
    child: CircularProgressIndicator(),
  );
}

Widget _buildEmptyView() {
  return Center(
    child: Text(
      'No nearby saloons found.',
      style: TextStyle(color: Colors.grey),
    ),
  );
}
