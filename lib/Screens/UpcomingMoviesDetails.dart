import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class UpcomingMoviesDetails extends StatefulWidget {
  final String movieTitle;

  const UpcomingMoviesDetails({super.key, required this.movieTitle});

  @override
  _UpcomingMoviesDetailsState createState() => _UpcomingMoviesDetailsState();
}

class _UpcomingMoviesDetailsState extends State<UpcomingMoviesDetails> {
  late YoutubePlayerController _youtubeController;
  bool _isPlaying = false;
  Map<String, dynamic>? movieData;

  @override
  void initState() {
    super.initState();
    _fetchMovieData();
  }

  Future<void> _fetchMovieData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("upcomingMovies");

    dbRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        List<dynamic> movies = List.from(event.snapshot.value as List);
        for (var movie in movies) {
          if (movie["title"] == widget.movieTitle) {
            setState(() {
              movieData = Map<String, dynamic>.from(movie);
              _initializeVideoPlayer();
            });
            break;
          }
        }
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
    if (movieData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                  // 🔙 Back & 📤 Share Buttons
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🔙 Back Button
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        // 📤 Share Button
                        IconButton(
                          icon: const Icon(Icons.share_rounded,
                              color: Colors.white),
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

              // ✅ Movie details section remains the same
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movieData?["title"] ?? "",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const SizedBox(height: 4),
                    Text(movieData?["genre"] ?? "",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: [
                        _buildChip(movieData?["format"] ?? ""),
                        _buildChip(movieData?["releaseDate"] ?? ""),
                        _buildChip(movieData?["language"] ?? ""),
                        _buildChip(movieData?["certificate"] ?? ""),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text("Plot",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(movieData?["plot"] ?? "",
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 14)),
                    const SizedBox(height: 15),
                    const Text("Cast",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildHorizontalList(movieData?["cast"]),
                    const SizedBox(height: 15),
                    const Text("Crew",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildHorizontalList(movieData?["crew"]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.amber.shade300, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 12)),
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
