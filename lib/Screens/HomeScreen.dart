import 'package:animated_notch_bottom_bar/src/notch_bottom_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ticket_booking/Screens/movieTheatrelist.dart';
import 'package:ticket_booking/Widgets/CustomeAppbar2.dart';
import 'package:ticket_booking/const/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required NotchBottomBarController controller});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("theatres");

  String selectedCity = "Chennai";
  List<Map<String, dynamic>> allMovies = [];
  List<Map<String, dynamic>> filteredMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() => isLoading = true);

    try {
      DatabaseEvent event = await _database.once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        List<Map<String, dynamic>> moviesList = [];
        data.forEach((theatreName, theatre) {
          if (theatre["city"] == selectedCity && theatre["movies"] != null) {
            Map<String, dynamic> movies =
                Map<String, dynamic>.from(theatre["movies"]);
            movies.forEach((movieKey, movie) {
              moviesList.add({
                "title": movie["title"],
                "image": movie["poster"],
                "language": movie["language"],
                "genre": movie["genre"]
              });
            });
          }
        });

        setState(() {
          allMovies = moviesList;
          filteredMovies = List.from(allMovies);
        });
      }
    } catch (e) {
      print("🔥 Error fetching movies: $e");
    }

    setState(() => isLoading = false);
  }

  void _filterMovies(String query) {
    setState(() {
      filteredMovies = allMovies
          .where((movie) =>
              movie['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar2(
              userName: "Arun",
              location: selectedCity,
              onTapQR: () {},
              onChanged: _filterMovies,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;
                        int crossAxisCount = screenWidth < 600 ? 2 : 3;
                        double itemWidth = (screenWidth / crossAxisCount) - 16;
                        double childAspectRatio =
                            screenWidth < 400 ? 0.62 : 0.65;
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = filteredMovies[index];

                            return KeyedSubtree(
                              key: ValueKey(movie['title']),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TheatreListScreen(
                                                  movieTitle: movie['title']),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          movie['image']!,
                                          fit: BoxFit.cover,
                                          width: itemWidth,
                                          height: itemWidth * 1.2,
                                          errorBuilder:
                                              (context, object, stackTrace) =>
                                                  const Center(
                                                      child: Icon(Icons.error)),
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: Text(
                                        movie['title']!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "U/A - ${movie['language']}",
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                movie['genre']!,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TheatreListScreen(
                                                          movieTitle:
                                                              movie['title']!),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: blue,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                textStyle: const TextStyle(
                                                    fontSize: 12)),
                                            child: const Text("Book",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
