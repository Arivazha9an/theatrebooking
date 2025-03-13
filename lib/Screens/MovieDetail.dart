import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late YoutubePlayerController _youtubeController;
  bool _isPlaying = false;

   final Map<String, dynamic> movieData = {
    "title": "POR THOZHIL",
    "rating": 93,
    "genre": "Drama, Thriller",
    "duration": "2h 20m",
    "releaseDate": "Jun 01, 2023",
    "language": "Tamil",
    "imdb": "8.3/10",
    "plot":
        "A rookie cop teams up with a veteran lawman to find a serial killer.",
    "youtubeUrl": "https://www.youtube.com/watch?v=CfKZUZR1UDk",
    "poster": "https://upload.wikimedia.org/wikipedia/en/8/8b/Por_Thozhil.jpg",
    "cast": [
      {
        "name": "Ashok Selvan",
        "image": "https://static.toiimg.com/photo/101059090.cms"
      },
      {
        "name": "Nikhila Vimal",
        "image":
            "https://imagesvs.oneindia.com/ph-big/2023/09/por-thozhil-fame-nikhila-vimal-s-saree-look-made-wow-among-fans_169494268870.jpg"
      },
      {
        "name": "Sarathkumar",
        "image":
            "https://images.moneycontrol.com/static-mcnews/2023/08/1E3A0482-770x435.jpg?impolicy=website&width=1600&height=900"
      }
    ],
    "crew": [
      {
        "name": "Vignesh Raja",
        "role": "Director",
        "image":
            "https://pbs.twimg.com/profile_images/1360546376854036483/GZO5wR1P_400x400.jpg"
      },
      {
        "name": "Jakes Bejoy",
        "role": "Music Director",
        "image":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQt6_RPORmCVPIQKrgE-D0aXXBkSIms2xEbIqjNz26w0WnxrdpDcwVwBHikyGlXhjCBwRk&usqp=CAU"
      }
    ]
  };


  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(movieData["youtubeUrl"]!);
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        controlsVisibleAtStart: true,
        hideControls: false,
        useHybridComposition: true,
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
          onPressed: () {},
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
              ),
              builder: (context, player) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: player,
                      ),
                      IconButton(
                        onPressed: () {
                          if (_isPlaying) {
                            _youtubeController.pause();
                          } else {
                            _youtubeController.play();
                          }
                        },
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 60,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movieData["title"],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text("${movieData["rating"]}%"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(movieData["genre"],
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      _buildChip("U/A"),
                      _buildChip(movieData["duration"]),
                      _buildChip(movieData["releaseDate"]),
                      _buildChip(movieData["language"]),
                      _buildChip(movieData["imdb"]),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Plot",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(movieData["plot"],
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14)),
                  const SizedBox(height: 15),
                  const Text("Cast",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildHorizontalList(movieData["cast"]),
                  const SizedBox(height: 15),
                  const Text("Crew",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildHorizontalList(movieData["crew"]),
                ],
              ),
            ),
          ],
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

  Widget _buildHorizontalList(List<dynamic> data) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    data[index]["image"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, object, stackTrace) => const Icon(Icons.error), // Handle image errors
                  ),
                ),
                const SizedBox(height: 4),
                Text(data[index]["name"],
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                if (data[index].containsKey("role"))
                  Text(data[index]["role"],
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}