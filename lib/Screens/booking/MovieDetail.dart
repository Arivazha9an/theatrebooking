import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ticket_booking/Screens/booking/movieTheatrelist.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shimmer/shimmer.dart'; // 🆕 Import Shimmer Package

class MovieDetailScreen extends StatefulWidget {
  final String theatreId;
  final String movieId;
  final String City;

  const MovieDetailScreen(
      {super.key,
      required this.theatreId,
      required this.movieId,
      required this.City});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late YoutubePlayerController _youtubeController;
  bool _isPlaying = false;
  Map<String, dynamic>? movieData;
  bool _isLoading = true; // 🆕 Shimmer Loading State

  @override
  void initState() {
    super.initState();
    _fetchMovieData();
  }

  Future<void> _fetchMovieData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref(
        "${widget.City}/theatres/${widget.theatreId}/movies/${widget.movieId}");

    dbRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        setState(() {
          movieData = Map<String, dynamic>.from(event.snapshot.value as Map);
          _initializeVideoPlayer();
          _isLoading = false; // ✅ Stop shimmer when data is loaded
        });
      }
    });
  }

  void _initializeVideoPlayer() {
    final videoId = YoutubePlayer.convertUrlToId(movieData?["trailer"] ?? "");
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? "",
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_youtubeController.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = _youtubeController.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController.removeListener(_listener);
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TheatreListScreen(
                        movieTitle: widget.movieId,
                        City: widget.City,
                      ),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(15),
          ),
          child: const Text("Book Now",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _isLoading ? _buildShimmerEffect() : _buildMovieDetails(),
        ),
      ),
    );
  }

  /// 🆕 **Shimmer Effect While Loading**
  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 15,
              width: 150,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 15,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// **🎬 Build Movie Details Once Loaded**
  Widget _buildMovieDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
              ),
              builder: (context, player) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: player,
                );
              },
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: () {
                      Share.share(
                        "Check out this movie: ${movieData?["title"]}\nWatch the trailer: ${movieData?["trailer"]}",
                        subject: "Movie Recommendation 🎬",
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movieData?["title"] ?? "",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(movieData?["genre"] ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 10),
              const Text("Plot",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(movieData?["plot"] ?? "",
                  style: const TextStyle(color: Colors.black87, fontSize: 14)),
              const SizedBox(height: 15),
              const Text("Cast",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildHorizontalList(movieData?["cast"]),
              const SizedBox(height: 15),
              const Text("Crew",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildHorizontalList(movieData?["crew"]),
            ],
          ),
        ),
      ],
    );
  }
    Widget _buildHorizontalList(dynamic data) {
    if (data == null || data is! List) return const SizedBox.shrink();

    List<dynamic> list = List.from(data); // ✅ Corrected for lists

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          var person = list[index];
          return Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    person["image"] ?? "", // ✅ Check if key exists
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, object, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  person["name"] ?? "Unknown", // ✅ Check for null values
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
                if (person.containsKey("role"))
                  Text(
                    person["role"] ?? "",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
