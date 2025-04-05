import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:ticket_booking/Screens/booking/seats.dart';

class MovieShowtimeScreen extends StatefulWidget {
  final String theatreName;
  final String theatreImage;
  final int tax;
  final String City;  

  const MovieShowtimeScreen(
      {super.key,
      required this.theatreName,
      required this.theatreImage,
      required this.City,
      required this.tax});

  @override
  _MovieShowtimeScreenState createState() => _MovieShowtimeScreenState();
}

class _MovieShowtimeScreenState extends State<MovieShowtimeScreen> {
  String selectedDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
  List<Map<String, String>> dates = [];
  List<Map<String, dynamic>> movies = [];
  List<Map<String, dynamic>> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    dates = generateDates();
    _fetchMovies();
  }

  // 🔹 Generate Next 10 Days
  List<Map<String, String>> generateDates() {
    return List.generate(10, (index) {
      DateTime date = DateTime.now().add(Duration(days: index));
      return {
        "day": DateFormat("dd").format(date),
        "month": DateFormat("MMM").format(date).toUpperCase(),
        "week": DateFormat("EEE").format(date).toUpperCase(),
        "fullDate": DateFormat("dd-MM-yyyy").format(date),
      };
    });
  }

// 🔹 Fetch Movies from Firebase
  Future<void> _fetchMovies() async {
    try {
      DatabaseReference dbRef = FirebaseDatabase.instance
          .ref("${widget.City}/theatres/${widget.theatreName}/movies");

      DatabaseEvent event = await dbRef.once();
      if (kDebugMode) {
        print("🔥 Raw Firebase Data: ${event.snapshot.value}");
      }

      if (event.snapshot.value != null && event.snapshot.value is Map) {
        Map<String, dynamic> rawData = {};

        (event.snapshot.value as Map).forEach((key, value) {
          if (key is String && value is Map) {
            rawData[key] = Map<String, dynamic>.from(value);
          }
        });

        List<Map<String, dynamic>> tempMovies = [];

        rawData.forEach((movieTitle, movieData) {
          if (movieData is Map) {
            Map<String, dynamic> formattedMovie =
                Map<String, dynamic>.from(movieData);

            formattedMovie["title"] = movieTitle;
            formattedMovie["image"] =
                formattedMovie["poster"] ?? "https://via.placeholder.com/150";
            formattedMovie["genre"] =
                formattedMovie["genre"] ?? "Unknown Genre";
            formattedMovie["language"] =
                formattedMovie["language"] ?? "Unknown";
            formattedMovie["duration"] = formattedMovie["duration"] ?? "N/A";
            formattedMovie["plot"] =
                formattedMovie["plot"] ?? "No plot available.";
            formattedMovie["rating"] =
                formattedMovie["rating"]?.toString() ?? "N/A";
            formattedMovie["showtimes"] = formattedMovie["showtimes"] ?? {};

            // 🛠 Debug Available Dates in Firebase
            if (formattedMovie.containsKey("showtimes") &&
                formattedMovie["showtimes"] is Map) {
              formattedMovie["showtimes"] =
                  (formattedMovie["showtimes"] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  value is Map ? Map<String, dynamic>.from(value) : {},
                ),
              );
            }

            if (kDebugMode) {
              print("🎬 Movie: ${formattedMovie["showtimes"]}");
            }
            if (kDebugMode) {
              print("🎬 Movie: $movieTitle");
            }
            if (kDebugMode) {
              print(
                "📅 Available Dates: ${formattedMovie["showtimes"].keys.toList()}");
            }

            tempMovies.add(formattedMovie);
          }
        });

        if (!mounted) return;

        setState(() {
          movies = tempMovies;
          _filterMovies(selectedDate); // ✅ Filtering movies for selected date
        });

        if (kDebugMode) {
          print("🎬 Movies fetched successfully! Count: ${movies.length}");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ No movies found in Firebase.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("🔥 Error fetching movies: $e");
      }
    }
  }

  // 🔹 Filter Movies Based on Selected Date
  void _filterMovies(String date) {
    setState(() {
      selectedDate = date;
      filteredMovies = movies.where((movie) {
        if (movie['showtimes'] != null &&
            movie['showtimes'] is Map<String, dynamic>) {
          Map<String, dynamic> showtimeMap =
              Map<String, dynamic>.from(movie['showtimes']);

          // ✅ Check if showtimes exist for the selected date
          if (showtimeMap.containsKey(date) &&
              showtimeMap[date] is Map<String, dynamic>) {
            return true;
          }
        }
        return false;
      }).toList();
    });

    if (kDebugMode) {
      print("🎬 Filtered Movies Count: ${filteredMovies.length}");
    }
    if (filteredMovies.isNotEmpty) {
      if (kDebugMode) {
        print(
          "✅ Available Movies: ${filteredMovies.map((m) => m['title']).toList()}");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ No movies available for $selectedDate");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🎭 Theatre Header
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.theatreImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 24),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 15,
                child: Text(
                  widget.theatreName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // 🗓️ Date Selection Bar
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(dates.first["month"]!,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemExtent: 70,
                    itemBuilder: (context, index) {
                      var date = dates[index];
                      bool isSelected = date["fullDate"] == selectedDate;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date["fullDate"]!;
                          });
                          _filterMovies(selectedDate);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(date["day"]!,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              Text(date["week"]!,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(dates.last["month"]!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 🎬 Movie List
          Expanded(
            child: filteredMovies.isEmpty
                ? const Center(
                    child: Text("No movies available for this date."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      var movie = filteredMovies[index];

                      return GestureDetector(
                        onTap: () {
                          var selectedShowtimeData =
                              movie['showtimes'][selectedDate] ?? {};

                          if (selectedShowtimeData is Map) {
                            selectedShowtimeData = Map<String, dynamic>.from(
                                selectedShowtimeData.cast<String, dynamic>());
                          } else {
                            selectedShowtimeData = {};
                          }

                          // 🛠 **Fix: Convert seat layout correctly**
                          if (selectedShowtimeData.containsKey("layout") &&
                              selectedShowtimeData["layout"] is List) {
                            selectedShowtimeData["layout"] =
                                (selectedShowtimeData["layout"] as List)
                                    .map((row) => row is List
                                        ? List<String>.from(row)
                                        : [])
                                    .toList();
                          }

                          // 🛠 **Fix: Convert Pricing correctly (Prevents 'String' index error)**
                          if (selectedShowtimeData.containsKey("pricing") &&
                              selectedShowtimeData["pricing"] is List) {
                            selectedShowtimeData["pricing"] =
                                (selectedShowtimeData["pricing"] as List)
                                    .map((price) =>
                                        int.tryParse(price.toString()) ??
                                        0) // 🔥 **Fix here**
                                    .toList();
                          }

                          if (kDebugMode) {
                            print(
                              "📌 Showtime Data: $selectedShowtimeData");
                          } // Debugging
if (kDebugMode) {
  print(widget.tax + 10);
}
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TheatreSeatSelectionScreen(
                                theatreName: widget.theatreName,
                                showtimeData: selectedShowtimeData,
                                movie: movie["title"],
                                date: selectedDate,
                                bookingCharge: widget.tax,
                                City: widget.City,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // ✅ Align content to top
                              children: [
                                // 🎞 Movie Poster
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    movie['image'],
                                    width: 100,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12), // ✅ Increase spacing

                                // 🎟 Movie Details
                                Expanded(
                                  // ✅ Allow details to take full width
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          movie['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines:
                                              2, // ✅ Ensure title doesn't overflow
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          movie['genre'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          movie['language'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ❤️ Rating
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.heart_fill,
                                          color: Colors.red,
                                          size: 18, // ✅ Match the image size
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${movie['rating']}%",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
