import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ticket_booking/Screens/booking/MovieShowTime.dart';

class TheaterScreen extends StatefulWidget {
  final String userName;
  final String location;

  TheaterScreen({required this.userName, required this.location});

  @override
  _TheaterScreenState createState() => _TheaterScreenState();
}

class _TheaterScreenState extends State<TheaterScreen> {
  bool isSearchActive = false;
  late DatabaseReference dbRef;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> theaters = [];
  List<Map<String, dynamic>> filteredTheaters = [];
 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref("${widget.location}/theatres");
    _fetchTheaters();
  }

  Future<void> _fetchTheaters() async {
    try {
      DatabaseEvent event = await dbRef.once();
      Map<String, dynamic> data =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      List<Map<String, dynamic>> tempTheaters = [];

      data.forEach((key, value) {
        tempTheaters.add({
          "name": value["name"],
          "location": value["location"],
          "city": value["city"],
          "image": value["theatreImage"], // Default image
          "tax": value["tax"]
        });
      });

      setState(() {
        theaters = tempTheaters;
        filteredTheaters = tempTheaters;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching theaters: $e");
      }
      setState(() => isLoading = false);
    }
  }

  void _toggleSearch() {
    setState(() {
      isSearchActive = !isSearchActive;
      if (!isSearchActive) {
        _searchController.clear();
        _filterTheaters("");
      }
    });
  }

  void _filterTheaters(String query) {
    setState(() {
      filteredTheaters = theaters
          .where((theater) =>
              theater['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: isLoading
                    ? _buildShimmerEffect() // 🔥 Shimmer instead of loader
                    : _buildTheaterList(),
              ),
            ],
          ),
          _buildAppBar(),
        ],
      ),
    );
  }

  /// **🔥 Shimmer Effect for Loading**
  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5, // Show 5 shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        );
      },
    );
  }

  /// **🎭 Theater List**
  Widget _buildTheaterList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredTheaters.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (kDebugMode) {
              print(filteredTheaters[index]['tax']);
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieShowtimeScreen(
                  theatreName: filteredTheaters[index]['name'],
                  theatreImage: filteredTheaters[index]['image'],
                  tax: filteredTheaters[index]['tax'] ?? 5,
                  City: widget.location,
                ),
              ),
            );
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    filteredTheaters[index]['image'],
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      height: 150,
                      child: const Center(
                          child: Icon(Icons.error, color: Colors.white)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    filteredTheaters[index]['name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// **📌 Custom AppBar**
  Widget _buildAppBar() {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            if (isSearchActive)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Search theaters...",
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: _toggleSearch,
                    ),
                  ),
                  onChanged: _filterTheaters,
                ),
              )
            else
              Flexible(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "All Theaters",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            IconButton(
              icon: Icon(isSearchActive ? Icons.close : Icons.search,
                  color: Colors.black),
              onPressed: _toggleSearch,
            ),
          ],
        ),
      ),
    );
  }
}
