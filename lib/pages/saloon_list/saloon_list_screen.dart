import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saloon_guide/constants/app_fonts.dart';
import 'package:saloon_guide/models/saloon_list/saloon_list_item.dart';
import 'package:saloon_guide/pages/saloon_list/widgets/saloon_list_card.dart';
import 'package:saloon_guide/config/api_config.dart';

class SaloonListScreen extends StatefulWidget {
  const SaloonListScreen({super.key});

  @override
  State<SaloonListScreen> createState() => _SaloonListScreenState();
}

class _SaloonListScreenState extends State<SaloonListScreen> {
  final _storage = const FlutterSecureStorage();
  List<SaloonListItem> _saloonList = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSaloons();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreSaloons();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSaloons({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
      });
    }

    if (!_hasMoreData && !refresh) return;

    setState(() {
      _isLoading = _currentPage == 1;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _limit.toString(),
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final uri = Uri.http(ApiConfig.baseUrl, '/api/v1/saloons', queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      print('Response: $responseData');

      if (responseData['status'] == true) {
        final saloons = responseData['data']['saloons'] as List;
        final pagination = responseData['data']['pagination'];

        setState(() {
          if (_currentPage == 1) {
            _saloonList =
                saloons.map((json) => SaloonListItem.fromJson(json)).toList();
          } else {
            _saloonList.addAll(
                saloons.map((json) => SaloonListItem.fromJson(json)).toList());
          }

          // Add null safety when accessing pagination data
          _totalPages = pagination?['totalPages'] ?? 1;
          _hasMoreData = _currentPage < _totalPages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        _handleError(responseData['message'] ?? 'Failed to load saloons');
      }
    } catch (e) {
      _handleError('Network error: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  Future<void> _loadMoreSaloons() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    await _fetchSaloons();
  }

  Future<void> _onRefresh() async {
    await _fetchSaloons(refresh: true);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    // Debounce search requests
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value) {
        _fetchSaloons(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Text(
          'Saloon Guide',
          style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.babasNeue),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearchActive ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearchActive) {
                  _searchController.clear();
                  _searchQuery = '';
                  _fetchSaloons(refresh: true);
                }
                _isSearchActive = !_isSearchActive;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
            if (_isSearchActive) ...[
              Container(
                padding: EdgeInsets.only(left: 10),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(148, 158, 158, 158),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromARGB(17, 255, 255, 255)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                          hintText: 'Search saloons...',
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                            _fetchSaloons(refresh: true);
                          });
                        },
                        icon: Icon(Icons.close),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
            SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _hasError
                      ? _buildErrorView()
                      : _saloonList.isEmpty
                          ? _buildEmptyView()
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    _saloonList.length + (_hasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _saloonList.length) {
                                    return _buildLoadMoreIndicator();
                                  }
                                  return SaloonListCard(
                                    saloonData: _saloonList[index],
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchSaloons(refresh: true),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined,
              size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No saloons found matching "$_searchQuery"'
                : 'No saloons available',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_searchQuery.isNotEmpty) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _fetchSaloons(refresh: true);
                });
              },
              child: Text('Clear Search'),
            ),
          ]
        ],
      ),
    );
  }
}
