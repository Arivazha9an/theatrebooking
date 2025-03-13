import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/MovieShowTime.dart';

class TheaterScreen extends StatefulWidget {
  final String userName;
  final String location;

  TheaterScreen({required this.userName, required this.location});

  @override
  _TheaterScreenState createState() => _TheaterScreenState();
}

class _TheaterScreenState extends State<TheaterScreen> {
  bool isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> theaters = [
    {
      "name": "Jazz cinemas Luxe chennai",
      "image":
          "https://tamil.samayam.com/thumb/61574897/61574897.jpg?imgsize-56017&width=700&height=394&resizemode=75"
    },
    {
      "name": "Kasi Talkies",
      "image":
          "https://tamil.samayam.com/thumb/61574897/61574897.jpg?imgsize-56017&width=700&height=394&resizemode=75"
    },
    {
      "name": "Kamala cinemas",
      "image":
          "https://tamil.samayam.com/thumb/61574897/61574897.jpg?imgsize-56017&width=700&height=394&resizemode=75"
    },
    {
      "name": "AGS cinemas T nagar",
      "image":
          "https://tamil.samayam.com/thumb/61574897/61574897.jpg?imgsize-56017&width=700&height=394&resizemode=75"
    },
  ];
  List<Map<String, String>> filteredTheaters = [];

  @override
  void initState() {
    super.initState();
    filteredTheaters = theaters;
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
              theater['name']!.toLowerCase().contains(query.toLowerCase()))
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredTheaters.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MovieShowtimeScreen()),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                filteredTheaters[index]['image']!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey,
                                  height: 150,
                                  child: const Center(
                                      child: Icon(Icons.error,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text("Get Direction",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                filteredTheaters[index]['name']!,
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
                ),
              ),
            ],
          ),
          Positioned(
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
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black),
                            onPressed: _toggleSearch,
                          ),
                        ),
                        onChanged: _filterTheaters,
                      ),
                    )
                  else
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "All Theaters",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('chennai')
                                ],
                              ),
                            ],
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
          )
        ],
      ),
    );
  }
}
