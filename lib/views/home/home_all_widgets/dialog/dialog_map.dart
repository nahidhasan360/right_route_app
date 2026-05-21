import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../utils/colors.dart';

void dialogMap(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 1 ,),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.medGray,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// -------- TOP: PDF icon + Close icon --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Left SVG PDF icon
                  SvgPicture.asset(
                    "assets/icons/Vector-hand.svg",
                    width: 23,
                    height: 23,
                    color: Colors.white,
                  ),

                  /// Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset("assets/icons/Close-X-Circle.svg",height: 30,width: 30,),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  "This option gives you a map where you can tap to add waypoints where each turn and exit are specified from your permit directions.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// -------- MAIN TEXT 02 --------
              // Flexible(
              //   child: Text(
              //     "Saving the photo to this device will make it available to this app.",
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 15,
              //       height: 1.4,
              //     ),
              //   ),
              // )


            ],
          ),
        ),
      );
    },
  );
}
