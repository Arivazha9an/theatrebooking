import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticket_booking/Screens/Seats.dart';
import 'package:ticket_booking/const/colors.dart';
import 'package:intl/intl.dart';

class MovieShowtimeScreen extends StatefulWidget {
  const MovieShowtimeScreen({super.key});

  @override
  _TheaterScreenState createState() => _TheaterScreenState();
}

class _TheaterScreenState extends State<MovieShowtimeScreen> {
  String selectedDate =
      DateFormat("dd MMM").format(DateTime.now()).toUpperCase();

  // Generate dates dynamically from today for the next 10 days
  List<Map<String, String>> generateDates() {
    return List.generate(10, (index) {
      DateTime date = DateTime.now().add(Duration(days: index));
      return {
        "day": DateFormat("dd").format(date),
        "month": DateFormat("MMM").format(date).toUpperCase(),
        "week": DateFormat("EEE").format(date).toUpperCase(),
        "fullDate": DateFormat("dd MMM").format(date).toUpperCase()
      };
    });
  }

  late List<Map<String, String>> dates = generateDates();

  // Movie data with seat percentage
  List<Map<String, dynamic>> movies = [
    {
      "title": "SPIDERMAN ACROSS THE SPIDER VERSE",
      "genre": "ACTION, ADVENTURE",
      "language": "Tamil - 2D",
      "rating": 84,
      "image": "https://tamil.samayam.com/thumb/61574897/61574897.jpg",
      "date": DateFormat("dd MMM").format(DateTime.now()).toUpperCase(),
      "showtimes": [
        {"time": "07:15 AM", "seatsFilled": 95},
        {"time": "10:15 AM", "seatsFilled": 80},
        {"time": "10:15 PM", "seatsFilled": 60}
      ]
    },
    {
      "title": "POR THOZHIL",
      "genre": "Drama, Thriller",
      "language": "Tamil - 2D",
      "rating": 93,
      "image": "https://tamil.samayam.com/thumb/61574897/61574897.jpg",
      "date": "05 MAR",
      "showtimes": [
        {"time": "10:15 AM", "seatsFilled": 50},
        {"time": "02:15 PM", "seatsFilled": 70},
        {"time": "06:15 PM", "seatsFilled": 95}
      ]
    }
  ];

  List<Map<String, dynamic>> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    _filterMovies(selectedDate);
  }

  void _filterMovies(String date) {
    setState(() {
      selectedDate = date;
      filteredMovies = movies.where((movie) => movie['date'] == date).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        "https://tamil.samayam.com/thumb/61574897/61574897.jpg"),
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
                child:
                    Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
              ),
              Positioned(
                bottom: 20,
                left: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kamala Talkies",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "No 156, Arcot Road, Vadapalani, Chennai...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: 70,
            child: Container(
              color: amber[100],
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(dates.isNotEmpty ? dates.first["month"]! : "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemExtent: 70, // Ensures 4 dates are visible at once
                      itemBuilder: (context, index) {
                        var date = dates[index];
                        bool isSelected = date["fullDate"]! == selectedDate;
                        return GestureDetector(
                          onTap: () => _filterMovies(date["fullDate"]!),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(date["day"]!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text(date["week"]!,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(dates.isNotEmpty ? dates.last["month"]! : "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // 🔴 Movie List
          Expanded(
            child: filteredMovies.isEmpty
                ? const Center(
                    child: Text("No movies available for this date."))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      var movie = filteredMovies[index];
                      return InkWell(
                        onTap: (){
                             Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TheatreSeatSelection()),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🎬 Movie Poster
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    movie['image'],
                                    width: 110,
                                    height: 145,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                        
                                // 🎞️ Movie Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['title'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ),
                                      Text(
                                        movie['genre'],
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        movie['language'],
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black54),
                                      ),
                                      Wrap(
                                        spacing: 6,
                                        children: movie['showtimes']
                                            .map<Widget>((showtime) {
                                          int seatsFilled =
                                              showtime['seatsFilled'];
                        
                                          // 🎨 Determine Button Color Based on Seat Percentage
                                          Color textColor = seatsFilled > 90
                                              ? Colors.red
                                              : (seatsFilled > 65
                                                  ? Colors.orange
                                                  : Colors.green);
                        
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: black,
                                                width: 0.2,
                                              ),
                                            ),
                                            child: Text(
                                              "${showtime['time']}",
                                              style: TextStyle(
                                                  color: textColor, fontSize: 12),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
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
