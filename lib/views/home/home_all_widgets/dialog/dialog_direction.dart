import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/utils/colors.dart';

void dialogDirection (BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 1 ,),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(10),
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
                    "assets/icons/edit.svg",
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),

                  /// Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset("assets/icons/Close-X-Circle.svg",height: 29,width: 29,),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  "This option allows you to type in the directions from your permit using your device's keyboard.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
