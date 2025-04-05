import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticket_booking/Screens/booking/seats.dart';

class TheatreListScreen extends StatefulWidget {
  final String movieTitle;
  final String City;

  const TheatreListScreen({super.key, required this.movieTitle, required this.City});

  @override
  _TheatreListScreenState createState() => _TheatreListScreenState();
}

class _TheatreListScreenState extends State<TheatreListScreen> {
  String selectedDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
  List<Map<String, dynamic>> availableTheatres = [];

  @override
  void initState() {
    super.initState();
    _fetchTheatres();
  }

  void _fetchTheatres() async {
    availableTheatres.clear();

    try {
      DatabaseReference databaseRef = FirebaseDatabase.instance.ref("${widget.City}/theatres");
      DatabaseEvent event = await databaseRef.once();

      if (kDebugMode) {
        print("🔥 Raw Firebase Data: ${event.snapshot.value}");
      }

      if (event.snapshot.value != null) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        Map<String, Map<String, dynamic>> theatreMap =
            {}; // ✅ Prevent duplicates

        data.forEach((theatreName, theatre) {
          if (theatre["movies"] != null &&
              theatre["movies"].containsKey(widget.movieTitle)) {
            var movieData =
                Map<String, dynamic>.from(theatre["movies"][widget.movieTitle]);

            if (movieData.containsKey("showtimes")) {
              List<dynamic> availableDates =
                  movieData["showtimes"].keys.toList();
              if (kDebugMode) {
                print("📅 Available Dates in Firebase: $availableDates");
              }
              if (kDebugMode) {
                print("📅 Selected Date: $selectedDate");
              }

              if (availableDates.contains(selectedDate)) {
                var showtimesForDate = movieData["showtimes"][selectedDate];

                if (kDebugMode) {
                  print("✅ Showtimes for $selectedDate: $showtimesForDate");
                }

                // ✅ Ensure showtimes is always a Map<String, dynamic>
                Map<String, dynamic> safeShowtimes = {};
                if (showtimesForDate is Map) {
                  safeShowtimes = Map<String, dynamic>.from(showtimesForDate);
                } else if (showtimesForDate is List) {
                  for (int i = 0; i < showtimesForDate.length; i++) {
                    safeShowtimes["Showtime $i"] = showtimesForDate[i];
                  }
                }

                if (!theatreMap.containsKey(theatreName)) {
                  theatreMap[theatreName] = {
                    "name": theatre["name"] ?? "Unknown Theatre",
                    "location": theatre["location"] ?? "Unknown Location",
                    "tax": theatre["tax"] ?? 0,
                    "poster": movieData["poster"] ?? "",
                    "showtimes": safeShowtimes, // ✅ Fixed here
                  };
                } else {
                  theatreMap[theatreName]!["showtimes"]
                      .addAll(safeShowtimes); // ✅ Merge showtimes correctly
                }
              }
            }
          }
        });

        if (mounted) {
          setState(() {
            availableTheatres = theatreMap.values.toList();
          });
          if (kDebugMode) {
            print("🎭 Available Theatres Updated: $availableTheatres");
          }
        } else {
          if (kDebugMode) {
            print("⚠️ No matching theatres found!");
          }
        }
      } else {
        if (kDebugMode) {
          print("⚠️ Firebase returned null!");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("🔥 Error fetching theatre data: $e");
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> dates = generateDates();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 📅 Date Selector UI
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
                      bool isSelected = date["fullDate"]! == selectedDate;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date["fullDate"]!;
                            _fetchTheatres();
                          });
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

          // 🎭 Theatre List
          Expanded(
            child: availableTheatres.isEmpty
                ? const Center(
                    child: Text("No theatres available for this date."))
                : ListView.builder(
                    itemCount: availableTheatres.length,
                    itemBuilder: (context, index) {
                      var theatre = availableTheatres[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(theatre["name"]),
                          subtitle: Text(theatre["location"]),
                          trailing: const Icon(Icons.arrow_forward_ios),
                         onTap: () {
                            if (kDebugMode) {
                              print("🎟️ Selected Date: $selectedDate");
                            }
                            if (kDebugMode) {
                              print(
                                "🔥 Raw Showtime Data: ${theatre["showtimes"]}");
                            }

                            // ✅ Fix: Ensure `showtimes` is a Map
                            Map<String, dynamic> selectedShowtimeData = {};

                            if (theatre["showtimes"] is Map<String, dynamic>) {
                              selectedShowtimeData = Map<String, dynamic>.from(
                                  theatre["showtimes"]);
                            } else if (theatre["showtimes"] is List) {
                              // Convert List to Map (Assigning "Showtime 0", "Showtime 1" as keys)
                              for (int i = 0;
                                  i < (theatre["showtimes"] as List).length;
                                  i++) {
                                selectedShowtimeData["Showtime $i"] =
                                    theatre["showtimes"][i];
                              }
                            } else {
                              if (kDebugMode) {
                                print(
                                  "⚠️ Unexpected showtime format! Received: ${theatre["showtimes"]}");
                              }
                            }

                            if (kDebugMode) {
                              print(
                                "✅ Processed Showtime Data: $selectedShowtimeData");
                            }
                                if (kDebugMode) {
                                  print(theatre["name"]);
                                }
                            if (kDebugMode) {
                              print(selectedShowtimeData);
                            }
                            if (kDebugMode) {
                              print(widget.movieTitle);
                            }
                            if (kDebugMode) {
                              print(selectedDate);
                            }
                            if (kDebugMode) {
                              print(theatre["tax"] + 10);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TheatreSeatSelectionScreen(
                                  theatreName: theatre["name"],
                                  showtimeData:
                                      selectedShowtimeData, // ✅ Pass Corrected Data
                                  movie: widget.movieTitle,
                                  date: selectedDate,
                                  bookingCharge: theatre["tax"], City: widget.City,
                                ),
                              ),
                            );
                          },

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
