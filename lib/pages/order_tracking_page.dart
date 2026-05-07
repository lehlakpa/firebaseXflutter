import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../widgets/status_dialog.dart';
import '../widgets/fade_in_slide.dart';

class OrderTrackingPage extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const themeBg = Color(0xFF070A11);
    const cardBg = Color(0xFF121721);
    const accent = Color(0xFFFFB300);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        title: Text(
          'Track Order',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        backgroundColor: themeBg,
        surfaceTintColor: themeBg,
      ),
      body: SafeArea(
        child: FadeInSlide(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(cardBg, accent),
                const SizedBox(height: 24),
                Text(
                  'Order Items',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ...order.items.map(
                  (item) => _buildItemTile(item, cardBg, accent),
                ),
                const SizedBox(height: 24),
                _buildOrderSummary(cardBg, accent),
                const SizedBox(height: 24),
                _buildShippingInfo(cardBg, accent),
                const SizedBox(height: 24),
                if (order.status.toLowerCase() == 'pending')
                  _buildActionButton(
                    context,
                    'Cancel Order',
                    Colors.redAccent.withAlpha(25),
                    Colors.redAccent,
                    () => _handleCancel(context),
                  ),
                if (order.status.toLowerCase() == 'cancelled' ||
                    order.status.toLowerCase() == 'delivered')
                  _buildActionButton(
                    context,
                    'Delete Order Record',
                    Colors.white10,
                    Colors.white54,
                    () => _handleDelete(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color bg,
    Color text,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          side: BorderSide(color: text.withAlpha(77)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.poppins(color: text, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      'Cancel Order',
      'Are you sure you want to cancel this order?',
    );
    if (confirmed) {
      try {
        await FirestoreService().updateOrder(order.id, {'status': 'Cancelled'});
        if (context.mounted) {
          StatusDialog.show(
            context,
            isSuccess: true,
            title: 'Order Cancelled',
            message: 'Your order has been cancelled successfully.',
            onConfirm: () => Navigator.pop(context),
          );
        }
      } catch (e) {
        if (context.mounted) {
          StatusDialog.show(
            context,
            isSuccess: false,
            title: 'Error',
            message: 'Failed to cancel order: $e',
          );
        }
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      'Delete Order',
      'This will remove the order record permanently. Continue?',
    );
    if (confirmed) {
      try {
        await FirestoreService().deleteOrder(order.id);
        if (context.mounted) {
          StatusDialog.show(
            context,
            isSuccess: true,
            title: 'Record Deleted',
            message: 'Order record has been removed from your history.',
            onConfirm: () => Navigator.pop(context),
          );
        }
      } catch (e) {
        if (context.mounted) {
          StatusDialog.show(
            context,
            isSuccess: false,
            title: 'Error',
            message: 'Failed to delete record: $e',
          );
        }
      }
    }
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF121721),
            title: Text(
              title,
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildStatusCard(Color cardBg, Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.isEmpty ? "NEW" : (order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase())}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.createdAt),
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (order.status.toLowerCase() == 'cancelled'
                              ? Colors.redAccent
                              : accent)
                          .withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: GoogleFonts.poppins(
                    color: order.status.toLowerCase() == 'cancelled'
                        ? Colors.redAccent
                        : accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (order.status.toLowerCase() == 'cancelled')
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order Cancelled',
                    style: GoogleFonts.montserrat(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            _buildTrackingTimeline(accent),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(Color accent) {
    final stages = ['Pending', 'Processing', 'Shipped', 'Delivered'];
    final currentStageIndex = stages.indexWhere(
      (s) => s.toLowerCase() == order.status.toLowerCase(),
    );

    return Row(
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentStageIndex;
        final isLast = index == stages.length - 1;

        return Expanded(
          flex: isLast ? 0 : 1,
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? accent : Colors.white10,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? accent : Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stages[index],
                    style: GoogleFonts.poppins(
                      color: isCompleted ? Colors.white : Colors.white38,
                      fontSize: 10,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: isCompleted ? accent : Colors.white10,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildItemTile(OrderItem item, Color cardBg, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.white10,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(Color cardBg, Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Information',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.phone, 'Phone', order.contactNumber),
          const SizedBox(height: 12),
          _infoRow(Icons.location_on, 'Address', order.address),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(Color cardBg, Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${order.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _summaryRow('Shipping', '\$0.00'),
          const Divider(height: 32, color: Colors.white10),
          _summaryRow(
            'Total',
            '\$${order.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
            accent: accent,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? accent,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isTotal ? Colors.white : Colors.white54,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: isTotal ? (accent ?? Colors.white) : Colors.white,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            fontSize: isTotal ? 20 : 14,
          ),
        ),
      ],
    );
  }
}
