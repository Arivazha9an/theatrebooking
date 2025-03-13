import 'package:flutter/material.dart';
import 'package:ticket_booking/Widgets/CustomAppbar.dart';
import 'package:ticket_booking/const/colors.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  _ComingSoonScreenState createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  final List<Map<String, String>> movies = [
    {
      "title": "MAAMANNAN",
      "certificate": "U/A",
      "language": "Tam",
      "genre": "Drama, Thriller",
      "releaseDate": "Jun 29",
      "poster":
          "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTWTgNxju0GIQaU65CxjmRYuRMICo4J2iYnjamD0qYt--01IlrpJQBKMvsm7d1-qWJOL7KIIg"
    },
    {
      "title": "Payuum Oli Nee Yenakku",
      "certificate": "U/A",
      "language": "Tam",
      "genre": "Action, Thriller",
      "releaseDate": "Jun 23",
      "poster":
          "https://m.media-amazon.com/images/M/MV5BNDM0OTgwMmMtZTJlMy00NTRmLWEwMzYtMGExMWU3Y2FmZjE1XkEyXkFqcGc@._V1_.jpg"
    },
    {
      "title": "MAVEERAN",
      "certificate": "U/A",
      "language": "Tam",
      "genre": "Action, Thriller",
      "releaseDate": "Jul 14",
      "poster":
          "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcREEZoBCvlEWZPMMLZa3XF3FuXf9zGbqmr4ibqdl0zC0DSpvTbS6fxd36H_iMMlmpKqla6J"
    },
    {
      "title": "INSIDIOUS: The Red Door",
      "certificate": "U/A",
      "language": "Tam,Eng",
      "genre": "Horror, Mystery",
      "releaseDate": "Sep 28",
      "poster":
          "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQn6HhE9WguEjDepY2iP0-ACdqKVKeKbDeVZIcDViZBm5BDWLNdI4kU6jOFzJ45gEus-5NX"
    },
    {
      "title": "Oppenheimer",
      "certificate": "U/A",
      "language": "Tam,Eng",
      "genre": "War, Drama",
      "releaseDate": "Jul 21",
      "poster":
          "https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQ8FFJNBaIXvhEwqXXw40rYYDci8jPlYxWfy9082flliYoZ-SqqZjy0az-G5rIWuSJp2pn7xQ"
    },
    {
      "title": "JAILER",
      "certificate": "U/A",
      "language": "Tam",
      "genre": "Action, Thriller",
      "releaseDate": "Jul 21",
      "poster":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDg4IkitIG8cCq4VvLx4JDDrGBhr39RkJpWjru13tywmTexYkBHb65nzwLELUgaMvvpXYl"
    },
  ];

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
        //centerTitle: true,
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MovieSearchDelegate(movies),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          itemCount: movies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _buildMovieCard(movie);
          },
        ),
      ),
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        Positioned(
          bottom: -1,
          left: -1,
          right: -1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie["title"]!,
                  style: const TextStyle(color: black, fontSize: 12),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${movie["certificate"] ?? "N/A"} • ${movie["language"] ?? "N/A"}",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 10),
                                  overflow: TextOverflow
                                      .ellipsis, // Prevents overflow
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            Text(
                              movie["genre"]!,
                              style:
                                  const TextStyle(color: black, fontSize: 10),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Release Date",
                                  style: TextStyle(
                                      color: black.withOpacity(0.7),
                                      fontSize: 10),
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

class MovieSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> movies;

  MovieSearchDelegate(this.movies);

  @override
  String get searchFieldLabel => "Search movies...";

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, String>> filteredMovies = movies
        .where((movie) =>
            movie["title"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        itemCount: filteredMovies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Keeps the same 2-column layout
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final movie = filteredMovies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context); // Same as suggestions but final result
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  Widget _buildMovieCard(Map<String, String> movie) {
    return Stack(
      children: [
        // Movie Poster with Rounded Corners
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            movie["poster"] ?? "", // Handle null case
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Light Black Shade Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.4), // Adjust for readability
          ),
        ),

        // Play Button on Top-Right
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.play_arrow, color: Colors.black, size: 24),
            ),
          ),
        ),

        // Movie Info Section (Title, Certificate, Language, Genre, Release Date)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Title (Always 1 line, Show "..." if too long)
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    movie["title"] ?? "Unknown",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),

                // Certificate & Language (Always 1 line)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${movie["certificate"] ?? "N/A"} • ${movie["language"] ?? "N/A"}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Genre (Always 1 line)
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    movie["genre"] ?? "Genre Not Available",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),

                // Release Date (Always 1 line)
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Release Date: ${movie["releaseDate"] ?? "Unknown"}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,                      
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
