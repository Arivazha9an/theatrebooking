import 'package:animated_notch_bottom_bar/src/notch_bottom_bar_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ticket_booking/Screens/booking/MovieDetail.dart';
import 'package:ticket_booking/Screens/booking/movieTheatrelist.dart';
import 'package:ticket_booking/Widgets/CustomeAppbar2.dart';
import 'package:ticket_booking/const/colors.dart';

class HomeScreen extends StatefulWidget {
    final String userName;
  final String location;
  const HomeScreen({super.key, 
  required NotchBottomBarController controller,
      required this.userName,
      required this.location});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseReference _database;
 
  List<Map<String, dynamic>> allMovies = [];
  List<Map<String, dynamic>> filteredMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instance.ref("${widget.location}/theatres");
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
          if (theatre["city"] == widget.location && theatre["movies"] != null) {
            Map<String, dynamic> movies =
                Map<String, dynamic>.from(theatre["movies"]);
            movies.forEach((movieKey, movie) {
              moviesList.add({
                "title": movie["title"],
                "image": movie["poster"],
                "language": movie["language"],
                "genre": movie["genre"],
                "theatreId": theatreName
              });
            });
          }
        });

        setState(() {
          allMovies = moviesList;
          filteredMovies = List.from(allMovies);
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("🔥 Error fetching movies: $e");
      }
      setState(() => isLoading = false);
    }
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
              userName: widget.userName,
              location: widget.location,
              onTapQR: () {},
              onChanged: _filterMovies,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: isLoading
                  ? _buildShimmerEffect() // 🔥 Replace with Shimmer Effect
                  : _buildMovieGrid(),
            ),
          ],
        ),
      ),
    );
  }

  /// **🔥 Shimmer Effect for Loading**
  Widget _buildShimmerEffect() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 6, // Showing 6 placeholders
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.65,
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

  /// **📌 Movie Grid**
  Widget _buildMovieGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int crossAxisCount = screenWidth < 600 ? 2 : 3;
        double itemWidth = (screenWidth / crossAxisCount) - 16;
        double childAspectRatio = screenWidth < 400 ? 0.62 : 0.65;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  SizedBox(
                    width: itemWidth,
                    child: InkWell(
                      onTap: () {
                        if (kDebugMode) {
                          print(
                            "Theatre ID: ${movie['theatreId']}  ${movie['title']!},");
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailScreen(
                              City: widget.location,
                              theatreId: movie['theatreId']!,
                              movieId: movie['title']!,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          movie['image']!,
                          fit: BoxFit.cover,
                          width: itemWidth,
                          height: itemWidth * 1.2,
                          errorBuilder: (context, object, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: SizedBox(
                      width: itemWidth,
                      child: Text(
                        movie['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: itemWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "U/A - ${movie['language']}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                movie['genre']!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TheatreListScreen(
                                    movieTitle: movie['title'],
                                    City: widget.location,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text("Book",
                                style: TextStyle(color: Colors.white)),
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
    );
  }
}
