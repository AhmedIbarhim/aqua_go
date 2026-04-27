import 'package:flutter/material.dart';
import '../data/models/offer_model.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offerModel});

  final OfferModel offerModel;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width - 82,
      height: height * 0.20,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(offerModel.image, fit: BoxFit.cover),
      ),
    );
  }
}
