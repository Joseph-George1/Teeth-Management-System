import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theming/styles.dart';
import '../../../core/utils/text_utils.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _filteredDoctors = [];
  final FocusNode _searchFocusNode = FocusNode();
  final Map<String, bool> _favorites = {};
  
  // Sample doctors data
  final List<Map<String, dynamic>> doctors = [
    {'name': 'د/ جمال مازن', 'specialty': 'تقويم الأسنان', 'rating': 4.8, 'image': 'assets/images/دكتور.png', 'doctorType': 'male'},
    {'name': 'د/ لوجي جمال', 'specialty': 'حشو الأسنان', 'rating': 4.9, 'image': 'assets/images/دكتوره.png', 'doctorType': 'female'},
    {'name': 'د/ جورج وهبه', 'specialty': 'زراعة الأسنان', 'rating': 4.7, 'image': 'assets/images/دكتور.png', 'doctorType': 'male'},
    {'name': 'د/ فاطمة رمضان', 'specialty': 'تبييض الأسنان', 'rating': 4.9, 'image': 'assets/images/دكتوره.png', 'doctorType': 'female'},
    {'name': 'ا.د/اشرف توفيق', 'specialty': 'تركيبات الأسنان', 'rating': 4.8, 'image': 'assets/images/دكتور كبير.png', 'doctorType': 'senior'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredDoctors.addAll(doctors);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors.clear();
        _filteredDoctors.addAll(doctors);
      } else {
        _filteredDoctors.clear();
        _filteredDoctors.addAll(doctors.where((doctor) =>
            doctor['name'].toLowerCase().contains(query.toLowerCase()) ||
            doctor['specialty'].toLowerCase().contains(query.toLowerCase())
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'جميع الأطباء',
          style: TextStyles.font24BlueBold.copyWith(
            color: const Color(0xFF25B4E5),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9).withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: Colors.grey, size: 24),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن طبيب...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.grey, size: 24),
                    onPressed: () {
                      // TODO: Add voice search functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
               // final doctor = _filteredDoctors[index];
                final doctorName = doctor['name'];
                return DoctorCard(
                  name: doctorName,
                  specialty: doctor['specialty'],
                  rating: doctor['rating'],
                  image: doctor['image'],
                  doctorType: doctor['doctorType'] ?? 'male',
                  searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
                  isFavorite: _favorites[doctorName] ?? false,
                  onFavoriteChanged: (isFavorite) {
                    setState(() {
                      _favorites[doctorName] = isFavorite;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String doctorType;
  final String name;
  final String specialty;
  final double rating;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final String image;
  final String? searchQuery;

  const DoctorCard({
    Key? key,
    required this.doctorType,
    required this.name,
    required this.specialty,
    required this.rating,
    this.isFavorite = false,
    this.onFavoriteChanged,
    required this.image,
    this.searchQuery,
  }) : super(key: key);

  // Helper method to get the correct SVG path based on doctor type
  String _getDoctorSvgPath() {
    switch (doctorType.toLowerCase()) {
      case 'female':
        return 'assets/images/دكتوره.png';
      case 'senior':
        return 'assets/images/دكتور كبير.png';
      case 'male':
      default:
        return 'assets/images/دكتور.png';
    }
  }

  // Helper method to load SVG with error handling
  Widget _buildSvgImage(String path) {
    return SvgPicture.asset(
      path,
      fit: BoxFit.contain,
      placeholderBuilder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(30.0),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final matches = <TextSpan>[];
    var start = 0;
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    while (true) {
      final matchIndex = textLower.indexOf(queryLower, start);
      if (matchIndex == -1) {
        if (start < text.length) {
          matches.add(TextSpan(
            text: text.substring(start),
            style: const TextStyle(color: Colors.black87),
          ));
        }
        break;
      }

      if (matchIndex > start) {
        matches.add(TextSpan(
          text: text.substring(start, matchIndex),
          style: const TextStyle(color: Colors.black87),
        ));
      }

      matches.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: const TextStyle(
            color: Color(0xFF0B8FAC),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = matchIndex + query.length;
    }

    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final isSenior = doctorType.toLowerCase() == 'senior';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD2EBE7).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                // TODO: Navigate to doctor details
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF0B8FAC),
                              BlendMode.srcIn,
                            ),
                            child: _buildSvgImage(_getDoctorSvgPath()),
                          ),
                        ),
                      ),

                      // Doctor Info
                      const SizedBox(width: 12),
                      Expanded(
                        child: Stack(
                          children: [
                            // Name and specialty in the center
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSenior)
                                    Text(
                                      'خبير',
                                      style: const TextStyle(
                                        color: Color(0xFF0B8FAC),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (isSenior) const SizedBox(height: 4),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    specialty,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Rating on the right side
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toString(),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Centered book button at the bottom
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Handle booking
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25B8E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                        ),
                        child: const Text(
                          'احجز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Favorite icon in the bottom-right corner
           /* Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  if (onFavoriteChanged != null) {
                    onFavoriteChanged!(!isFavorite);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.blue : Colors.grey,
                    size: 28,
                  ),
                ),
              ),
            ),*/
              ),
            )
          ],
        ),
      ),
    );
  }
}
