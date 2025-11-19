import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weather App",
      debugShowCheckedModeBanner: false,
      home: WeatherApp()
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> with SingleTickerProviderStateMixin {
  int _index = 0;
  late TabController _tabController;
  String _search = "";
  bool _geolocation = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState((){
        _index = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getTab() {
    switch(_index) {
      case 0: return "Currently";
      case 1: return "Today";
      case 2: return "Weekly";
      default: return "";
    }
  }

  String displayText() {
    String tab = getTab();

    if (_geolocation) {
      return tab + "\nGeolocation";
    } else if (!_search.isEmpty) {
      return tab + "\n"  + _search;
    } else {
      return tab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: "Search location..."),
          onSubmitted: (value) {
            setState(() {
              _search = value;
              _geolocation = false;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              setState(() {
                _geolocation = true;
                _search = "";
                _searchController.clear();
              });
            }
          )
        ]
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text(displayText(), style: TextStyle(fontSize: 24), textAlign: TextAlign.center,)),
          Center(child: Text(displayText(), style: TextStyle(fontSize: 24), textAlign: TextAlign.center,)),
          Center(child: Text(displayText(), style: TextStyle(fontSize: 24), textAlign: TextAlign.center,)),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
            _tabController.animateTo(index);
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: "Currently",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Today",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: "Weekly",
          ),
        ]
      ), 
    );
  }
}
