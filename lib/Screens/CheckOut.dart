import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:ticket_booking/Screens/TicketQR.dart';
import 'package:ticket_booking/Widgets/CustomDivider.dart';
import 'package:ticket_booking/const/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckOutScreen extends StatefulWidget {
  final String theatreName;
  final String showTime;
  final List<String> selectedSeats;
  final double totalPrice;
  final int noofSeats;
  final String movieTitle;
  final String selectedDate;

  const CheckOutScreen({
    super.key,
    required this.theatreName,
    required this.showTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.noofSeats,
    required this.movieTitle,
    required this.selectedDate,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  late Map<String, dynamic> movieData;
  int bookingCharge = 10;
  late num taxRate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieData();
  }

  /// ✅ Format selected date
  String formattedDate() {
    DateTime date = DateFormat("dd-MM-yyyy").parse(widget.selectedDate);
    return DateFormat("EEEE, d MMM").format(date);
  }

  /// 🔥 Fetch movie & theatre data from Firebase
  Future<void> _fetchMovieData() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("theatres");

    try {
      DatabaseEvent event = await dbRef.once();
      Map<String, dynamic> theatres =
          Map<String, dynamic>.from(event.snapshot.value as Map);

      for (var theatre in theatres.values) {
        if (theatre["name"] == widget.theatreName &&
            theatre["movies"].containsKey(widget.movieTitle)) {
          setState(() {
            movieData =
                Map<String, dynamic>.from(theatre["movies"][widget.movieTitle]);
            bookingCharge = theatre["tax"] ?? 20; // Default ₹20
            taxRate = bookingCharge * 0.18; // 18% tax
            isLoading = false;
          });
          return;
        }
      }
    } catch (error) {
      print("Error fetching movie data: $error");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateSeatsInFirebase() async {
    try {
      // 🔍 Step 1: Get All Theatres
      DatabaseReference theatreRef = FirebaseDatabase.instance.ref("theatres");
      DatabaseEvent theatreEvent = await theatreRef.once();

      Map<String, dynamic> allTheatres =
          Map<String, dynamic>.from(theatreEvent.snapshot.value as Map);

      print("🎭 Available Theatres: ${allTheatres.keys}");

      // 🛠 Step 2: Format Firebase Path
      String theatreKey = widget.theatreName.replaceAll(" ", "");
      String movieKey = widget.movieTitle.toUpperCase().replaceAll(" ", "_");

      String firebasePath =
          "theatres/$theatreKey/movies/$movieKey/showtimes/${widget.selectedDate}/${widget.showTime}/layout";

      print("🎯 Fetching seat layout from: $firebasePath");

      DatabaseReference seatsRef = FirebaseDatabase.instance.ref(firebasePath);
      DatabaseEvent event = await seatsRef.once();

      // 🚨 Step 3: Handle Missing Data
      if (event.snapshot.value == null) {
        print("🚨 Seat layout not found! Check database structure.");
        return;
      }

      // ✅ Convert Firebase Data to a Proper List<List<String>>
      var snapshot = event.snapshot.value;
      List<List<String>> seatLayout = (snapshot as List<dynamic>)
          .map((row) =>
              (row as List<dynamic>).map((seat) => seat.toString()).toList())
          .toList();

      print("🎭 Seat Layout Before Update: $seatLayout");

      // 🔥 Step 4: Update Selected Seats
      for (String seat in widget.selectedSeats) {
        // ✅ Fix: Convert seat format if necessary (Handles "0-0" cases)
        if (seat.contains("-")) {
          List<String> parts = seat.split("-");
          int rowNumber = int.parse(parts[0]);
          int colNumber = int.parse(parts[1]);

          seat = "${String.fromCharCode(65 + rowNumber)}${colNumber + 1}";
          print("🔄 Converted Seat: $seat");
        }

        // 🔢 Convert Seat to Row & Column
        int row = seat.codeUnitAt(0) - 65; // 'A' → 0, 'B' → 1, etc.
        int col = int.parse(seat.substring(1)) - 1;

        // ✅ Prevent Out-of-Bounds Errors
        if (row < 0 ||
            row >= seatLayout.length ||
            col < 0 ||
            col >= seatLayout[row].length) {
          print("🚨 Seat $seat is out of bounds! Row: $row, Col: $col");
          continue;
        }

        // ✅ Check if Seat is Available
        if (seatLayout[row][col] == "S" || seatLayout[row][col] == "V") {
          seatLayout[row][col] = "B"; // Mark as booked
          print("✅ Seat $seat booked successfully!");
        } else {
          print("⚠️ Seat $seat is already booked.");
        }
      }

      // 🎭 Debug: Show Updated Layout
      print("🎭 Seat Layout After Update: $seatLayout");

      // 🔥 Step 5: Write Updated Data to Firebase
      await seatsRef.set(seatLayout).then((_) {
        print("🔥 Data successfully updated in Firebase!");
      }).catchError((error) {
        print("🚨 Firebase Write Error: $error");
      });
    } catch (e) {
      print("🔥 Error updating seats: $e");
    }
  }

  /// ✅ Convert seat format from `"0-1"` to `"A1"`
  List<String> formatSeats(List<String> seats) {
    return seats.map((seat) {
      List<String> parts = seat.split("-");
      String rowLetter = String.fromCharCode(65 + int.parse(parts[0]));
      return "$rowLetter${int.parse(parts[1]) + 1}";
    }).toList();
  }

  /// ✅ Generate Order ID
  String generateOrderId() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${widget.selectedDate.replaceAll('-', '')}$timestamp";
  }

  /// ✅ Calculate final price with taxes
  num get finalTotalPrice => widget.totalPrice + bookingCharge + (taxRate * 2);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (movieData.isEmpty) {
      return Scaffold(
        body: const Center(child: Text("Movie data not found!")),
      );
    }

    List<String> formattedSeats = formatSeats(widget.selectedSeats);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎟 Movie Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow[200],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            movieData["poster"],
                            height: 170,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${movieData["title"]} (${movieData["language"]} ${movieData["format"]})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                  '${movieData["rating"]} • ${movieData["language"]} • ${movieData["format"]}',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  TicketDivider(
                      height: 10,
                      dashWidth: 8,
                      dashHeight: 2,
                      color: Colors.grey),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${formattedDate()} ${widget.showTime}",
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            Text(widget.theatreName,
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: formattedSeats.map((seat) {
                                return Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: amber, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(seat,
                                      style: const TextStyle(
                                          color: grey, fontSize: 12)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            border: Border.all(
                                color: blue.withOpacity(0.5), width: 6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              Text(widget.noofSeats.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const Text('Tickets',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📜 Booking Details
            _buildDetailRow('Seats', formattedSeats.join(", ")),
            _buildDetailRow('${widget.noofSeats} X Tickets',
                '₹${widget.totalPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Booking Charge', '₹$bookingCharge'),
            _buildDetailRow(
                'Total Amount', '₹${finalTotalPrice.toStringAsFixed(2)}'),
            Spacer(
              flex: 1,
            ),

            // 💳 Pay Now Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  backgroundColor: blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                onPressed: () async {
                  await _updateSeatsInFirebase();
                }
                //() {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => TicketScreen(
                //           theatreName: widget.theatreName,
                //           movieName: movieData["title"],
                //           showTime: widget.showTime,
                //           selectedSeats: formattedSeats,
                //           totalPrice: finalTotalPrice.toInt(),
                //           noofSeats: widget.noofSeats,
                //           movieLanguage: movieData["language"],
                //           date: widget.selectedDate,
                //           movieFormat: movieData["format"],
                //           movieImage: movieData["poster"],
                //           orderId: generateOrderId(),
                //         ),
                //       ));
                // }
                ,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${finalTotalPrice.toDouble()}",
                        style: TextStyle(color: white),
                      ),
                      Text('|', style: const TextStyle(color: white)),
                      Row(
                        children: [
                          Text('Pay Now', style: const TextStyle(color: white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
