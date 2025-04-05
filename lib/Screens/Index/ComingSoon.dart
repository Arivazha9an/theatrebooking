import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ticket_booking/Screens/UpcomingMoviesDetails.dart';
import 'package:ticket_booking/Widgets/CustomAppbar.dart';
import 'package:ticket_booking/const/colors.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  _ComingSoonScreenState createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("upcomingMovies");

  List<Map<String, String>> upcomingMovies = [];
  bool isLoading = true; // 🔥 Added flag for loading state

  @override
  void initState() {
    super.initState();
    fetchUpcomingMovies();
  }

  Future<void> fetchUpcomingMovies() async {
    try {
      DatabaseEvent event = await _dbRef.once();
      var data = event.snapshot.value;

      List<Map<String, dynamic>> moviesList = [];

      if (data is Map<dynamic, dynamic>) {
        data.forEach((key, value) {
          _processMovie(value, moviesList);
        });
      } else if (data is List<dynamic>) {
        for (var value in data) {
          if (value != null) {
            _processMovie(value, moviesList);
          }
        }
      }

      moviesList.sort((a, b) =>
          (a["parsedDate"] as DateTime).compareTo(b["parsedDate"] as DateTime));

      setState(() {
        upcomingMovies = moviesList.map((movie) {
          return {
            "title": movie["title"].toString(),
            "certificate": movie["certificate"].toString(),
            "language": movie["language"].toString(),
            "genre": movie["genre"].toString(),
            "releaseDate": movie["releaseDate"].toString(),
            "poster": movie["poster"].toString(),
          };
        }).toList();
        isLoading = false; // ✅ Loading complete
      });
    } catch (e) {
      debugPrint("Error fetching upcoming movies: $e");
      setState(() {
        isLoading = false; // ✅ Ensure UI updates even on error
      });
    }
  }

  void _processMovie(dynamic value, List<Map<String, dynamic>> moviesList) {
    DateTime? releaseDate = _parseDate(value["releaseDate"]);
    if (releaseDate != null) {
      moviesList.add({
        "title": value["title"]?.toString() ?? "",
        "certificate": value["certificate"]?.toString() ?? "",
        "language": value["language"]?.toString() ?? "",
        "genre": value["genre"]?.toString() ?? "",
        "releaseDate": value["releaseDate"]?.toString() ?? "",
        "poster": value["poster"]?.toString() ?? "",
        "parsedDate": releaseDate,
      });
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateFormat("MMM d").parse(dateStr);
    } catch (e) {
      debugPrint("Date parsing error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        height: 80,
        title: const Text(
          "Coming Soon",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? _buildShimmerGrid() // 🔥 Show shimmer while loading
            : upcomingMovies.isEmpty
                ? const Center(child: Text("No Upcoming Movies"))
                : GridView.builder(
                    itemCount: upcomingMovies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final movie = upcomingMovies[index];
                      return _buildMovieCard(movie);
                    },
                  ),
      ),
    );
  }

  /// **🔥 Shimmer Effect for Loading**
  Widget _buildShimmerGrid() {
    return GridView.builder(
      itemCount: 6, // Showing 6 placeholders
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieCard(Map<String, String> movie) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(movie["poster"]!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpcomingMoviesDetails(
                  movieTitle: movie["title"]!,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie["title"]!,
                  style: const TextStyle(color: black, fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${movie["certificate"] ?? "N/A"} • ${movie["language"] ?? "N/A"}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          movie["genre"]!,
                          style: const TextStyle(color: black, fontSize: 10),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Release Date",
                          style: TextStyle(
                              color: black.withOpacity(0.7), fontSize: 10),
                        ),
                        Text(
                          movie["releaseDate"]!,
                          style: const TextStyle(
                              color: black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
