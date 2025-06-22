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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.teal[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(1, 1),
            ),
          ],
          border: Border.all(
            // إضافة الحدود هنا
            color: Colors.teal.shade400,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة
            Padding(
              padding: EdgeInsets.only(right: 5, left: 5, top: 5),
              child: SizedBox(
                height: 110,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child:
                      widget.image.isNotEmpty
                          ? Image.network(
                            widget.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            "images/fig.webp",
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
            ),
      
            // الصورة
            SizedBox(
              height: 40,
              child: ClipRRect(
                child:
                    widget.status == "available"
                        ? Image.asset(
                          "images/available.PNG",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          "images/booked.PNG",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
      
            // التفاصيل
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 3, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.teal[900], size: 24),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 5),
      
                  // السعر والمفضلة
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.teal[900], size: 20),
                      // السعر
                      Text(
                        " ${widget.price} ج.م",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
      
                  // التقييم والحالة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // التقييم
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
      
                          widget.rate == "null"
                              ? Text(
                                "لا تقييم",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.teal[900],
                                ),
                              )
                              : Text(
                                widget.rate,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.teal[900],
                                ),
                              ),
                        ],
                      ),
                      // أيقونة المفضلة
                      Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isFavorite ? Colors.red : Colors.teal[900],
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
