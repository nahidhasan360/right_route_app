import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/utils/colors.dart';

void showPermitDialog(BuildContext context) {
  showDialog(

    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 1 ,),
        backgroundColor: Colors.transparent,

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
                    "assets/icons/Import_white.svg",
                    width: 29,
                    height: 29,
                    color: Colors.white,
                  ),

                  /// Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset("assets/icons/Close-X-Circle.svg" ,width: 30,
                      height: 30,),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  "This option scans a PDF of your permit and extracts the directions from it.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// -------- MAIN TEXT 02 --------
              Flexible(
                child: Text(
                  "Your permit needs to be accessible from this device or available from your iCloud, Google Drive, or Dropbox storage.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              )


            ],
          ),
        ),
      );
    },
  );
}
