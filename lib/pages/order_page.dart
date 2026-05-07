import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../widgets/fade_in_slide.dart';
import 'order_tracking_page.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const themeBg = Color(0xFF070A11);
    const cardBg = Color(0xFF121721);
    const accent = Color(0xFFFFB300);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        backgroundColor: themeBg,
        surfaceTintColor: themeBg,
      ),
      body: FadeInSlide(
        child: user == null
            ? Center(
                child: Text(
                  'Please log in to view orders',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              )
            : StreamBuilder<List<OrderModel>>(
                stream: FirestoreService().getOrdersStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error loading orders. If this is your first order, please wait a moment for the database to sync or check if a Firestore index is required.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    );
                  }
                  final orders = snapshot.data ?? [];
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: accent.withAlpha(77),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderIdDisp = order.id.isEmpty 
                          ? "NEW" 
                          : (order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase());

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderTrackingPage(order: order),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0x0DFFFFFF)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #$orderIdDisp',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status)
                                          .withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getStatusColor(order.status)
                                            .withAlpha(128),
                                      ),
                                    ),
                                    child: Text(
                                      order.status,
                                      style: GoogleFonts.poppins(
                                        color: _getStatusColor(order.status),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a')
                                    .format(order.createdAt),
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const Divider(height: 24, color: Colors.white10),
                              Row(
                                children: [
                                  Text(
                                    '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${order.totalAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      color: accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
