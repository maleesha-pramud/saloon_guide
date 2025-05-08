import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    this.topPosition,
    this.bottomPosition,
    this.leftPosition,
    this.rightPosition,
  });

  final double? topPosition;
  final double? bottomPosition;
  final double? leftPosition;
  final double? rightPosition;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPosition,
      bottom: widget.bottomPosition,
      left: widget.leftPosition,
      right: widget.rightPosition,
      child: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: 24.0,
        ),
        tooltip: 'Add to favorites',
        splashRadius: 20.0,
      ),
    );
  }
}
