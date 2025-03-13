import 'package:flutter/material.dart';

class CustomAppBar2 extends StatefulWidget {
  final String userName;
  final String location;
  final VoidCallback onTapQR;
  final ValueChanged<String> onChanged; // Callback for search input

  const CustomAppBar2({
    super.key,
    required this.userName,
    required this.location,
    required this.onTapQR,
    required this.onChanged, // Receive search input changes
  });

  @override
  _CustomAppBar2State createState() => _CustomAppBar2State();
}

class _CustomAppBar2State extends State<CustomAppBar2> {
  bool isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      isSearchActive = !isSearchActive;
      if (!isSearchActive) {
        _searchController.clear(); // Clear search field when closing
        widget.onChanged(""); // Reset search results
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.amber, // Adjust to match your design
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Animated Search Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSearchActive ? MediaQuery.of(context).size.width * 0.7 : 0,
            curve: Curves.easeInOut,
            child: isSearchActive
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Search movies...",
                      border: InputBorder.none,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: _toggleSearch, // Close search
                      ),
                    ),
                    onChanged: widget.onChanged, // Pass search query changes
                  )
                : const SizedBox(),
          ),

          if (!isSearchActive)
            // Greeting & Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey, ${widget.userName}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        widget.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ],
              ),
            ),

          // Icons (Search & QR Code)
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isSearchActive ? Icons.close : Icons.search,
                  color: Colors.black,
                ),
                onPressed: _toggleSearch, // Toggle search animation
              ),
              if (!isSearchActive)
                // QR Code Icon
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Colors.black),
                  onPressed: widget.onTapQR, // QR Code functionality
                ),
            ],
          ),
        ],
      ),
    );
  }
}
