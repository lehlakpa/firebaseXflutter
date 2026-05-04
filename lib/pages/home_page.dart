import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your details screen here
import 'details_screen.dart';
import '../widgets/banner_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List of PageControllers for each product image carousel
  late List<PageController> productPageControllers;

  @override
  void initState() {
    super.initState();
    // Initialize PageControllers for each product
    productPageControllers = List.generate(
      products.length,
      (index) => PageController(),
    );
  }

  @override
  void dispose() {
    // Dispose all PageControllers
    for (var controller in productPageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  final products = [
    {
      "title": "G522 Lightspeed",
      "price": "169.99",
      "image":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/g522/g522-gallery-1.png",
      "image2":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/g522/g522-gallery-2.png",
    },
    {
      "title": "G733 Lightspeed",
      "price": "119.00",
      "image":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/g733/gallery/g733-white-1.png",
      "image2":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/g733/gallery/g733-white-2.png",
    },
    {
      "title": "Pro X Wireless",
      "price": "199.00",
      "image":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/pro-x-wireless/pro-x-wireless-gallery-1.png",
      "image2":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/pro-x-wireless/pro-x-wireless-gallery-2.png",
    },
    {
      "title": "G435 Lightspeed",
      "price": "79.99",
      "image":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/g435/g435-gallery-white-1.png",
      "image2":
          "https://resource.logitechg.com/w_800,c_limit,q_auto,f_auto/content/dam/gaming/en/products/g435/g435-gallery-white-2.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A11), // Deeper Midnight
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🔍 TRACKING SEARCH BAR (Sticky Header)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchDelegate(),
            ),

            // 🔥 MAIN CONTENT
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildAnimatedHeader(),
                  const SizedBox(height: 20),
                  BannerSlider(
                    banners: const [
                      "https://images.unsplash.com/photo-1585386959984-a41552262c6a",
                      "https://images.unsplash.com/photo-1518444028785-8c4b2c0a5c0d",
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "FEATURED",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70, // Amber Gold
                    ),
                  ),
                  Text(
                    " PRODUCTS",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            // 🔳 PRODUCT GRID
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductCard(index),
                  childCount: products.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PEAK",
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 9.0),
          child: Text(
            "PREMIUM",
            style: GoogleFonts.montserrat(
              letterSpacing: 1.5,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          "AUDIO",
          style: GoogleFonts.montserrat(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFB300), // Amber Gold
          ),
        ),
        Text(
          "Buy Now, Pay Later",
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white70, // Amber Gold
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(int index) {
    final p = products[index];
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                title: p["title"]!,
                price: p["price"]!,
                image: p["image"]!,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121721), // Slate Midnight
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x0DFFFFFF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x33333333),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image carousel with dot indicators
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: productPageControllers[index],
                      itemCount: 2,
                      itemBuilder: (context, imgIndex) {
                        return Hero(
                          tag: p["title"]! + imgIndex.toString(),
                          child: Image.network(
                            imgIndex == 0 ? p["image"]! : p["image2"]!,
                            fit: BoxFit.contain,
                            cacheWidth: 300,
                          ),
                        );
                      },
                    ),
                    // Dot indicators for product images
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: ListenableBuilder(
                        listenable: productPageControllers[index],
                        builder: (context, child) {
                          final pageIndex =
                              productPageControllers[index].hasClients
                              ? productPageControllers[index].page?.round() ?? 0
                              : 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (imgIndex) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: pageIndex == imgIndex ? 12 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: pageIndex == imgIndex
                                      ? const Color(0xFFFFB300)
                                      : Colors.white30,
                                  borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 12),
              Text(
                p["title"]!,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${p["price"]}",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFB300),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- STICKY SEARCH BAR DELEGATE ---
class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 80.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF070A11), // Match background
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      alignment: Alignment.center,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white38),
            const SizedBox(width: 12),
            Text(
              "Search premium gear...",
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.tune, color: Color(0xFFFFB300), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
