import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theming/styles.dart';
import '../../../core/utils/text_utils.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCategories = [];
  final FocusNode _searchFocusNode = FocusNode();
  
  // Sample categories data
  final List<Map<String, dynamic>> categories = [
    {'name': 'تقويم الأسنان', 'iconPath': 'assets/svg/تقويم اسنان.svg'},
    {'name': 'حشو الأسنان', 'iconPath': 'assets/svg/حشو اسنان.svg'},
    {'name': 'تبييض الأسنان', 'iconPath': 'assets/svg/تبيض اسنان.svg'},
    {'name': 'زراعة الأسنان', 'iconPath': 'assets/svg/زراعه اسنان.svg'},
    {'name': 'خلع الاسنان', 'iconPath': 'assets/svg/خلع اسنان.svg'},
    {'name': 'تركيبات الأسنان', 'iconPath': 'assets/svg/تركيبات اسنان.svg'},
    {'name': 'فحص شامل', 'iconPath': 'assets/svg/فحص شامل.svg'},
   // {'name': 'أمراض اللثة'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredCategories = List.from(categories);
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
        _filteredCategories = List.from(categories);
      } else {
        _filteredCategories = categories
            .where((category) => category['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'الأقسام',
          style: TextStyles.font24BlueBold.copyWith(
            color: const Color(0xFF0B8FAC), // #0B8FAC color
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.loginScreen,
              (route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Search Icon
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.search, color: Colors.grey, size: 24),
                      ),
                      // Search Text
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن قسم...',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      // Microphone Icon
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
                // Search Suggestions
                if (_searchController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        final query = _searchController.text.toLowerCase();
                        final categoryName = category['name'];
                        final startIndex = categoryName.toLowerCase().indexOf(query);
                        
                        return ListTile(
                          title: RichText(
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              children: _buildHighlightedText(categoryName, query),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          onTap: () => _selectSuggestion(categoryName),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          minLeadingWidth: 0,
                          horizontalTitleGap: 0,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Categories Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    name: _filteredCategories[index]['name'],
                    iconPath: _filteredCategories[index]['iconPath'],
                    color: const Color(0xFF7BC1B7), // #7BC1B7 color
                    searchQuery: _searchController.text.isNotEmpty
                        ? _searchController.text
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
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
}

class CategoryCard extends StatelessWidget {
  static const Color _textColor = Colors.white;
  final String name;
  final String? iconPath;
  final Color color;
  final String? searchQuery;

  const CategoryCard({
    Key? key,
    required this.name,
    this.iconPath,
    required this.color,
    this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.doctorsScreen,
          arguments: {'category': name},
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SvgPicture.asset(
                  iconPath!,
                  width: 200,
                  height: 80,
                ),
              ),
            if (searchQuery != null && searchQuery!.isNotEmpty)
              RichText(
                text: TextSpan(
                  children: _buildHighlightedText(name, searchQuery!),
                  style: const TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                name,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
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