import "package:flutter/material.dart";

class BottomNavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final int currentPage;
  final Function onTap;

  BottomNavigation({this.items, this.currentPage, this.onTap});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    final TextStyle _selectedItemTextStyle = TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 18.0,
        fontWeight: FontWeight.w600);

    final TextStyle _unselectedItemStyle = TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w600);

    return SizedBox(
      height: 100,
      child: BottomNavigationBar(
          backgroundColor: Theme.of(context).backgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
          selectedLabelStyle: _selectedItemTextStyle,
          unselectedLabelStyle: _unselectedItemStyle,
          currentIndex: widget.currentPage,
          elevation: 0,
          items: widget.items,
          onTap: widget.onTap),
    );
  }
}
