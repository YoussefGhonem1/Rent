import 'package:flutter/material.dart';

class RealEstateCard extends StatefulWidget {
  final String image;
  final String title;
  final String price;
  final String location;
  final String description;
  final String rate;
  final String status;
  final bool isFavorite;

  const RealEstateCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.rate,
    required this.status,
    required this.isFavorite,
  });

  @override
  State<RealEstateCard> createState() => _RealEstateCardState();
}

class _RealEstateCardState extends State<RealEstateCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ صورة العقار
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child:
                widget.image.isNotEmpty
                    ? Image.network(
                      widget.image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      "images/fig.webp",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(height: 7),

          // ✅ تفاصيل العقار
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color.fromARGB(157, 19, 160, 141),
                      size: 15,
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 15.0,
                      color: Color.fromARGB(157, 19, 160, 141),
                    ),
                    Text(
                      widget.price,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  widget.status == "available" ? "Available" : "Booked",
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        widget.status == "available"
                            ? Color.fromARGB(157, 19, 160, 141)
                            : Colors.red,
                  ),
                ),
                const SizedBox(height: 2),

                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 3),
                    Text(widget.rate, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 80),

                    Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
