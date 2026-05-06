import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../widgets/status_dialog.dart';
import 'order_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isUserDataLoaded = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData(String userId) async {
    if (_isUserDataLoaded) return;
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _phoneController.text = data?['contactNumber'] ?? '';
        _addressController.text =
            '${data?['province'] ?? ''}, ${data?['tole'] ?? ''}';
        _isUserDataLoaded = true;
      });
    }
  }

  Future<double> _getProductPrice(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) return 0;
    final data = doc.data() as Map<String, dynamic>?;
    final priceStr = data?['price']?.toString() ?? '0';
    return double.tryParse(priceStr) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    const themeBg = Color(0xFF070A11);
    const cardBg = Color(0xFF121721);
    const accent = Color(0xFFFFB300);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: Text(
          'Cart',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        backgroundColor: themeBg,
        surfaceTintColor: themeBg,
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = userSnap.data;
            if (user == null) {
              return Center(
                child: Text(
                  'Please log in to view your cart.',
                  style: GoogleFonts.poppins(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              );
            }

            _loadUserData(user.uid);

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('cart')
                  .orderBy('addedAt', descending: true)
                  .snapshots(),
              builder: (context, cartSnap) {
                if (cartSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (cartSnap.hasError) {
                  return Center(
                    child: Text(
                      'Error loading cart',
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  );
                }

                final cartDocs = cartSnap.data?.docs ?? [];

                if (cartDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 56,
                          color: accent.withAlpha(230),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items from Home to get started.',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Review Items',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = cartDocs[index];
                          final data = doc.data();
                          final productId = (data['productId'] ?? doc.id)
                              .toString();
                          final quantity = (data['quantity'] ?? 1) as num;
                          final qty = quantity.toInt().clamp(1, 999);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _CartItemTile(
                              accent: accent,
                              cardBg: cardBg,
                              productId: productId,
                              quantity: qty,
                              onIncrement: () async {
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('cart')
                                    .doc(productId)
                                    .set({
                                      'productId': productId,
                                      'quantity': qty + 1,
                                      'addedAt': FieldValue.serverTimestamp(),
                                    }, SetOptions(merge: true));
                              },
                              onDecrement: () async {
                                final next = qty - 1;
                                final cartItemDoc = _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('cart')
                                    .doc(productId);

                                if (next <= 0) {
                                  await cartItemDoc.delete();
                                } else {
                                  await cartItemDoc.set({
                                    'productId': productId,
                                    'quantity': next,
                                  }, SetOptions(merge: true));
                                }
                              },
                              onRemove: () async {
                                await _firestore
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('cart')
                                    .doc(productId)
                                    .delete();
                              },
                            ),
                          );
                        },
                        childCount: cartDocs.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipping Details',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Contact Number',
                              icon: Icons.phone,
                              accent: accent,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _addressController,
                              label: 'Delivery Address',
                              icon: Icons.location_on,
                              accent: accent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '* Updating these details will be used for this order.',
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: _CartSummary(
                          cartDocs: cartDocs,
                          getProductPrice: _getProductPrice,
                          accent: accent,
                          cardBg: cardBg,
                          onCheckout: () async {
                            if (cartDocs.isEmpty) return;
                            if (_phoneController.text.isEmpty ||
                                _addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all details'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            final subtotal = await _CartSummary._calcSubtotal(
                              cartDocs,
                              _getProductPrice,
                            );

                            List<OrderItem> orderItems = [];
                            for (var doc in cartDocs) {
                              final data = doc.data();
                              final productId =
                                  (data['productId'] ?? doc.id).toString();
                              final qty =
                                  ((data['quantity'] ?? 1) as num).toInt();

                              final productDoc = await _firestore
                                  .collection('products')
                                  .doc(productId)
                                  .get();
                              if (productDoc.exists) {
                                final p = Product.fromFirestore(productDoc);
                                orderItems.add(OrderItem(
                                  productId: productId,
                                  title: p.title,
                                  image: p.image,
                                  quantity: qty,
                                  price: double.tryParse(p.price) ?? 0,
                                ));
                              }
                            }

                            final order = OrderModel(
                              id: '',
                              userId: user.uid,
                              items: orderItems,
                              totalAmount: subtotal,
                              status: 'Pending',
                              createdAt: DateTime.now(),
                              contactNumber: _phoneController.text,
                              address: _addressController.text,
                            );

                            try {
                              await FirestoreService().placeOrder(order);
                              // Update user profile if changed
                              await _firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .set({
                                'contactNumber': _phoneController.text,
                              }, SetOptions(merge: true));

                              if (!mounted) return;
                              StatusDialog.show(
                                context,
                                isSuccess: true,
                                title: 'Order Placed!',
                                message:
                                    'Your order has been placed successfully. You can track it in the orders section.',
                                onConfirm: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrderPage(),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              if (!mounted) return;
                              StatusDialog.show(
                                context,
                                isSuccess: false,
                                title: 'Checkout Failed',
                                message: e.toString(),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54),
        prefixIcon: Icon(icon, color: accent, size: 20),
        filled: true,
        fillColor: Colors.white.withAlpha(13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Color accent;
  final Color cardBg;
  final String productId;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.accent,
    required this.cardBg,
    required this.productId,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0DFFFFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: firestore.collection('products').doc(productId).get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Container(
                      color: Colors.white10,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (!snap.hasData || !snap.data!.exists) {
                    return Container(
                      color: Colors.white10,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                      ),
                    );
                  }

                  final data = snap.data!.data();
                  final imageUrl = (data?['image'] ?? '').toString();
                  if (imageUrl.isEmpty) {
                    return Container(
                      color: Colors.white10,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                      ),
                    );
                  }

                  return Image.network(imageUrl, fit: BoxFit.cover);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: firestore.collection('products').doc(productId).get(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Loading...',
                        style: GoogleFonts.poppins(color: Colors.white54),
                      );
                    }
                    if (!snap.hasData || !snap.data!.exists) {
                      return Text(
                        'Unknown product',
                        style: GoogleFonts.poppins(color: Colors.white54),
                      );
                    }

                    final p = Product.fromFirestore(snap.data!);
                    final price = double.tryParse(p.price) ?? 0;
                    final lineTotal = price * quantity;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Line total: \$${lineTotal.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x1AFFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            icon: Icon(Icons.remove, color: accent),
                            onPressed: onDecrement,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              quantity.toString(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 30,
                            ),
                            icon: Icon(Icons.add, color: accent),
                            onPressed: onIncrement,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        'Remove',
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

class _CartSummary extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> cartDocs;
  final Future<double> Function(String productId) getProductPrice;
  final Color accent;
  final Color cardBg;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.cartDocs,
    required this.getProductPrice,
    required this.accent,
    required this.cardBg,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _calcSubtotal(cartDocs, getProductPrice),
      builder: (context, snap) {
        final subtotal = snap.data ?? 0.0;
        const shipping = 0.0;
        final total = subtotal + shipping;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x0DFFFFFF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Shipping',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${shipping.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Colors.white10),
              Row(
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onCheckout,
                  child: Text(
                    'Place Order',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (snap.connectionState == ConnectionState.waiting) ...[
                const SizedBox(height: 10),
                const Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Future<double> _calcSubtotal(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> cartDocs,
    Future<double> Function(String productId) getProductPrice,
  ) async {
    double subtotal = 0;

    for (final doc in cartDocs) {
      final data = doc.data();
      final productId = (data['productId'] ?? doc.id).toString();
      final qty = ((data['quantity'] ?? 1) as num).toInt().clamp(1, 999);
      final price = await getProductPrice(productId);
      subtotal += price * qty;
    }

    return subtotal;
  }
}
