import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../../../features/categories/ui/categories_screen.dart';
import '../../../features/chat/ui/chat_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;
  const MainLayoutScreen({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;
  late final List<Widget> _screens;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _screens = const [
      CategoriesScreen(),
      ChatScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xff0B8FAC),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined, color: const Color(0xFF0B8FAC)),
            activeIcon: Icon(Icons.category),
            label: 'الاقسام',
          ),
          // other items...

      BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, color: const Color(0xFF0B8FAC)),
            activeIcon: Icon(Icons.chat, color: const Color(0xFF0B8FAC)),
            label: 'ثوثة المساعد',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined, color: const Color(0xFF0B8FAC)),
            activeIcon: Icon(Icons.calendar_today, color: const Color(0xFF0B8FAC)),
            label: 'المواعيد',

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, color: const Color(0xFF0B8FAC)),
            //activeIcon: Icon(Icons.chat, color: const Color(0xFF0B8FAC)),
            label: 'الملف الشخصي',

          ),

    ]));
  }
}
