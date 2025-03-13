import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticket_booking/Screens/TicketQR.dart';
import 'package:ticket_booking/Widgets/CustomDivider.dart';
import 'package:ticket_booking/const/colors.dart';


class CheckOutScreen extends StatefulWidget {
  final String theatreName;
  final String showTime;
  final List<String> selectedSeats;
  final double totalPrice;
  final int noofSeats;
  final String movieTitle;
  final String selectedDate;
  // final String date;
  const CheckOutScreen({
    super.key,
    required this.theatreName,
    required this.showTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.noofSeats,
    required this.movieTitle,
    required this.selectedDate, // ✅ Corrected variable
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  late Map<String, dynamic> movieData;
  late int bookingCharge;
  late num taxRate;
  late String formattedSeat;

  @override
  void initState() {
    super.initState();
    _loadMovieData();
  }

  String formattedDate() {
    DateTime date = DateFormat("dd.MM.yyyy").parse(widget.selectedDate);
    return DateFormat("EEEE, d MMM").format(date);
  }

  void _loadMovieData() {
    // for (var theatre in theatreData["theatres"].values) {
    //   if (theatre["movies"].containsKey(widget.movieTitle)) {
    //     movieData = theatre["movies"][widget.movieTitle];
    //     bookingCharge = theatre["tax"];
    //     taxRate = bookingCharge * 0.18; // Example tax calculation (18%)
    //     break;
    //   }
    // }
  }

  String generateOrderId() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int date = DateTime.now().day;
    int month = DateTime.now().month;
    int yr = DateTime.now().year;
    return "$date$month$yr$timestamp";
  }

  num get totalPrice => widget.totalPrice + bookingCharge + (taxRate * 2);

  @override
  Widget build(BuildContext context) {
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
                                '${movieData["title"]}( ${movieData["language"]} ${movieData["format"]})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 40,
                              ),
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
                    color: Colors.grey,
                  ),
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
                              children: widget.selectedSeats.map((seat) {
                                List<String> parts = seat
                                    .split("-"); // Split "0-1" into ["0", "1"]
                                String rowLetter = String.fromCharCode(65 +
                                    int.parse(parts[
                                        0])); // Convert row index to A, B, C...
                                formattedSeat =
                                    "$rowLetter-${int.parse(parts[1]) + 1}"; // Convert to "A-1"

                                return Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: amber, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    formattedSeat, // ✅ Shows seat as "A-1"
                                    style: const TextStyle(
                                        color: grey, fontSize: 12),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Spacer(),
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
            Text('Booking Details',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildDetailRow(
                '${widget.noofSeats} X Tickets', '₹${totalPrice.toString()}'),
            const Divider(),
            Text('Taxes & Fees',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildDetailRow('Booking Charge', '₹$bookingCharge'),
            _buildDetailRow('CGST (9%)', '₹${(taxRate).toStringAsFixed(2)}'),
            _buildDetailRow('SGST (9%)', '₹${(taxRate).toStringAsFixed(2)}'),
            const Divider(),
            const Spacer(),
            // 💳 Pay Now Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                String orderId = generateOrderId();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketScreen(
                      theatreName: widget.theatreName,
                      movieName: movieData["title"],
                      showTime: widget.showTime,
                      selectedSeats: widget.selectedSeats.map((seat) {
                        List<String> parts = seat.split("-");
                        String rowLetter = String.fromCharCode(65 + int.parse(parts[0]));
                        return "$rowLetter-${int.parse(parts[1]) + 1}";
                      }).toList(),
                      totalPrice: totalPrice.toInt(),
                      noofSeats: widget.noofSeats,
                      movieLanguage: movieData["language"],
                      date: widget.selectedDate,
                      movieFormat: movieData["format"],
                      movieImage: movieData["poster"],
                      orderId: orderId,
                    ),
                  ),
                );
              },
              child: Text("Pay ₹${totalPrice.toDouble()}",
                  style: TextStyle(fontSize: 16, color: white)),
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
