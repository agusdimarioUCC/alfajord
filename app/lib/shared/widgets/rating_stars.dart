import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onRatingSelected,
    this.size = 20,
  });

  final double rating;
  final double size;
  final ValueChanged<double>? onRatingSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = rating >= starValue;
        final isHalf = rating > starValue - 1 && rating < starValue;
        return IconButton(
          onPressed: onRatingSelected == null
              ? null
              : () => onRatingSelected!(starValue.toDouble()),
          icon: Icon(
            isFilled
                ? Icons.star
                : isHalf
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }
}
