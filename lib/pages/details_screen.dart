import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String price;
  final String image;
  final String image2;
  final String description;

  const DetailPage({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.image2,
    required this.description,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121826),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: 2,
                              itemBuilder: (context, index) {
                                return Hero(
                                  tag: '${widget.title}$index',
                                  child: Image.network(
                                    index == 0 ? widget.image : widget.image2,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                            // Dot indicators
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: ListenableBuilder(
                                listenable: _pageController,
                                builder: (context, child) {
                                  final pageIndex = _pageController.hasClients
                                      ? _pageController.page?.round() ?? 0
                                      : 0;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(2, (dotIndex) {
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width: pageIndex == dotIndex ? 12 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: pageIndex == dotIndex
                                              ? const Color(0xFFFFB300)
                                              : Colors.white30,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        widget.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '\$${widget.price}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Add to Cart",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
