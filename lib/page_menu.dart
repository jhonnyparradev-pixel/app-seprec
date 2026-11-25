import 'package:flutter/material.dart';
import 'package:seprec/pages/ContactoScreen.dart';
import 'package:seprec/pages/GeoreferenciacionScreen.dart';
import 'package:seprec/pages/mas_info.dart';
import 'package:seprec/pages/page_screen.dart';
import 'package:seprec/pages/scannqr.dart';

class PageMenu extends StatefulWidget {
  @override
  _PageMenuState createState() => _PageMenuState();
}

class _PageMenuState extends State<PageMenu> {
  int _currentIndex = 2;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GeoreferenciacionScreen(),
      ContactoScreen(),
      InicioScreen(),
      BarcodeScanner(onBack: () => onTabTapped(2)),
      MasInfo(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1F2B31),
            ),
          ),
          _pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: _currentIndex == 3
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 4),
              child: Container(
                height: 68,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF193B4C),
                      Color(0xFF102D40),
                      Color(0xFF0B2233),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: const Color(0xFF39788A),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF071A29).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: const Color(0xFF30BFA5).withOpacity(0.08),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNavItem(Icons.location_on, 'Cerca de mí', 0),
                    _buildNavItem(Icons.phone_outlined, 'Contacto', 1),
                    _buildNavItem(Icons.home_outlined, 'Inicio', 2),
                    _buildNavItem(Icons.qr_code_2, 'Escanear', 3),
                    _buildNavItem(Icons.more_vert, 'Más', 4),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () => onTabTapped(index),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isSelected ? null : BorderRadius.circular(10),
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF087F78),
                              Color(0xFF064B50),
                            ],
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFF142638),
                              Color(0xFF0A1726),
                            ],
                          ),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF35D6C5)
                          : const Color(0xFF263F52),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF20CFC0).withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    size: isSelected ? 21 : 18,
                    color: isSelected ? Colors.white : const Color(0xFF8DA9B8),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF50E4D6)
                        : const Color(0xFF91A5B5),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
