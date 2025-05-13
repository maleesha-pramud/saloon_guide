import 'package:flutter/material.dart';
import 'package:saloon_guide/constants/app_fonts.dart';
import 'package:saloon_guide/models/saloon_list/saloon_list_item.dart';
import 'package:saloon_guide/pages/home/widgets/greeting_text.dart';
import 'package:saloon_guide/pages/home/widgets/latest_saloon_card.dart';
import 'package:saloon_guide/pages/home/widgets/nearby_saloon_card.dart';
import 'package:saloon_guide/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final saloonData = SaloonListItem(
    name: "Maleesha Saloon",
    address: "40/2 Panadura rd, Horana",
    rating: 5.0,
    totalReviews: 122,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      endDrawer: CustomDrawer(),
      // We need to use a Builder to get the correct BuildContext that has Scaffold as an ancestor
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingText(),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(148, 158, 158, 158),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromARGB(17, 255, 255, 255),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 15),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/saloon-list');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 23,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'LATEST VISIT',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(height: 10),
                LatestSaloonCard(saloonData: saloonData),
                SizedBox(height: 20),
                Text(
                  'NEARBY BABERSHOPS',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NearbySaloonCard(saloonData: saloonData),
                      SizedBox(width: 10),
                      NearbySaloonCard(saloonData: saloonData),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
