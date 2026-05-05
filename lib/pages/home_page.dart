import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'details_screen.dart';
import '../widgets/banner_slider.dart';
import '../../models/product_model.dart';
import '../../models/banner_model.dart';
import '../../services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A11),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchDelegate(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildAnimatedHeader(),
                  const SizedBox(height: 20),
                  StreamBuilder<List<BannerModel>>(
                    stream: firestoreService.getBannersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'Error loading banners',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      }
                      final banners = snapshot.data ?? [];
                      return BannerSlider(banners: banners);
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "FEATURED",
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: StreamBuilder<List<Product>>(
                stream: firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Center(child: Text('No products available', style: TextStyle(color: Colors.white70))),
                      ),
                    );
                  }
                  final productsList = snapshot.data!;
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      childCount: productsList.length,
                      (context, index) =>
                          _buildProductCard(productsList, index),
                    ),
                  );
                },
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
            color: const Color(0xFFFFB300),
          ),
        ),
        Text(
          "Buy Now, Pay Later",
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(List<Product> productsList, int index) {
    final p = productsList[index];
    final PageController pageController = PageController();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                title: p.title,
                price: p.price,
                image: p.image,
                image2: p.image1,
                description: p.description,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121721),
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
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: 2,
                      itemBuilder: (context, imgIndex) {
                        return Hero(
                          tag: '${p.title}$imgIndex',
                          child: Image.network(
                            imgIndex == 0 ? p.image : p.image1,
                            fit: BoxFit.contain,
                            cacheWidth: 300,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: ListenableBuilder(
                        listenable: pageController,
                        builder: (context, child) {
                          final pageIndex = pageController.hasClients
                              ? pageController.page?.round() ?? 0
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
                p.title,
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
                    "\$${p.price}",
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
      color: const Color(0xFF070A11),
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
