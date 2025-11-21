import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'city.dart';
import 'weather.dart';
import 'services/geocoding_service.dart';
import 'services/weather_service.dart';

void main() {
  runApp(MyApp());
} // main

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weather App",
      debugShowCheckedModeBanner: false,
      home: WeatherApp(),
    ); // MaterialApp
  } // build
} // MyApp

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
} // WeatherApp

class _WeatherAppState extends State<WeatherApp>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  String _location = "";
  bool _locationPermission = false;

  List<City> _cities = [];
  bool _showCities = false;
  
  final Geocoding geocoding = Geocoding();
  final Weather _Weather = Weather();
  
  WeatherData? _weatherData;  // Stores all weather data
  bool _isLoading = false;    // Loading state
  String? _errorMessage;       // Error message

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _index = _tabController.index;
      }); // setState
    }); // addListener
    
    getLocation();
  } // initState

  Future<void> getLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    }); // setState

    try {
      bool service = await Geolocator.isLocationServiceEnabled();
      if (!service) {
        setState(() {
          _location = "Location services are disabled";
          _locationPermission = false;
          _isLoading = false;
        }); // setState
        return;
      } // if !service

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Please enable location permissions";
            _locationPermission = false;
            _isLoading = false;
          }); // setState
          return;
        } // if denied
      } // if denied

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location permissions are permanently denied";
          _locationPermission = false;
          _isLoading = false;
        }); // setState
        return;
      } // if deniedForever

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ); // getCurrentPosition

      // Get city name from coordinates
      String? cityName = await geocoding.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      ); // getCityFromCoordinates

      String locationName = cityName ?? "Current Location";

      // Fetch weather data
      WeatherData? weather = await _Weather.getWeather(
        position.latitude,
        position.longitude,
        locationName,
      ); // getWeather

      setState(() {
        _location = locationName;
        _weatherData = weather;
        _locationPermission = true;
        _isLoading = false;
      }); // setState
    } catch (e) {
      setState(() {
        _location = "Error getting location";
        _errorMessage = e.toString();
        _locationPermission = false;
        _isLoading = false;
      }); // setState
    } // try-catch
  } // getLocation

  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      setState(() {
        _cities = [];
        _showCities = false;
      }); // setState
      return;
    } // if empty

    List<City> cities = await geocoding.searchCities(query);
    setState(() {
      _cities = cities;
      _showCities = cities.isNotEmpty;
    }); // setState
  } // searchCities

  Future<void> selectCity(City city) async {
    setState(() {
      _searchController.text = city.displayName;
      _showCities = false;
      _cities = [];
      _isLoading = true;
      _errorMessage = null;
    }); // setState

    // Fetch weather for selected city
    WeatherData? weather = await _Weather.getWeather(
      city.latitude,
      city.longitude,
      city.displayName,
    ); // getWeather

    setState(() {
      _location = city.displayName;
      _weatherData = weather;
      _isLoading = false;
    }); // setState
  } // selectCity

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  } // dispose

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
    } // switch
  } // getTab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
          decoration: InputDecoration(
            hintText: "Search location...",
            hintStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
            border: InputBorder.none,
          ), // InputDecoration
          onChanged: (value) {
            searchCities(value);
          }, // onChanged
          onSubmitted: (value) async {
            if (value.isNotEmpty) {
              List<City> cities = await geocoding.searchCities(value);
              if (cities.isNotEmpty) {
                selectCity(cities.first);
              } // if cities not empty
            } // if value not empty
          }, // onSubmitted
        ), // TextField
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              getLocation();
              setState(() {
                _searchController.clear();
                _cities = [];
                _showCities = false;
              }); // setState
            }, // onPressed
          ), // IconButton
        ], // actions
      ), // AppBar
      body: Stack(
        children: [
          // Main content (tabs)
          if (_isLoading)
            Center(child: CircularProgressIndicator()), // Loading indicator
          
          if (!_isLoading && _weatherData == null)
            Center(
              child: Text(
                _errorMessage ?? "No weather data available",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ), // Text
            ), // Center - no data
          
          if (!_isLoading && _weatherData != null)
            TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Currently
                _buildCurrentlyTab(),
                // Tab 2: Today
                _buildTodayTab(),
                // Tab 3: Weekly
                _buildWeeklyTab(),
              ], // TabBarView children
            ), // TabBarView

          // Suggestion list overlay
          if (_showCities)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      City city = _cities[index];
                      return ListTile(
                        title: Text(city.name),
                        subtitle: Text(city.region + ", " + city.country),
                        onTap: () => selectCity(city),
                      ); // ListTile
                    }, // itemBuilder
                  ), // ListView.builder
                ), // Container
              ), // Material
            ), // Positioned
        ], // Stack children
      ), // Stack body
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
            _tabController.animateTo(index);
          }); // setState
        }, // onTap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: "Currently",
          ), // BottomNavigationBarItem 1
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Today",
          ), // BottomNavigationBarItem 2
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: "Weekly",
          ), // BottomNavigationBarItem 3
        ], // items
      ), // BottomNavigationBar
    ); // Scaffold
  } // build

  // Build Currently tab
  Widget _buildCurrentlyTab() {
    if (_weatherData?.current == null) {
      return Center(child: Text("No current weather data"));
    } // if no current data

    CurrentWeather current = _weatherData!.current!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _weatherData!.location,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ), // Text - location
          SizedBox(height: 8),
          Text(
            "${_weatherData!.latitude.toStringAsFixed(2)}, ${_weatherData!.longitude.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
          ), // Text - coordinates
          SizedBox(height: 24),
          Text(
            "${current.temp.toStringAsFixed(1)}°C",
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ), // Text - temperature
          SizedBox(height: 8),
          Text(
            current.weather,
            style: TextStyle(fontSize: 24),
          ), // Text - weather description
          SizedBox(height: 16),
          Text(
            "Wind Speed: ${current.windSpeed.toStringAsFixed(1)} km/h",
            style: TextStyle(fontSize: 18),
          ), // Text - wind speed
        ], // Column children
      ), // Column
    ); // SingleChildScrollView
  } // _buildCurrentlyTab

  // Build Today tab
  Widget _buildTodayTab() {
    if (_weatherData?.hourly.isEmpty ?? true) {
      return Center(child: Text("No hourly weather data"));
    } // if no hourly data

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            _weatherData!.location,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ), // Text
        ), // Padding
        Expanded(
          child: ListView.builder(
            itemCount: _weatherData!.hourly.length,
            itemBuilder: (context, index) {
              HourlyWeather hour = _weatherData!.hourly[index];
              return ListTile(
                leading: Text(
                  hour.formattedTime,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ), // Text - time
                title: Text("${hour.temp.toStringAsFixed(1)}°C"),
                subtitle: Text(hour.weather),
                trailing: Text("${hour.windSpeed.toStringAsFixed(1)} km/h"),
              ); // ListTile
            }, // itemBuilder
          ), // ListView.builder
        ), // Expanded
      ], // Column children
    ); // Column
  } // _buildTodayTab

  // Build Weekly tab
  Widget _buildWeeklyTab() {
    if (_weatherData?.daily.isEmpty ?? true) {
      return Center(child: Text("No daily weather data"));
    } // if no daily data

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            _weatherData!.location,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ), // Text
        ), // Padding
        Expanded(
          child: ListView.builder(
            itemCount: _weatherData!.daily.length,
            itemBuilder: (context, index) {
              DailyWeather day = _weatherData!.daily[index];
              return ListTile(
                leading: Text(
                  day.formattedTime,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ), // Text - date
                title: Text(
                  "${day.tempMax.toStringAsFixed(1)}°C / ${day.tempMin.toStringAsFixed(1)}°C",
                ), // Text - temps
                subtitle: Text(day.weather),
              ); // ListTile
            }, // itemBuilder
          ), // ListView.builder
        ), // Expanded
      ], // Column children
    ); // Column
  } // _buildWeeklyTab
} // _WeatherAppState