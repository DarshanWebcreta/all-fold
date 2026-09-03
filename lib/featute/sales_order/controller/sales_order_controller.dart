import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:all_fold/core/di/service_locator.dart';
import 'package:all_fold/data/api_service.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/sales_order/model/sales_order_list_model.dart';
import 'package:all_fold/featute/sales_order/model/dispatch_preview_model.dart';

class SalesOrderController extends GetxController {
  // ─── List State ─────────────────────────────────────────────────────────────
  final salesOrders = <SalesOrder>[].obs;
  final isLoadingOrders = false.obs;
  final ordersError = ''.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalOrders = 0.obs;
  final isLoadingMore = false.obs;
  final selectedStatusFilter = ''.obs; // '' = all

  // ─── Detail State ────────────────────────────────────────────────────────────
  final selectedOrder = Rxn<SalesOrder>();
  final isLoadingDetail = false.obs;

  // ─── Dispatch Preview State ──────────────────────────────────────────────────
  final dispatchPreview = Rxn<DispatchPreviewData>();
  final isLoadingPreview = false.obs;
  final previewError = ''.obs;
  final selectedShippingId = Rxn<dynamic>();
  final totalDispatchUnits = 0.0.obs;

  // ─── Dispatch Execution State ────────────────────────────────────────────────
  final isDispatching = false.obs;

  // ─── Dispatch Form Controllers ───────────────────────────────────────────────
  final vehicleNumberController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final driverNameController = TextEditingController();
  final driverPhoneController = TextEditingController();
  final remarksController = TextEditingController();

  // ─── Dispatch item qty map: orderItemId → qty controller ────────────────────
  final dispatchQtyControllers = <int, TextEditingController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSalesOrders();
  }

  @override
  void onClose() {
    vehicleNumberController.dispose();
    vehicleTypeController.dispose();
    driverNameController.dispose();
    driverPhoneController.dispose();
    remarksController.dispose();
    for (final c in dispatchQtyControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  // ─── Status Filter Helper ────────────────────────────────────────────────────
  static const List<Map<String, String>> statusFilters = [
    {'label': 'All', 'value': ''},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Processing', 'value': 'processing'},
    {'label': 'Completed', 'value': 'completed'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  void setStatusFilter(String value) {
    selectedStatusFilter.value = value;
    fetchSalesOrders(isRefresh: true);
  }

  // ─── Fetch Sales Order List ──────────────────────────────────────────────────
  Future<void> fetchSalesOrders({int page = 1, bool isRefresh = false, String? search}) async {
    if (isRefresh) currentPage.value = 1;

    if (page == 1) {
      isLoadingOrders.value = true;
      ordersError.value = '';
    } else {
      isLoadingMore.value = true;
    }

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getSalesOrders(
        orderStatus: selectedStatusFilter.value.isEmpty ? null : selectedStatusFilter.value,
        search: (search != null && search.isNotEmpty) ? search : null,
        perPage: 15,
        page: page,
      );

      if (response is Map) {
        final bool isSuccess = response['success'] == true;
        if (isSuccess && response['data'] != null) {
          final parsed = SalesOrderListResponse.fromJson(Map<String, dynamic>.from(response));
          final newItems = parsed.data?.data ?? [];
          if (page == 1) {
            salesOrders.assignAll(newItems);
          } else {
            salesOrders.addAll(newItems);
          }
          currentPage.value = parsed.data?.currentPage ?? 1;
          lastPage.value = parsed.data?.lastPage ?? 1;
          totalOrders.value = parsed.data?.total ?? 0;
        } else {
          ordersError.value = response['message'] ?? 'Failed to fetch sales orders';
        }
      } else {
        ordersError.value = 'Unexpected response format';
      }
    } catch (e) {
      debugPrint('Error fetching sales orders: $e');
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        ordersError.value = (data is Map && data['message'] != null)
            ? data['message']
            : e.message ?? 'Network error';
      } else {
        ordersError.value = 'Unable to load sales orders. Check your connection.';
      }
      // Load mock data as fallback
      if (page == 1) _loadMockSalesOrders();
    } finally {
      isLoadingOrders.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreOrders(String? search) async {
    if (currentPage.value >= lastPage.value || isLoadingMore.value) return;
    await fetchSalesOrders(page: currentPage.value + 1, search: search);
  }

  // ─── Fetch Sales Order Detail ────────────────────────────────────────────────
  Future<void> fetchSalesOrderDetail(int orderId) async {
    isLoadingDetail.value = true;
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getSalesOrderDetail(id: orderId);
      if (response is Map && response['data'] != null) {
        selectedOrder.value = SalesOrder.fromJson(Map<String, dynamic>.from(response['data']));
      }
    } catch (e) {
      debugPrint('Error fetching sales order detail: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // ─── Fetch Dispatch Preview ──────────────────────────────────────────────────
  Future<void> fetchDispatchPreview(int orderId) async {
    isLoadingPreview.value = true;
    previewError.value = '';
    dispatchPreview.value = null;

    // Reset dispatch form
    _clearDispatchForm();

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getSalesOrderDispatchPreview(id: orderId);

      if (response is Map && response['data'] != null) {
        final preview = DispatchPreviewData.fromJson(Map<String, dynamic>.from(response['data']));
        dispatchPreview.value = preview;
        selectedShippingId.value = preview.selectedShippingId ??
            (preview.shippingAddresses?.isNotEmpty == true
                ? preview.shippingAddresses!.first.id
                : 'default');

        // Initialize qty controllers for each item with default dispatch qty
        _initDispatchQtyControllers(preview.items ?? []);
      } else {
        previewError.value = (response is Map ? response['message'] : null) ?? 'Failed to load dispatch preview';
      }
    } catch (e) {
      debugPrint('Error fetching dispatch preview: $e');
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        previewError.value = (data is Map && data['message'] != null)
            ? data['message']
            : 'Network error loading dispatch preview';
      } else {
        previewError.value = 'Unable to load dispatch preview.';
      }
    } finally {
      isLoadingPreview.value = false;
    }
  }

  void _initDispatchQtyControllers(List<DispatchPreviewItem> items) {
    final activeIds = items.map((e) => e.orderItemId).whereType<int>().toSet();

    // Dispose and remove controllers for items that no longer exist in response
    final staleIds = dispatchQtyControllers.keys.where((id) => !activeIds.contains(id)).toList();
    for (final id in staleIds) {
      dispatchQtyControllers[id]?.dispose();
      dispatchQtyControllers.remove(id);
    }

    for (final item in items) {
      if (item.orderItemId != null) {
        final maxQty = item.qtyReady ?? 0;
        final remaining = item.qtyRemaining ?? 0;
        final isZero = maxQty <= 0 || remaining <= 0;
        final defaultQty = isZero ? 0 : (item.qtyDispatchDefault ?? maxQty);
        final formatted = _formatNum(defaultQty);

        if (dispatchQtyControllers.containsKey(item.orderItemId!)) {
          final existing = dispatchQtyControllers[item.orderItemId!]!;
          if (existing.text != formatted) {
            existing.text = formatted;
          }
        } else {
          final controller = TextEditingController(text: formatted);
          controller.addListener(_updateTotalDispatchUnits);
          dispatchQtyControllers[item.orderItemId!] = controller;
        }
      }
    }
    _updateTotalDispatchUnits();
  }

  void _updateTotalDispatchUnits() {
    num total = 0;
    for (final c in dispatchQtyControllers.values) {
      total += num.tryParse(c.text.trim()) ?? 0;
    }
    totalDispatchUnits.value = total.toDouble();
  }

  String _formatNum(num val) {
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }

  void _clearDispatchForm() {
    vehicleNumberController.clear();
    vehicleTypeController.clear();
    driverNameController.clear();
    driverPhoneController.clear();
    remarksController.clear();
  }

  // ─── Add Shipping Address ────────────────────────────────────────────────────
  Future<void> addShippingAddress({
    required int orderId,
    required String label,
    required String address,
    String? contactName,
    String? phone,
  }) async {
    FunctionalWidget.loaderHideShow(loaderShow: true);
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.addSalesOrderShippingAddress(
        id: orderId,
        body: {
          'label': label,
          'address': address,
          if (contactName != null && contactName.isNotEmpty) 'contact_name': contactName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      final bool isSuccess = response is Map ? response['success'] == true : true;
      final String msg = response is Map
          ? (response['message'] ?? 'Address added successfully.')
          : 'Address added successfully.';
      FunctionalWidget.showSnackBar(title: msg, success: isSuccess);
      if (isSuccess) {
        // Re-fetch preview to get updated address list
        await fetchDispatchPreview(orderId);
      }
    } catch (e) {
      debugPrint('Error adding shipping address: $e');
      FunctionalWidget.showSnackBar(title: 'Failed to add shipping address.', success: false);
    } finally {
      FunctionalWidget.loaderHideShow(loaderShow: false);
    }
  }

  // ─── Execute Dispatch ────────────────────────────────────────────────────────
  Future<bool> executeDispatch(int orderId) async {
    // Validate required fields
    if (vehicleNumberController.text.trim().isEmpty) {
      FunctionalWidget.showSnackBar(title: 'Vehicle number is required.', success: false);
      return false;
    }
    if (driverNameController.text.trim().isEmpty) {
      FunctionalWidget.showSnackBar(title: 'Driver name is required.', success: false);
      return false;
    }

    // Build items payload
    final List<Map<String, dynamic>> itemsPayload = [];
    dispatchQtyControllers.forEach((orderItemId, controller) {
      final qty = num.tryParse(controller.text.trim());
      if (qty != null && qty > 0) {
        itemsPayload.add({'order_item_id': orderItemId, 'quantity': qty});
      }
    });

    if (itemsPayload.isEmpty) {
      FunctionalWidget.showSnackBar(title: 'Enter dispatch quantity for at least one item.', success: false);
      return false;
    }

    isDispatching.value = true;
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.executeSalesOrderDispatch(
        id: orderId,
        body: {
          'address_confirmed': true,
          'shipping_address_id': selectedShippingId.value ?? 'default',
          'vehicle_number': vehicleNumberController.text.trim(),
          'vehicle_type': vehicleTypeController.text.trim(),
          'driver_name': driverNameController.text.trim(),
          'driver_phone': driverPhoneController.text.trim(),
          if (remarksController.text.trim().isNotEmpty) 'remarks': remarksController.text.trim(),
          'items': itemsPayload,
        },
      );

      final bool isSuccess = response is Map ? response['success'] == true : true;
      final String msg = response is Map
          ? (response['message'] ?? 'Dispatch recorded successfully.')
          : 'Dispatch recorded successfully.';

      FunctionalWidget.showSnackBar(title: msg, success: isSuccess);

      if (isSuccess) {
        // Refresh list so status is up to date
        await fetchSalesOrders(isRefresh: true);
      }
      return isSuccess;
    } catch (e) {
      debugPrint('Error executing dispatch: $e');
      String errorMsg = 'Failed to execute dispatch.';
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) errorMsg = data['message'];
      }
      FunctionalWidget.showSnackBar(title: errorMsg, success: false);
      return false;
    } finally {
      isDispatching.value = false;
    }
  }

  // ─── Mock Fallback Data ──────────────────────────────────────────────────────
  void _loadMockSalesOrders() {
    salesOrders.assignAll([
      SalesOrder(
        id: 42,
        orderNo: 'SO-2026-0042',
        orderDate: '2026-09-02',
        expectedDeliveryDate: '2026-09-10',
        orderStatus: 'processing',
        orderStatusLabel: 'Processing',
        grandTotal: 15400.00,
        supplier: SalesOrderSupplier(id: 5, name: 'Acme Supplies Ltd', code: 'SUP-005'),
        totalOrderedQty: 100,
        totalDispatchedQty: 0,
        remainingDispatchQty: 100,
        canDispatch: true,
        dispatchStatus: 'ready',
        items: [
          SalesOrderItem(
            id: 102,
            productId: 15,
            productName: 'Premium Folding Box A',
            sku: 'SKU-FB-001',
            quantity: 100,
            qtyDispatched: 0,
            qtyRemaining: 100,
            unitPrice: 140.00,
            lineTotal: 14000.00,
          ),
        ],
      ),
      SalesOrder(
        id: 43,
        orderNo: 'SO-2026-0043',
        orderDate: '2026-09-01',
        expectedDeliveryDate: '2026-09-12',
        orderStatus: 'pending',
        orderStatusLabel: 'Pending',
        grandTotal: 8750.00,
        supplier: SalesOrderSupplier(id: 3, name: 'Global Parts Co.', code: 'SUP-003'),
        totalOrderedQty: 50,
        totalDispatchedQty: 20,
        remainingDispatchQty: 30,
        canDispatch: false,
        dispatchStatus: 'partial',
        items: [],
      ),
    ]);
    currentPage.value = 1;
    lastPage.value = 1;
    totalOrders.value = 2;
  }
}
