import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/sales_order/controller/sales_order_controller.dart';
import 'package:all_fold/featute/sales_order/model/sales_order_list_model.dart';
import 'package:all_fold/featute/sales_order/model/dispatch_preview_model.dart';

class DispatchPreviewScreen extends StatefulWidget {
  const DispatchPreviewScreen({super.key});

  @override
  State<DispatchPreviewScreen> createState() => _DispatchPreviewScreenState();
}

class _DispatchPreviewScreenState extends State<DispatchPreviewScreen> {
  late SalesOrderController _controller;
  SalesOrder? _order;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SalesOrderController>();
    _order = Get.arguments as SalesOrder?;
    if (_order?.id != null) {
      _controller.fetchDispatchPreview(_order!.id!);
    }
  }

  String _formatNum(num? val) {
    if (val == null) return '0';
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }

  Future<void> _showAddAddressDialog() async {
    if (_order?.id == null) return;
    await Get.dialog(
      _AddAddressDialog(
        onSave: (label, address, contact, phone) {
          _controller.addShippingAddress(
            orderId: _order!.id!,
            label: label,
            address: address,
            contactName: contact,
            phone: phone,
          );
        },
      ),
    );
  }

  Future<void> _executeDispatch() async {
    final success = await _controller.executeDispatch(_order!.id!);
    if (success && mounted) {
      Get.back();
      Get.back(); // Go back to list
    }
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
        title: const TextWidget(
          text: 'Dispatch Preview',
          fontSize: FontSizes.large,
          fontWeight: FontWeights.bold,
          clr: AppColors.black,
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingPreview.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
            ),
          );
        }

        if (_controller.previewError.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                const SizedBox(height: 12),
                TextWidget(
                  text: _controller.previewError.value,
                  clr: AppColors.grey,
                  fontSize: FontSizes.small,
                  maxLine: 3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _controller.fetchDispatchPreview(_order!.id!),
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

        final preview = _controller.dispatchPreview.value;
        if (preview == null) return const SizedBox();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Header ───────────────────────────────────────────────
              _PreviewCard(
                title: 'Order Info',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    _InfoRow(label: 'Order No', value: preview.orderNo ?? '—'),
                    _InfoRow(label: 'Customer', value: preview.customerName ?? '—'),
                    if (preview.supplier != null) ...[
                      _InfoRow(label: 'Contact', value: preview.supplier!.phone ?? '—'),
                      _InfoRow(label: 'Address', value: preview.supplier!.address ?? '—'),
                    ],
                    _InfoRow(label: 'Total Units', value: _formatNum(preview.totalUnits), isBold: true),
                    _InfoRow(label: 'SKU Count', value: '${preview.skuCount ?? 0}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Shipping Address Selector ──────────────────────────────────
              _PreviewCard(
                title: 'Shipping Address',
                icon: Icons.location_on_outlined,
                trailing: TextButton.icon(
                  onPressed: _showAddAddressDialog,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.orange),
                  label: const TextWidget(text: 'Add New', fontSize: FontSizes.xsmall, clr: AppColors.orange),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
                child: Builder(
                  builder: (context) {
                    final rawList = preview.shippingAddresses ?? [];
                    final fallbackAddress = preview.supplier?.address ?? _order?.supplier?.name ?? '';
                    final List<Map<String, dynamic>> addressList = [];

                    for (final a in rawList) {
                      addressList.add({
                        'id': a.id ?? 'default',
                        'label': a.label ?? 'Shipping Address',
                        'address': a.address ?? '',
                      });
                    }

                    // Only prepend fallback if rawList doesn't contain default
                    final hasDefault = addressList.any((a) {
                      final idStr = a['id'].toString().toLowerCase();
                      final addrStr = a['address'].toString().trim().toLowerCase();
                      return idStr == 'default' ||
                          (fallbackAddress.isNotEmpty && addrStr == fallbackAddress.trim().toLowerCase());
                    });

                    if (!hasDefault && fallbackAddress.isNotEmpty) {
                      addressList.insert(0, {
                        'id': 'default',
                        'label': 'Default Address',
                        'address': fallbackAddress,
                      });
                    }

                    // Deduplicate by unique id and address
                    final seenIds = <String>{};
                    final seenAddrs = <String>{};
                    final uniqueTiles = <Widget>[];

                    for (int i = 0; i < addressList.length; i++) {
                      final item = addressList[i];
                      final idKey = item['id'].toString();
                      final addrKey = item['address'].toString().trim().toLowerCase();

                      if (seenIds.contains(idKey) || (addrKey.isNotEmpty && seenAddrs.contains(addrKey))) {
                        continue;
                      }
                      seenIds.add(idKey);
                      if (addrKey.isNotEmpty) seenAddrs.add(addrKey);

                      final isItemDefault = idKey.toLowerCase() == 'default' || i == 0;

                      uniqueTiles.add(
                        _ShippingAddressTile(
                          id: item['id'],
                          label: item['label'] as String,
                          address: item['address'] as String,
                          isDefault: isItemDefault,
                        ),
                      );
                    }

                    if (uniqueTiles.isEmpty && fallbackAddress.isNotEmpty) {
                      uniqueTiles.add(
                        _ShippingAddressTile(
                          id: 'default',
                          label: 'Default Address',
                          address: fallbackAddress,
                          isDefault: true,
                        ),
                      );
                    }

                    return Column(children: uniqueTiles);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ── Dispatch Items ─────────────────────────────────────────────
              _PreviewCard(
                title: 'Items to Dispatch',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: (preview.items ?? []).asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final controller = _controller.dispatchQtyControllers[item.orderItemId];
                    return Column(
                      children: [
                        if (i > 0) const Divider(color: AppColors.borderClr, height: 20),
                        _DispatchItemRow(item: item, qtyController: controller),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // ── Vehicle & Driver Info ──────────────────────────────────────
              _PreviewCard(
                title: 'Vehicle & Driver',
                icon: Icons.directions_car_outlined,
                child: Column(
                  children: [
                    _FormField(
                      label: 'Vehicle Number *',
                      controller: _controller.vehicleNumberController,
                      hint: 'e.g. MH-04-AB-1234',
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      label: 'Vehicle Type',
                      controller: _controller.vehicleTypeController,
                      hint: 'e.g. Tata Ace, Truck',
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      label: 'Driver Name *',
                      controller: _controller.driverNameController,
                      hint: 'Full name',
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      label: 'Driver Phone',
                      controller: _controller.driverPhoneController,
                      hint: '+91 9XXXXXXXXX',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _FormField(
                      label: 'Remarks',
                      controller: _controller.remarksController,
                      hint: 'Optional notes…',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),

      // ── Confirm Dispatch Button ────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          final isDispatching = _controller.isDispatching.value;
          final totalUnits = _controller.totalDispatchUnits.value;
          final canDispatch = !isDispatching && totalUnits > 0;
        
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.borderClr)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canDispatch ? _executeDispatch : null,
                icon: isDispatching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: TextWidget(
                  text: isDispatching ? 'Processing…' : 'Confirm Dispatch',
                  fontSize: FontSizes.mediuam,
                  fontWeight: FontWeights.bold,
                  clr: AppColors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canDispatch ? AppColors.orange : AppColors.grey,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.4),
                  disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Shipping Address Tile ───────────────────────────────────────────────────

class _ShippingAddressTile extends StatelessWidget {
  final dynamic id;
  final String label;
  final String address;
  final bool isDefault;

  const _ShippingAddressTile({
    required this.id,
    required this.label,
    required this.address,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SalesOrderController>();
    return Obx(() {
      final selectedId = controller.selectedShippingId.value;
      final isSelected = selectedId != null && id != null && selectedId.toString() == id.toString();

      return GestureDetector(
        onTap: () => controller.selectedShippingId.value = id,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF9F5) : AppColors.white,
            border: Border.all(
              color: isSelected ? AppColors.orange : AppColors.borderClr,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.orange : AppColors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextWidget(
                            text: label,
                            fontSize: FontSizes.small,
                            fontWeight: FontWeights.bold,
                            clr: AppColors.black,
                          ),
                        ),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const TextWidget(
                              text: 'DEFAULT',
                              fontSize: 9,
                              fontWeight: FontWeights.bold,
                              clr: AppColors.orange,
                            ),
                          ),
                      ],
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      TextWidget(
                        text: address,
                        fontSize: FontSizes.xsmall,
                        clr: AppColors.grey,
                        maxLine: 3,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Dispatch Item Row ───────────────────────────────────────────────────────

class _DispatchItemRow extends StatelessWidget {
  final DispatchPreviewItem item;
  final TextEditingController? qtyController;

  const _DispatchItemRow({required this.item, this.qtyController});

  String _fmt(num? v) {
    if (v == null) return '0';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = (item.qtyReady ?? 0);
    final remainingQty = (item.qtyRemaining ?? 0);
    final isFullyDispatched = (item.quantity != null && (item.qtyDispatched ?? 0) >= item.quantity!) || remainingQty <= 0;
    final isZeroQty = maxQty <= 0 || isFullyDispatched;
    final hasShortage = maxQty > 0 && maxQty < remainingQty;

    return Opacity(
      opacity: isZeroQty ? 0.6 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    TextWidget(text: item.sku ?? '', fontSize: FontSizes.xsmall, clr: AppColors.grey),
                  ],
                ),
              ),
              if (isFullyDispatched)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextWidget(text: 'Fully Dispatched', fontSize: 9, fontWeight: FontWeights.bold, clr: AppColors.openText),
                )
              else if (maxQty <= 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextWidget(text: 'Not Ready', fontSize: 9, fontWeight: FontWeights.bold, clr: AppColors.grey),
                )
              else if (hasShortage)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextWidget(text: 'Partial', fontSize: 9, fontWeight: FontWeights.bold, clr: AppColors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SmallStat(label: 'Ordered', value: _fmt(item.quantity), color: AppColors.themeColor),
              const SizedBox(width: 6),
              _SmallStat(label: 'Dispatched', value: _fmt(item.qtyDispatched), color: Colors.green),
              const SizedBox(width: 6),
              _SmallStat(label: 'Remaining', value: _fmt(item.qtyRemaining), color: AppColors.grey),
              const SizedBox(width: 6),
              _SmallStat(label: 'Ready Now', value: _fmt(item.qtyReady), color: AppColors.orange),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const TextWidget(text: 'Dispatch Qty:', fontSize: FontSizes.small, clr: AppColors.grey),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: qtyController,
                  enabled: !isZeroQty,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  onChanged: (val) {
                    if (maxQty > 0) {
                      final parsed = num.tryParse(val);
                      if (parsed != null && parsed > maxQty) {
                        qtyController?.text = _fmt(maxQty);
                        qtyController?.selection = TextSelection.collapsed(offset: qtyController!.text.length);
                      }
                    }
                  },
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: FontSizes.small,
                    fontWeight: FontWeight.w600,
                    color: isZeroQty ? AppColors.grey : AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: isZeroQty ? AppColors.borderClr.withValues(alpha: 0.25) : AppColors.lightGrey,
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderClr.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.borderClr),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              TextWidget(
                text: 'Max: ${_fmt(item.qtyReady)}',
                fontSize: FontSizes.xsmall,
                clr: isZeroQty ? AppColors.grey : AppColors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SmallStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          TextWidget(text: value, fontSize: 10, fontWeight: FontWeights.bold, clr: color),
          TextWidget(text: label, fontSize: 8, clr: color),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _PreviewCard({required this.title, required this.icon, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderClr),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
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
              children: [
                Icon(icon, size: 16, color: AppColors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: TextWidget(
                    text: title,
                    fontSize: FontSizes.small,
                    fontWeight: FontWeights.semiBold,
                    clr: AppColors.black,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: TextWidget(text: label, fontSize: FontSizes.small, clr: AppColors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextWidget(
              text: value,
              fontSize: FontSizes.small,
              fontWeight: isBold ? FontWeights.bold : FontWeights.normal,
              clr: AppColors.black,
              textAlign: TextAlign.right,
              maxLine: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text: label, fontSize: FontSizes.xsmall, fontWeight: FontWeights.semiBold, clr: AppColors.grey),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontFamily: 'Outfit', fontSize: FontSizes.small),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.grey, fontSize: FontSizes.xsmall),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: AppColors.lightGrey,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.borderClr),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Add Address Dialog ──────────────────────────────────────────────────────

class _AddAddressDialog extends StatefulWidget {
  final Function(String label, String address, String? contact, String? phone) onSave;

  const _AddAddressDialog({required this.onSave});

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  late final TextEditingController labelCtrl;
  late final TextEditingController addressCtrl;
  late final TextEditingController contactCtrl;
  late final TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    labelCtrl = TextEditingController();
    addressCtrl = TextEditingController();
    contactCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    labelCtrl.dispose();
    addressCtrl.dispose();
    contactCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextWidget(
              text: 'Add Shipping Address',
              fontSize: FontSizes.large,
              fontWeight: FontWeights.bold,
              clr: AppColors.black,
            ),
            const SizedBox(height: 16),
            _DialogField(controller: labelCtrl, label: 'Label (e.g. Branch Office)'),
            const SizedBox(height: 10),
            _DialogField(controller: addressCtrl, label: 'Full Address', maxLines: 3),
            const SizedBox(height: 10),
            _DialogField(controller: contactCtrl, label: 'Contact Name (optional)'),
            const SizedBox(height: 10),
            _DialogField(controller: phoneCtrl, label: 'Phone (optional)', keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const TextWidget(text: 'Cancel', fontSize: FontSizes.small),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final label = labelCtrl.text.trim();
                      final address = addressCtrl.text.trim();
                      if (label.isEmpty || address.isEmpty) {
                        Get.snackbar('Error', 'Label and Address are required.',
                            backgroundColor: AppColors.lightRed, colorText: AppColors.red);
                        return;
                      }
                      final contact = contactCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      Get.back();
                      widget.onSave(
                        label,
                        address,
                        contact.isEmpty ? null : contact,
                        phone.isEmpty ? null : phone,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const TextWidget(
                      text: 'Save',
                      fontSize: FontSizes.small,
                      fontWeight: FontWeights.bold,
                      clr: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;

  const _DialogField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Outfit', fontSize: FontSizes.small),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Outfit', color: AppColors.grey, fontSize: FontSizes.small),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColors.lightGrey,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderClr),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
