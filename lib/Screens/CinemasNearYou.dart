import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CinemasNearYouScreen extends StatelessWidget {
  CinemasNearYouScreen({super.key});

  // Local Data for Cinema and Movies
  final Map<String, dynamic> cinema = {
    "name": "Kamala Talkies",
    "rating": 4.3,
    "distance": "3km",
    "address":
        "116, Arcot Rd, Ottraipalam, Somusundara Bharathi Nagar, Vadapalani, Chennai, Tamil Nadu 600026",
    "lat": 13.0525, // Latitude for the cinema
    "lng": 80.2311, // Longitude for the cinema
    "image":
        "https://lh3.googleusercontent.com/proxy/9VvJX7XveI6Y0TQKicbPISIZPoK6Mor-UhXtIY_veC29txUpRT5GSMpETlKWcJLptBSXPvH_lZwXvbeH0mwSl2RXR4RkamLzYQ52jHjB5cq_XGn3ALb3Pvc1rA",
  };

  final List<Map<String, dynamic>> movies = [
    {
      "title": "Por Thozhil",
      "rating": 4.3,
      "image":
          "https://m.media-amazon.com/images/M/MV5BZDkyN2QwYzAtZjk4My00YmYyLThmMTItZDJmYmQxMmE3ZGIxXkEyXkFqcGc@._V1_.jpg"
    },
    {
      "title": "Adipurush",
      "rating": 3.3,
      "image":
          "https://upload.wikimedia.org/wikipedia/en/c/cf/Adipurush_poster.jpeg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cinemas Near You"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 350,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(cinema["lat"], cinema["lng"]),
                    initialZoom: 16.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(cinema["lat"], cinema["lng"]),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cinema Details Card Positioned at the Top of the Map
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Cinema Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cinema["image"],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Cinema Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cinema["name"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.yellow, size: 16),
                                    Text(
                                      " ${cinema["rating"]}",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.location_pin,
                                        color: Colors.white70, size: 16),
                                    Text(
                                      cinema["distance"],
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              cinema["address"],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Now Showing Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Now Showing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // Movie List
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie["image"],
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            Text(movie["rating"].toString()),
                          ],
                        ),
                      ],
                    ),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
