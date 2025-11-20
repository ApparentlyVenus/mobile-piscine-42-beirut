import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'city.dart';
import 'geocoding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Weather App",
        debugShowCheckedModeBanner: false,
        home: WeatherApp());
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late TabController _tabController;

  String _search = "";
  final TextEditingController _searchController = TextEditingController();

  String _location = "";
  bool _locationPermission = false;

  List<City> _cities = [];
  bool _showCities = false;
  final Geocoding _geocoding = Geocoding();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _index = _tabController.index;
      });
    });
    getLocation();
  }

  Future<void> getLocation() async {
    try {
      bool service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        setState(() {
          _location = "Location services are disabled";
          _locationPermission = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Please enable location permissions";
            _locationPermission = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location are denied forever";
          _locationPermission = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String? cityName = await _geocoding.getCityFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        if (cityName != null) {
          _location = cityName +
              ", " +
              position.latitude.toString() +
              ", " +
              position.longitude.toString();
        } else {
          _location = "Current location: " +
              position.latitude.toString() +
              ", " +
              position.longitude.toString();
        }
        _locationPermission = true;
      });
    } catch (e) {
      setState(() {
        _location = "Error getting location: " + e.toString();
        _locationPermission = false;
      });
    }
  }

  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      setState(() {
        _cities = [];
        _showCities = false;
      });
      return;
    }
    List<City> cities = await _geocoding.searchCities(query);
    setState(() {
      _cities = cities;
      _showCities = true;
    });
  }

  void selectCity(City city) {
    setState(() {
      _searchController.text = city.displayName;
      _location = city.displayName +
          "\n" +
          city.latitude.toString() +
          ", " +
          city.longitude.toString();
      _showCities = false;
      _cities = [];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getTab() {
    switch (_index) {
      case 0:
        return "Currently";
      case 1:
        return "Today";
      case 2:
        return "Weekly";
      default:
        return "";
    }
  }

  String displayText() {
    String tab = getTab();

    if (!_location.isEmpty) {
      return tab + "\n" + _location;
    } else if (_search.isNotEmpty) {
      return tab + "\n" + _search;
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
            decoration: InputDecoration(
              hintText: "Search location...",
              border: InputBorder.none,
            ),
            onChanged: (value) {
              searchCities(value);
            },
            onSubmitted: (value) async {
              if (!value.isEmpty) {
                List<City> cities = await _geocoding.searchCities(value);
                if (!cities.isEmpty) {
                  selectCity(cities.first);
                }
              }
            },
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () {
                  getLocation();
                  setState(() {
                    _search = "";
                    _searchController.clear();
                    _cities = [];
                  });
                },
              )
            ]
          ),
          body: Stack(
            children: [
              TabBarView(
                controller: _tabController, 
                children: [
                  Center(
                    child: Text(
                      displayText(),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      displayText(),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),             
                  ),
                  Center(
                    child: Text(
                      displayText(),
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]
              ),
            ]
          )
          },
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _index,
              onTap: (index) {
                setState(() {
                  _index = index;
                  _tabController.animateTo(index);
                });
              },
              items: const [
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
          ),
    );
  }
}
