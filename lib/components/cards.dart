import 'package:flutter/material.dart';

Widget buildCardBack() {
      return Image.asset(
      'images/carta-avesso.png',
      width: 80,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
      
      return Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
        ),
      );
  }
    );
  }

  // Imagem das cartas visíveis
  Widget buildCardFront(String imageUrl) {
    return GestureDetector(
      onTap: () {
        debugPrint('Carta clicada: $imageUrl');
      },
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }