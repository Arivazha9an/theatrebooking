// ignore: file_names
// import 'dart:ffi';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:ticket_booking/Screens/booking/TicketQR.dart';
import 'package:ticket_booking/Widgets/CustomDivider.dart';
import 'package:ticket_booking/const/colors.dart';

class CheckOutScreen extends StatefulWidget {
  final String theatreName;
  final String showTime;
  final List<String> selectedSeats;
  final double totalPrice;
  final String noofSeats;
  final String movieTitle;
  final String selectedDate;
  final int bookingCharge;
  final String City;
  final List<String> selectedSeats1;

  const CheckOutScreen({
    super.key,
    required this.City,
    required this.theatreName,
    required this.showTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.noofSeats,
    required this.movieTitle,
    required this.selectedDate,
    required this.bookingCharge,
    required this.selectedSeats1,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  late Map<String, dynamic> movieData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late double taxRate;
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
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref("${widget.City}/theatres");

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
            double bookingCharge = widget.bookingCharge.toDouble();
            taxRate = double.parse((bookingCharge * 0.18).toStringAsFixed(1));

            isLoading = false;
          });

          return;
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error fetching movie data: $error");
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _storeBooking() async {
    try {
      formatSeats(widget.selectedSeats);
      List<String> formattedSeats1 = widget.selectedSeats1;
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(generateOrderId())
          .set({
        "theatreName": widget.theatreName,
        "movieName": movieData["title"],
        "showTime": widget.showTime,
        "selectedSeats": formattedSeats1,
        "totalPrice": finalTotalPrice.toString(),
        "noofSeats": widget.noofSeats.toString(),
        "movieLanguage": movieData["language"],
        "date": widget.selectedDate,
        "movieFormat": movieData["format"],
        "movieImage": movieData["poster"],
        "likes": movieData["rating"],
        "timestamp": FieldValue.serverTimestamp(), // Store time of booking
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Store failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _storeOrderID() async {
    try {
      User? user = _auth.currentUser;
     DocumentReference bookingRef1 =  FirebaseFirestore.instance.collection('orders').doc(user?.uid);
      Map<String, dynamic> orderId = {
        "ordeId": generateOrderId(),       
      };
        await bookingRef1.set({
        "Orders": FieldValue.arrayUnion([orderId])
      }, SetOptions(merge: true));
    //  .set({
    //     "orderId": generateOrderId(),
    //     // Store time of booking
    //   });
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Store failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _storeOrderResult() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw "User not logged in";

      DocumentReference bookingRef =
          FirebaseFirestore.instance.collection('bookingHistory').doc(user.uid);

      Map<String, dynamic> bookingResult = {
        "movie": movieData["title"],
        "date": widget.selectedDate,
        "status": "Booking Successfully",
        "price": "₹${finalTotalPrice.toString()}",
        "poster": movieData["poster"],
      };

      await bookingRef.set({
        "history": FieldValue.arrayUnion([bookingResult])
      }, SetOptions(merge: true));

      print("✅ Booking result added to history");
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Store failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> _updateSeatsInFirebase() async {
    try {
      String theatreKey = widget.theatreName.replaceAll(" ", "");
      String movieKey = widget.movieTitle.toUpperCase().replaceAll(" ", "_");
      String firebasePath =
          "${widget.City}/theatres/$theatreKey/movies/$movieKey/showtimes/${widget.selectedDate}/${widget.showTime}/layout";

      DatabaseReference seatsRef = FirebaseDatabase.instance.ref(firebasePath);
      DatabaseEvent event = await seatsRef.once();

      if (event.snapshot.value == null) {
        CherryToast.error(
          title: Text("Seat layout not found!"),
          animationType: AnimationType.fromRight,
        ).show(context);
        return true; // 🚫 Prevents navigation since data is missing
      }

      var snapshot = event.snapshot.value;
      List<List<String>> seatLayout = (snapshot as List<dynamic>)
          .map((row) =>
              (row as List<dynamic>).map((seat) => seat.toString()).toList())
          .toList();

      List<String> bookedSeats = [];
      List<String> alreadyBookedSeats = [];

      for (String seat in widget.selectedSeats) {
        if (seat.contains("-")) {
          List<String> parts = seat.split("-");
          int rowNumber = int.parse(parts[0]);
          int colNumber = int.parse(parts[1]);

          seat = "${String.fromCharCode(65 + rowNumber)}${colNumber + 1}";
        }

        int row = seat.codeUnitAt(0) - 65;
        int col = int.parse(seat.substring(1)) - 1;

        if (row < 0 ||
            row >= seatLayout.length ||
            col < 0 ||
            col >= seatLayout[row].length) {
          continue;
        }

        if (seatLayout[row][col] == "S" || seatLayout[row][col] == "V") {
          seatLayout[row][col] = "B"; // Mark as booked
          bookedSeats.add(seat);
        } else {
          alreadyBookedSeats.add(seat);
        }
      }

      // 🎯 If all seats are already booked, return true to stop navigation
      if (alreadyBookedSeats.length == widget.selectedSeats.length) {
        CherryToast.warning(
          title: Text("Seats already booked: ${alreadyBookedSeats.join(", ")}"),
        ).show(context);
        return true;
      }

      if (bookedSeats.isNotEmpty) {
        await seatsRef.set(seatLayout);
        CherryToast.success(
          title: Text("Seats booked: ${bookedSeats.join(", ")}"),
        ).show(context);
      }

      return false; // ✅ Seats were booked successfully, allow navigation
    } catch (e) {
      CherryToast.error(
        title: Text("Seat Booking Failed: $e"),
      ).show(context);
      return true; // 🚫 Prevents navigation in case of errors
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
  num get finalTotalPrice =>
      widget.totalPrice + widget.bookingCharge + (taxRate * 2);

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
    formatSeats(widget.selectedSeats);
    List<String> formattedSeats1 = widget.selectedSeats1;
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
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.heart_solid,
                                    color: Colors.red,
                                  ),
                                  Text(
                                      '${movieData["rating"]}% • ${movieData["language"]} • ${movieData["format"]}',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TicketDivider(
                      height: 10,
                      dashWidth: 8,
                      dashHeight: 2,
                      color: Colors.grey),
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
                              children: formattedSeats1.map((seat) {
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 📜 Booking Details
            Text(
              "Booking Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildDetailRow('Seats', formattedSeats1.join(", ")),
            _buildDetailRow('${widget.noofSeats} X Tickets',
                '₹${widget.totalPrice.toStringAsFixed(2)}'),
            Divider(
              color: grey,
              thickness: 5,
            ),
            _buildDetailRow('Booking Charge', '₹${widget.bookingCharge}'),
            _buildDetailRow('GST', '₹${taxRate.toStringAsFixed(2)}'),
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
                  try {
                    bool allSeatsBooked = await _updateSeatsInFirebase();
                    if (allSeatsBooked) {
                      return; // 🚫 Stop navigation if all seats are already booked
                    }
                    await _storeBooking();
                    await _storeOrderID();
                    await _storeOrderResult();

                    if (!mounted) {
                      return; // Ensure widget is still in the tree before navigating
                    }
                    // Navigate to the TicketScreen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketScreen(
                          theatreName: widget.theatreName,
                          movieName: movieData["title"],
                          showTime: widget.showTime,
                          selectedSeats: formattedSeats1,
                          totalPrice: finalTotalPrice.toString(),
                          noofSeats: widget.noofSeats.toString(),
                          movieLanguage: movieData["language"],
                          date: widget.selectedDate,
                          movieFormat: movieData["format"],
                          movieImage: movieData["poster"],
                          orderId: generateOrderId(),
                          likes: movieData["rating"],
                        ),
                      ),
                    );
                  } catch (e) {
                    CherryToast.error(title: Text("Something went wrong: $e"))
                        .show(context);
                  }
                },
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
