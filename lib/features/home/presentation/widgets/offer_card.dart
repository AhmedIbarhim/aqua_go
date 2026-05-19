import 'package:flutter/material.dart';
import '../../data/models/offer_model.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offerModel, this.atHome = true});

  final OfferModel offerModel;
  final bool atHome;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: atHome == true ? height * 0.4 : width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(offerModel.image, fit: BoxFit.fill),
      ),
    );
  }
}
