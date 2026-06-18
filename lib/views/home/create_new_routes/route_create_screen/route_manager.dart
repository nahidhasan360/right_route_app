import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../global_widgets/custom_navbar.dart';
import '../../../../../utils/assets_manager.dart';

class RouteManager extends StatelessWidget {
  const RouteManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              ImageManager.mapBackground,
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                bottom: 100.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),

                  // Logo
                  Container(
                    width: 225.w,
                    height: 112.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageManager.splashScreenLogo),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Title
                  Text(
                    'ROUTE MANAGEMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontFamily: 'League Gothic',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.50,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 30.h),

                  // Add Permit Button
                  GestureDetector(
                    onTap: () {
                      // Navigate to Add Permit Screen
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF48436), // Matches screenshot's orange
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/New-Route-white.svg', // Reusing the icon seen in image
                            width: 24.w,
                            height: 24.h,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'ADD PERMIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26.sp,
                                fontFamily: 'League Gothic',
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // Subtitle under button
                  Text(
                    'Create your first route to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }
}
