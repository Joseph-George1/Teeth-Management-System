import 'package:flutter/material.dart';
import '../../../../core/theming/colors.dart';

class DoctorImageAndText extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const DoctorImageAndText({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    final isTablet = maxWidth >= 600;
    final imageSize = isTablet
        ? (maxWidth * 0.48).clamp(260.0, 420.0)
        : (maxWidth * 0.72).clamp(220.0, 340.0);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 40 : 20,
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image container
              Container(
                width: imageSize,
                height: imageSize,
                margin: EdgeInsets.only(
                  bottom: 32,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.mainBlue.withAlpha(40),
                      spreadRadius: 8,
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    cacheWidth: 1500,
                    isAntiAlias: true,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 50 : 32,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: isTablet ? 3 : 2,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: isTablet ? 36 : 24,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.mainBlue,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 44 : 20,
                ),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: isTablet ? 6 : 4,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: isTablet ? 22 : 16,
                    color: Colors.grey[600],
                    height: isTablet ? 1.7 : 1.6,
                  ),
                ),
              ),
              if (maxHeight < 700)
                SizedBox(height: 6)
              else
                SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
