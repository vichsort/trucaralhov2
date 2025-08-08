import 'package:flutter/material.dart';

const double kCardWidth = 57;
const double kCardHeight = 80;
final BorderRadius kCardRadius = BorderRadius.circular(8);

BoxDecoration _cardBaseDecoration = BoxDecoration(
  borderRadius: kCardRadius,
  border: Border.all(color: Colors.grey, width: 1),
);

Widget buildCardBack({VoidCallback? onTap}) {
  final child = Image.asset(
    'images/carta-avesso.png',
    width: kCardWidth,
    height: kCardHeight,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) {
      return Container(
        width: kCardWidth,
        height: kCardHeight,
        decoration: _cardBaseDecoration.copyWith(color: Colors.black),
      );
    },
  );

  if (onTap == null) return child;
  return GestureDetector(onTap: onTap, child: child);
}

Widget buildTableCard(String imageUrl) {
  return Container(
    width: kCardWidth,
    height: kCardHeight,
    decoration: _cardBaseDecoration,
    child: ClipRRect(
      borderRadius: kCardRadius,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) {
          return Container(color: Colors.black);
        },
      ),
    ),
  );
}

Widget buildCardFront(
  String imageUrl,
  int index,
  Function(int) onCartaTapped,
  bool enabled,
) {
  return GestureDetector(
    onTap: enabled ? () => onCartaTapped(index) : null,
    child: Opacity(
      opacity: enabled ? 1.0 : 0.6, // escurece um pouco
      child: ColorFiltered(
        colorFilter: enabled
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: Container(
          width: kCardWidth,
          height: kCardHeight,
          decoration: _cardBaseDecoration,
          child: ClipRRect(
            borderRadius: kCardRadius,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) {
                return Container(color: Colors.black);
              },
            ),
          ),
        ),
      ),
    ),
  );
}
