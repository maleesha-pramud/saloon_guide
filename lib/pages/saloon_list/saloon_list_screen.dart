import 'package:flutter/material.dart';
import 'package:saloon_guide/constants/app_fonts.dart';
import 'package:saloon_guide/models/saloon_list/saloon_list_item.dart';
import 'package:saloon_guide/pages/saloon_list/widgets/saloon_list_card.dart';

class SaloonListScreen extends StatefulWidget {
  const SaloonListScreen({super.key});

  @override
  State<SaloonListScreen> createState() => _SaloonListScreenState();
}

class _SaloonListScreenState extends State<SaloonListScreen> {
  final List<SaloonListItem> _saloonList = [
    SaloonListItem(
      name: "Maleesha Saloon",
      address: "40/2 Panadura rd, Horana",
      rating: 5.0,
      totalReviews: 122,
    ),
    SaloonListItem(
      name: "Savithma Saloon",
      address: "77 Golden rd, Panadura",
      rating: 4.0,
      totalReviews: 97,
    ),
    SaloonListItem(
      name: "Leo Saloon",
      address: "50 Kasbawa rd, Karandana",
      rating: 4.4,
      totalReviews: 44,
    ),
    SaloonListItem(
      name: "Maleesha Saloon",
      address: "40/2 Panadura rd, Horana",
      rating: 5.0,
      totalReviews: 123,
    ),
    SaloonListItem(
      name: "Savithma Saloon",
      address: "77 Golden rd, Panadura",
      rating: 4.0,
      totalReviews: 100,
    ),
    SaloonListItem(
      name: "Leo Saloon",
      address: "50 Kasbawa rd, Karandana",
      rating: 4.4,
      totalReviews: 52,
    ),
  ];

  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<SaloonListItem> get _filteredSaloonList {
    if (_searchQuery.isEmpty) {
      return _saloonList;
    }
    return _saloonList
        .where((saloon) =>
            saloon.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            saloon.address.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
                        onChanged: (value) => {
                          setState(() {
                            _searchQuery = value;
                          })
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        icon: Icon(Icons.close),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSaloonList.length,
                itemBuilder: (context, index) {
                  return SaloonListCard(
                    saloonData: _filteredSaloonList[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
