import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailEditWidgets extends StatelessWidget {
  final String email;
  final VoidCallback onEditTap;

  const EmailEditWidgets({
    super.key,
    required this.email,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 382.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // IMPORTANT FIX ✔
        mainAxisAlignment: MainAxisAlignment.start, // FIX ✔
        children: [
          /// TOP TEXT
          Text(
            "Create your account using",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              height: 1.44.h,
            ),
          ),

          SizedBox(height: 6.h),

          /// INLINE ROW (email + edit)
          Row(
            mainAxisSize: MainAxisSize.min, // FIX ✔ keeps row tight
            children: [
              Text(
                email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w900,
                  height: 1.44.h,
                ),
              ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: onEditTap,
                child: Text(
                  "edit",
                  style: TextStyle(
                    color: Color(0xFF9DACF5),
                    fontSize: 18.sp,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    height: 1.44.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
