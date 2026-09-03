import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/routes/route_name.dart';
import 'package:all_fold/featute/sales_order/controller/sales_order_controller.dart';
import 'package:all_fold/featute/sales_order/model/sales_order_list_model.dart';

class SalesOrderListScreen extends StatefulWidget {
  final bool showAppBar;
  const SalesOrderListScreen({super.key, this.showAppBar = true});

  @override
  State<SalesOrderListScreen> createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends State<SalesOrderListScreen>
    with AutomaticKeepAliveClientMixin {
  late SalesOrderController _controller;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SalesOrderController());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMoreOrders(_searchController.text.trim());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final content = Padding(
      padding: widget.showAppBar ? const EdgeInsets.all(16) : const EdgeInsets.only(top: 8),
      child: Column(
        spacing: 12,
        children: [
            // ── Search Bar ──────────────────────────────────────────────────
            TextField(
              controller: _searchController,
              onChanged: (val) {
                if (val.isEmpty || val.length >= 2) {
                  _controller.fetchSalesOrders(isRefresh: true, search: val);
                }
              },
              style: const TextStyle(fontFamily: 'Outfit', fontSize: FontSizes.small),
              decoration: InputDecoration(
                hintText: 'Search by order number or supplier…',
                hintStyle: const TextStyle(color: AppColors.grey, fontSize: FontSizes.small),
                prefixIcon: const Icon(Icons.search, color: AppColors.orange, size: 20),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.grey, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _controller.fetchSalesOrders(isRefresh: true);
                            },
                          )
                        : const SizedBox();
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderClr),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // ── Status Filter Chips ─────────────────────────────────────────
            SizedBox(
              height: 36,
              child: Obx(() {
                final selectedFilter = _controller.selectedStatusFilter.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: SalesOrderController.statusFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final filter = SalesOrderController.statusFilters[i];
                    final isSelected = selectedFilter == filter['value'];
                    return GestureDetector(
                      onTap: () => _controller.setStatusFilter(filter['value']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.orange : AppColors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.orange : AppColors.borderClr,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextWidget(
                          text: filter['label']!,
                          fontSize: FontSizes.xsmall,
                          fontWeight: isSelected ? FontWeights.bold : FontWeights.normal,
                          clr: isSelected ? AppColors.white : AppColors.grey,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // ── Orders List ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (_controller.isLoadingOrders.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                    ),
                  );
                }

                if (_controller.ordersError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                        const SizedBox(height: 12),
                        TextWidget(
                          text: _controller.ordersError.value,
                          clr: AppColors.grey,
                          fontSize: FontSizes.small,
                          maxLine: 3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _controller.fetchSalesOrders(isRefresh: true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const TextWidget(text: 'Retry', fontSize: FontSizes.small, clr: AppColors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_controller.salesOrders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _controller.fetchSalesOrders(isRefresh: true),
                    color: AppColors.orange,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 140),
                        const Center(
                          child: Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.borderClr),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: TextWidget(
                            text: 'No sales orders found.',
                            clr: AppColors.grey,
                            fontSize: FontSizes.mediuam,
                            fontWeight: FontWeights.medium,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _controller.fetchSalesOrders(isRefresh: true),
                  color: AppColors.orange,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _controller.salesOrders.length +
                        (_controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _controller.salesOrders.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                            ),
                          ),
                        );
                      }
                      return _SalesOrderCard(order: _controller.salesOrders[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        title: Row(
          spacing: 8,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
              child: const Icon(Icons.local_shipping_outlined, color: AppColors.white, size: 18),
            ),
            const TextWidget(
              text: 'Sales Orders',
              fontSize: FontSizes.large,
              fontWeight: FontWeights.bold,
              clr: AppColors.black,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.orange),
            onPressed: () => _controller.fetchSalesOrders(isRefresh: true),
          ),
        ],
      ),
      body: content,
    );
  }
}

// ─── Sales Order Card ────────────────────────────────────────────────────────

class _SalesOrderCard extends StatelessWidget {
  final SalesOrder order;
  const _SalesOrderCard({required this.order});

  Color _statusBg(String? s) {
    switch (s) {
      case 'processing':
        return AppColors.lightBitBlue;
      case 'completed':
        return AppColors.lightGreen;
      case 'cancelled':
        return AppColors.lightRed;
      default:
        return const Color(0xFFE1D9FF);
    }
  }

  Color _statusText(String? s) {
    switch (s) {
      case 'processing':
        return AppColors.themeColor;
      case 'completed':
        return AppColors.openText;
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.partialPickedText;
    }
  }

  Color _dispatchStatusColor(String? s) {
    switch (s) {
      case 'ready':
        return Colors.green;
      case 'partial':
        return AppColors.orange;
      case 'not_ready':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }

  String _formatAmount(num? val) {
    if (val == null) return '—';
    return '₹${val.toStringAsFixed(2)}';
  }

  String _formatQty(num? val) {
    if (val == null) return '0';
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesOrderController>();
    return GestureDetector(
      onTap: () {
        controller.selectedOrder.value = order;
        Get.toNamed(RoutesNames.salesOrderDetail, arguments: order);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderClr),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: order.orderNo ?? '—',
                          fontSize: FontSizes.mediuam,
                          fontWeight: FontWeights.bold,
                          clr: AppColors.black,
                        ),
                        const SizedBox(height: 2),
                        TextWidget(
                          text: order.supplier?.name ?? '—',
                          fontSize: FontSizes.xsmall,
                          clr: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg(order.orderStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextWidget(
                      text: order.statusLabel,
                      fontSize: FontSizes.xsmall,
                      fontWeight: FontWeights.semiBold,
                      clr: _statusText(order.orderStatus),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: 'Order Date',
                        value: order.orderDate ?? '—',
                      ),
                      _InfoChip(
                        icon: Icons.event_outlined,
                        label: 'Delivery',
                        value: order.expectedDeliveryDate ?? '—',
                      ),
                      _InfoChip(
                        icon: Icons.currency_rupee,
                        label: 'Total',
                        value: _formatAmount(order.grandTotal),
                        valueColor: AppColors.themeColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.borderClr, height: 1),
                  const SizedBox(height: 12),

                  // Qty summary row
                  Row(
                    children: [
                      _QtyBadge(
                        label: 'Ordered',
                        qty: _formatQty(order.totalOrderedQty),
                        color: AppColors.themeColor,
                      ),
                      const SizedBox(width: 8),
                      _QtyBadge(
                        label: 'Dispatched',
                        qty: _formatQty(order.totalDispatchedQty),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _QtyBadge(
                        label: 'Remaining',
                        qty: _formatQty(order.remainingDispatchQty),
                        color: AppColors.orange,
                      ),
                      const Spacer(),
                      if (order.dispatchStatus != null)
                        Row(
                          spacing: 4,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 14,
                              color: _dispatchStatusColor(order.dispatchStatus),
                            ),
                            TextWidget(
                              text: order.dispatchStatus!.capitalizeFirst ?? order.dispatchStatus!,
                              fontSize: FontSizes.xsmall,
                              fontWeight: FontWeights.semiBold,
                              clr: _dispatchStatusColor(order.dispatchStatus),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Dispatch CTA
                  if (order.canDispatch == true) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.toNamed(RoutesNames.dispatchPreview, arguments: order);
                        },
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const TextWidget(
                          text: 'Dispatch Now',
                          fontSize: FontSizes.small,
                          fontWeight: FontWeights.semiBold,
                          clr: AppColors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4,
          children: [
            Icon(icon, size: 11, color: AppColors.grey),
            TextWidget(text: label, fontSize: FontSizes.xsmall, clr: AppColors.grey),
          ],
        ),
        const SizedBox(height: 2),
        TextWidget(
          text: value,
          fontSize: FontSizes.small,
          fontWeight: FontWeights.semiBold,
          clr: valueColor,
        ),
      ],
    );
  }
}

class _QtyBadge extends StatelessWidget {
  final String label;
  final String qty;
  final Color color;

  const _QtyBadge({required this.label, required this.qty, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextWidget(text: qty, fontSize: FontSizes.small, fontWeight: FontWeights.bold, clr: color),
          TextWidget(text: label, fontSize: 9, clr: color),
        ],
      ),
    );
  }
}
