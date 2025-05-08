import 'package:flutter/material.dart';
import 'package:saloon_guide/constants/app_colors.dart';
import 'package:saloon_guide/models/saloon_list/saloon_list_item.dart';
import 'package:saloon_guide/widgets/like_button.dart';

class NearbySaloonCard extends StatelessWidget {
  final SaloonListItem saloonData;

  const NearbySaloonCard({super.key, required this.saloonData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color.fromARGB(17, 255, 255, 255),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color.fromARGB(148, 158, 158, 158),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/tempory/1.jpg',
                  width: 210,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 210,
                      height: 200,
                      color: Colors.grey,
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.4 * 255).toInt()),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 2),
                      Text(
                        saloonData.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '(${saloonData.totalReviews.toString()})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              LikeButton(
                topPosition: 0,
                rightPosition: 0,
              )
            ],
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'OPEN NOW',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '9.00 - 21.00',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  saloonData.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18),
                    SizedBox(width: 5),
                    Text(
                      '0.7 km',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                Container(
                  width: 200,
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 1, color: Colors.grey),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/saloon');
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    child: Text(
                      'Book Now',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
