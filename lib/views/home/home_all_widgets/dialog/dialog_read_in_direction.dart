import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../utils/colors.dart';

void dialogReadInDirection (BuildContext context) {
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
                    "assets/icons/Mic-white.svg",
                    width: 29,
                    height: 29,
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
                  "You can use your device's microphone to read in the directions from your permit.",
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
