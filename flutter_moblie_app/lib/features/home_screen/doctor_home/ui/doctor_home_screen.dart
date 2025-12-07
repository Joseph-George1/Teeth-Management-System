// dart
              import 'package:flutter/material.dart';
              import 'package:flutter_screenutil/flutter_screenutil.dart';

              class DoctorHomeScreen extends StatelessWidget {
                const DoctorHomeScreen({Key? key}) : super(key: key);

                @override
                Widget build(BuildContext context) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: PreferredSize(
                      preferredSize: const Size(429.9976501464844, 73.05826568603516),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: 0.98.h,
                          right: 35.w,
                          bottom: 1.1.h,
                          left: 20.w,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.1,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Center(
                            child: Container(
                              width: 390.0042419433594.w,
                              height: 39.99340057373047.h,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 200.2962188720703.w,
                                      height: 40.99340057373047.h,
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 36.99217987060547.w,
                                            height: 39.99340057373047.h,
                                            child: Opacity(
                                              opacity: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10.r),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Padding(
                                                  padding: EdgeInsets.all(6.r),
                                                  child: Image.asset(
                                                    'assets/images/splash-logo.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 11.99.w),
                                          Transform.translate(
                                            offset: Offset(0, 0.71.h),
                                            child: SizedBox(
                                              width: 95.3163070678711.w,
                                              height: 27.0109806060791.h,
                                              child: Opacity(
                                                opacity: 1,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'لوحة التحكم',
                                                    style: TextStyle(
                                                      fontFamily: 'Cairo',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18.sp,
                                                      height: 27 / 18,
                                                      color: const Color(0xFF101828),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 39.99340057373047.w,
                                      height: 39.99340057373047.h,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Transform.translate(
                                      offset: Offset(-7.99.w, 0),
                                      child: SizedBox(
                                        width: 39.99340057373047.w,
                                        height: 39.99340057373047.h,
                                        child: Opacity(
                                          opacity: 1,
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 0.02.w),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10.r),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.menu,
                                                color: Color(0xFF101828),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    body: Container(
                      width: double.infinity,
                      // Use flexible height - avoid hardcoding large fixed heights
                      color: const Color(0xFFF9FAFB),
                      child: Padding(
                        padding: EdgeInsets.only(top: 24.h, left: 16.w, right: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Opacity(
                              opacity: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Opacity(
                                    opacity: 1,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'مرحبا د. كريستيانو رونالدو',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w700,
                                            height: 36 / 24,
                                            letterSpacing: 0,
                                            color: const Color(0xFF101828),
                                          ),
                                        ),
                                        SizedBox(height: 5.99.h),
                                        Text(
                                          'إليك نظرة عامة على حجوزاتك وأدائك',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w400,
                                            height: 22.5 / 15,
                                            letterSpacing: 0,
                                            color: const Color(0xFF475467),
                                          ),
                                        ),
                                        SizedBox(height: 24.h),

                                        // Grid of 4 containers
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 16.h,
                                          crossAxisSpacing: 16.w,
                                          childAspectRatio: 187 / 125.16,
                                          children: List.generate(4, (index) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16.r),
                                                border: Border.all(
                                                  color: const Color(0xFFE5E7EB),
                                                  width: 1.1,
                                                ),
                                                boxShadow: [
                                                  const BoxShadow(
                                                    color: Color(0x1A000000),
                                                    offset: Offset(0, 1),
                                                    blurRadius: 1,
                                                    spreadRadius: -1,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    offset: const Offset(0, 1),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Container ${index + 1}',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 16.sp,
                                                    color: const Color(0xFF101828),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                              ),
                        ]))])) ),
                      );
                    }
              }