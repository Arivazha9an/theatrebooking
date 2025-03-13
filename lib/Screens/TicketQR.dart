import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:ticket_booking/Widgets/CustomZigZagDivider.dart';
import 'package:ticket_booking/const/colors.dart';

class TicketScreen extends StatefulWidget {
  final String theatreName;
  final String showTime;
  final List<String> selectedSeats;
  final int totalPrice;
  final int noofSeats;
  final String movieName;
  final String movieImage;
  final String movieLanguage;
  final String movieFormat;
  final String orderId;
  final String date;
  const TicketScreen({
    super.key,
    required this.theatreName,
    required this.showTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.noofSeats,
    required this.movieName,
    required this.movieImage,
    required this.movieLanguage,
    required this.movieFormat,  
    required this.orderId,
    required this.date,
  });

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // Local Data for Ticket
  final Map<String, dynamic> ticketData = {
    "movieTitle": "POR THOZHIL (TAMIL WITH ENGLISH SUB) (2D)",
    "language": "Tamil",
    "format": "2D",
    "cinema": "Kamala Talkies A/C.",
    "date": "06/06/2023",
    "time": "10:15 AM",
    "orderID": "MG120409",
    "amount": "₹521.96",
    "seats": "G7, G8, G9, G10",
    "movieImage":
        "https://m.media-amazon.com/images/M/MV5BZDkyN2QwYzAtZjk4My00YmYyLThmMTItZDJmYmQxMmE3ZGIxXkEyXkFqcGc@._V1_.jpg",
    "qrData": "MG120409-06/06/2023-10:15AM-G7,G8,G9,G10"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "Your Ticket",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTicketCard(),
            const SizedBox(height: 20),
            _buildSpacer(),
            _buildDownloadShareButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(00),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Movie Poster & Title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.movieImage,
                          width: 150,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movieName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${widget.movieLanguage} • ${widget.movieFormat}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Ticket Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTicketInfo1("Theatre", widget.theatreName),
                          SizedBox(height: 20),
                          _buildTicketInfo1("Date", widget.date ),
                          SizedBox(height: 20),
                          _buildTicketInfo1("Order ID", widget.orderId),
                          SizedBox(height: 20),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTicketInfo(
                              "Seats", widget.selectedSeats.join(", ")),
                          SizedBox(height: 20),
                          _buildTicketInfo("Time", widget.showTime),
                          SizedBox(height: 20),
                          _buildTicketInfo(
                              "Amount", widget.totalPrice.toString()),
                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Custom Ticket Divider
                ],
              ),
            ),
            CustomZigZag(
              height: 12,
              width: 5,
              //  height: 1,
              color: white,
            ),

            // QR Code
            const SizedBox(height: 10),
            QrImageView(
              data: widget.orderId,
              size: 140,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 5),
            const Text(
              "Get this QR scanned at the entrance",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTicketInfo1(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Spacer _buildSpacer() {
    return const Spacer();
  }

  Widget _buildDownloadShareButtons() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            label: const Text("Download"),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: () {
              print(widget.orderId.toString());
            },
            label: const Text("Share"),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              backgroundColor: blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
