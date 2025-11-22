import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your profile content here
            const CircleAvatar(
              radius: 50,
              // Add your profile image here
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16.h),
            Text(
              'الملف الشخصي',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            // Add more profile information here
          ],
        ),
      ),
    );
  }
}
