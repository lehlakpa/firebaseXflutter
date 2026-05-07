import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/status_dialog.dart';
import '../widgets/fade_in_slide.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String price;
  final String image;
  final String image2;
  final String description;

  const DetailPage({
    super.key,
    required this.id,
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
  int _quantity = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Future<void> _addToCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      StatusDialog.show(
        context,
        isSuccess: false,
        title: 'Login Required',
        message: 'Please log in to add items to your cart.',
      );
      return;
    }

    final userCartDoc = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(widget.id);

    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(userCartDoc);
        final currentQty = (snap.data()?['quantity'] ?? 0) as num;
        final nextQty = currentQty.toInt() + _quantity;

        tx.set(userCartDoc, {
          'productId': widget.id,
          'quantity': nextQty,
          'addedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      if (!mounted) return;
      StatusDialog.show(
        context,
        isSuccess: true,
        title: 'Added to Cart',
        message: '${widget.title} (x$_quantity) has been added to your cart.',
      );
    } catch (e) {
      if (!mounted) return;
      StatusDialog.show(
        context,
        isSuccess: false,
        title: 'Cart Error',
        message: 'Failed to add item to cart. Please try again.',
      );
    }
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
        child: FadeInSlide(
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQtyBtn(Icons.remove, () {
                              if (_quantity > 1) setState(() => _quantity--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _quantity.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _buildQtyBtn(Icons.add, () {
                              setState(() => _quantity++);
                            }),
                          ],
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
                    onPressed: _addToCart,
                    child: Text(
                      "Add to Cart",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Icon(icon, color: const Color(0xFFFFB300), size: 20),
      ),
    );
  }
}
