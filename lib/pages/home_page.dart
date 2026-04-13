import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        "image": "https://picsum.photos/400/200?1",
        "title": "Wake up early",
        "desc": "Start your day at 6 AM",
      },
      {
        "image": "https://picsum.photos/400/200?2",
        "title": "Exercise",
        "desc": "Stay fit and healthy",
      },
      {
        "image": "https://picsum.photos/400/200?3",
        "title": "Study",
        "desc": "Focus on your goals",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Discipline"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔥 Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: items.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.network(
                            item["image"]!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),

                          // Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),

                          // Text
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item["desc"]!,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 🔥 Details Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCard("Wake up early", "Completed 5 days", Icons.wb_sunny),
                _buildCard(
                  "Exercise",
                  "Completed 3 days",
                  Icons.fitness_center,
                ),
                _buildCard("Study", "Completed 4 days", Icons.book),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
