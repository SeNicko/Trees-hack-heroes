import 'package:app/pages/stats_page.dart';
import "package:flutter/material.dart";

import "../pages/home_page.dart";
import "../pages/garden_page.dart";

import "../widgets/bottom_navigtion.dart";

enum Pages { gardenPage, homePage, rankingPage }

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final List<Widget> _pages = [GardenPage(), HomePage(), StatsPage()];

  double _iconSize = 30;

  List<BottomNavigationBarItem> _items;
  @override
  void initState() {
    super.initState();
    _items = [
      BottomNavigationBarItem(
          icon: Icon(
            Icons.eco,
            size: _iconSize,
          ),
          label: "ogród"),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
          size: _iconSize,
        ),
        label: "strona główna",
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.bubble_chart,
          size: _iconSize,
        ),
        label: "statystyki",
      ),
    ];
  }

  int _currentPage = Pages.homePage.index;
  void _onTap(int index) => setState(() {
        _currentPage = index;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _pages[_currentPage],
      bottomNavigationBar: SizedBox(
          height: 100,
          child: BottomNavigation(
            items: _items,
            onTap: _onTap,
            currentPage: _currentPage,
          )),
    );
  }
}
