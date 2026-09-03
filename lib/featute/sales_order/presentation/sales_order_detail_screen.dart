import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/routes/route_name.dart';
import 'package:all_fold/featute/sales_order/controller/sales_order_controller.dart';
import 'package:all_fold/featute/sales_order/model/sales_order_list_model.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  const SalesOrderDetailScreen({super.key});

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  late SalesOrderController _controller;
  SalesOrder? _order;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SalesOrderController>();
    _order = Get.arguments as SalesOrder?;
    if (_order?.id != null) {
      _controller.fetchSalesOrderDetail(_order!.id!);
    }
  }

  String _formatNum(num? val) {
    if (val == null) return '0';
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }

  String _formatAmount(num? val) {
    if (val == null) return '—';
    return '₹${val.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: TextWidget(
          text: _order?.orderNo ?? 'Order Detail',
          fontSize: FontSizes.large,
          fontWeight: FontWeights.bold,
          clr: AppColors.black,
        ),
        actions: [
          if (_order?.canDispatch == true)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(RoutesNames.dispatchPreview, arguments: _order),
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const TextWidget(
                  text: 'Dispatch',
                  fontSize: FontSizes.small,
                  fontWeight: FontWeights.bold,
                  clr: AppColors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
      body: Obx(() {
        final order = _controller.selectedOrder.value ?? _order;
        if (order == null) {
          return const Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
          ));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Summary Card ─────────────────────────────────────────
              _SectionCard(
                title: 'Order Summary',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    _DetailRow(label: 'Order No', value: order.orderNo ?? '—'),
                    _DetailRow(label: 'Order Date', value: order.orderDate ?? '—'),
                    _DetailRow(label: 'Expected Delivery', value: order.expectedDeliveryDate ?? '—'),
                    _DetailRow(label: 'Status', value: order.statusLabel, isStatus: true, status: order.orderStatus),
                    _DetailRow(label: 'Grand Total', value: _formatAmount(order.grandTotal), isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Supplier Info ──────────────────────────────────────────────
              if (order.supplier != null)
                _SectionCard(
                  title: 'Supplier / Customer',
                  icon: Icons.business_outlined,
                  child: Column(
                    children: [
                      _DetailRow(label: 'Name', value: order.supplier!.name ?? '—'),
                      _DetailRow(label: 'Code', value: order.supplier!.code ?? '—'),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // ── Dispatch Progress ──────────────────────────────────────────
              _SectionCard(
                title: 'Dispatch Progress',
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    _DetailRow(label: 'Total Ordered', value: _formatNum(order.totalOrderedQty)),
                    _DetailRow(label: 'Total Dispatched', value: _formatNum(order.totalDispatchedQty)),
                    _DetailRow(label: 'Remaining', value: _formatNum(order.remainingDispatchQty)),
                    if (order.remainingDispatchQty != null && order.totalOrderedQty != null && order.totalOrderedQty! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const TextWidget(text: 'Progress', fontSize: FontSizes.xsmall, clr: AppColors.grey),
                                TextWidget(
                                  text: '${((order.totalDispatchedQty ?? 0) / order.totalOrderedQty! * 100).toStringAsFixed(0)}%',
                                  fontSize: FontSizes.xsmall,
                                  fontWeight: FontWeights.semiBold,
                                  clr: AppColors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (order.totalDispatchedQty ?? 0) / order.totalOrderedQty!,
                                backgroundColor: AppColors.borderClr,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Product Line Items ─────────────────────────────────────────
              if (order.items != null && order.items!.isNotEmpty)
                _SectionCard(
                  title: 'Product Items (${order.items!.length})',
                  icon: Icons.inventory_2_outlined,
                  child: Column(
                    children: order.items!.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i > 0) const Divider(color: AppColors.borderClr, height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.lightBitBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: TextWidget(
                                    text: '${i + 1}',
                                    fontSize: FontSizes.xsmall,
                                    fontWeight: FontWeights.bold,
                                    clr: AppColors.themeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: item.productName ?? '—',
                                      fontSize: FontSizes.small,
                                      fontWeight: FontWeights.semiBold,
                                      clr: AppColors.black,
                                    ),
                                    const SizedBox(height: 2),
                                    TextWidget(
                                      text: item.sku ?? '',
                                      fontSize: FontSizes.xsmall,
                                      clr: AppColors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        _MiniStat(label: 'Qty', value: _formatNum(item.quantity), color: AppColors.themeColor),
                                        const SizedBox(width: 8),
                                        _MiniStat(label: 'Dispatched', value: _formatNum(item.qtyDispatched), color: Colors.green),
                                        const SizedBox(width: 8),
                                        _MiniStat(label: 'Remaining', value: _formatNum(item.qtyRemaining), color: AppColors.orange),
                                        const Spacer(),
                                        TextWidget(
                                          text: _formatAmount(item.lineTotal),
                                          fontSize: FontSizes.small,
                                          fontWeight: FontWeights.bold,
                                          clr: AppColors.black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),

      // ── Bottom Dispatch Button ───────────────────────────────────────────────
      bottomNavigationBar: Obx(() {
        final order = _controller.selectedOrder.value ?? _order;
        if (order?.canDispatch != true) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.borderClr)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(RoutesNames.dispatchPreview, arguments: order),
              icon: const Icon(Icons.local_shipping_outlined, size: 20),
              label: const TextWidget(
                text: 'Proceed to Dispatch',
                fontSize: FontSizes.mediuam,
                fontWeight: FontWeights.bold,
                clr: AppColors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isStatus;
  final String? status;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isStatus = false,
    this.status,
  });

  Color _statusBg(String? s) {
    switch (s) {
      case 'processing': return AppColors.lightBitBlue;
      case 'completed': return AppColors.lightGreen;
      case 'cancelled': return AppColors.lightRed;
      default: return const Color(0xFFE1D9FF);
    }
  }

  Color _statusText(String? s) {
    switch (s) {
      case 'processing': return AppColors.themeColor;
      case 'completed': return AppColors.openText;
      case 'cancelled': return AppColors.red;
      default: return AppColors.partialPickedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(text: label, fontSize: FontSizes.small, clr: AppColors.grey),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _statusBg(status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextWidget(
                text: value,
                fontSize: FontSizes.xsmall,
                fontWeight: FontWeights.semiBold,
                clr: _statusText(status),
              ),
            )
          else
            TextWidget(
              text: value,
              fontSize: FontSizes.small,
              fontWeight: isBold ? FontWeights.bold : FontWeights.normal,
              clr: isBold ? AppColors.black : AppColors.black,
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          TextWidget(text: value, fontSize: FontSizes.xsmall, fontWeight: FontWeights.bold, clr: color),
          TextWidget(text: label, fontSize: 9, clr: color),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderClr),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              spacing: 8,
              children: [
                Icon(icon, size: 16, color: AppColors.orange),
                TextWidget(
                  text: title,
                  fontSize: FontSizes.small,
                  fontWeight: FontWeights.semiBold,
                  clr: AppColors.black,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}
