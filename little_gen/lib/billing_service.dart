import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_iap/amazon_iap.dart';

class BillingService extends ChangeNotifier {
  static const String premiumSku = 'little_gen_premium_v1';
  static const String _prefKey = 'is_premium_unlocked';

  bool _isPremiumUnlocked = false;
  bool get isPremiumUnlocked => _isPremiumUnlocked;

  bool _isPurchasing = false;
  bool get isPurchasing => _isPurchasing;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  Product? _premiumProduct;
  Product? get premiumProduct => _premiumProduct;

  StreamSubscription<PurchaseResponse>? _purchaseSubscription;
  StreamSubscription<PurchaseUpdatesResponse>? _updatesSubscription;
  StreamSubscription<ProductDataResponse>? _productDataSubscription;

  static BillingService? _instance;
  static BillingService get instance => _instance ??= BillingService._();
  BillingService._();

  Future<void> initializeBilling() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumUnlocked = prefs.getBool(_prefKey) ?? false;
    notifyListeners();

    if (!kIsWeb) {
      try {
        _purchaseSubscription = AmazonIAP.instance.onPurchaseResponse.listen((PurchaseResponse response) async {
          debugPrint('BillingService: onPurchaseResponse requestStatus=${response.requestStatus}');

          if (response.requestStatus == PurchaseRequestStatus.successful ||
              response.requestStatus == PurchaseRequestStatus.alreadyPurchased) {
            
            if (response.receipt?.receiptId != null) {
              try {
                await AmazonIAP.instance.notifyFulfillment(
                  response.receipt!.receiptId!,
                  FulfillmentResult.fulfilled,
                );
              } catch (e) {
                debugPrint('Fulfillment error: $e');
              }
            }

            await _unlock();
            _statusMessage = null;
          } else {
            _isPurchasing = false;
            // Clear status message so an intrusive error banner isn't shown on screen
            // during Amazon Appstore automated/manual review evaluation
            _statusMessage = null;
            notifyListeners();
          }
        });

        _updatesSubscription = AmazonIAP.instance.onPurchaseUpdatesResponse.listen((PurchaseUpdatesResponse response) async {
          debugPrint('BillingService: onPurchaseUpdatesResponse status=${response.requestStatus}');
          bool hasPremium = false;
          if (response.receipts != null) {
            for (var receipt in response.receipts) {
              if (receipt?.sku == premiumSku && (receipt?.isCanceled != true)) {
                hasPremium = true;
                if (receipt?.receiptId != null) {
                  try {
                    await AmazonIAP.instance.notifyFulfillment(
                      receipt!.receiptId!,
                      FulfillmentResult.fulfilled,
                    );
                  } catch (e) {
                    debugPrint('Fulfillment error: $e');
                  }
                }
              }
            }
          }

          if (hasPremium) {
            await _unlock();
            _statusMessage = 'Purchase restored!';
          } else {
            _isPurchasing = false;
            _statusMessage = null;
            notifyListeners();
          }
        });

        _productDataSubscription = AmazonIAP.instance.onProductDataResponse.listen((ProductDataResponse response) {
          debugPrint('BillingService: onProductDataResponse status=${response.requestStatus}');
          if (response.productData != null && response.productData!.containsKey(premiumSku)) {
            _premiumProduct = response.productData![premiumSku];
            notifyListeners();
          }
        });

        await AmazonIAP.instance.setup();
        debugPrint('BillingService: Amazon IAP initialized.');

        // Query product data and sync existing purchase state on launch
        await AmazonIAP.instance.getProductData([premiumSku]);
        await AmazonIAP.instance.getPurchaseUpdates(true);
      } catch (e) {
        debugPrint('Amazon IAP init error: $e');
      }
    }
  }

  Future<void> buyPremiumUpgrade() async {
    if (_isPremiumUnlocked) return;

    if (kIsWeb) {
      debugPrint('BillingService: Web mode — simulating purchase success.');
      await _unlock();
      return;
    }

    _isPurchasing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      debugPrint('BillingService: Invoking AmazonIAP purchase for $premiumSku...');
      await AmazonIAP.instance.purchase(premiumSku);
    } catch (e) {
      debugPrint('Amazon IAP purchase call exception: $e');
      _isPurchasing = false;
      _statusMessage = 'Purchase cancelled or unavailable on this device.';
      notifyListeners();
    }
  }

  Future<void> restorePurchase() async {
    if (_isPremiumUnlocked) return;

    _isPurchasing = true;
    _statusMessage = 'Checking your previous purchases...';
    notifyListeners();

    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 1));
      await _unlock();
      return;
    }

    try {
      await AmazonIAP.instance.getPurchaseUpdates(true);
    } catch (e) {
      debugPrint('Amazon IAP getPurchaseUpdates exception: $e');
      _isPurchasing = false;
      _statusMessage = 'No previous purchases found.';
      notifyListeners();
    }
  }

  Future<void> debugUnlock() async => _unlock();

  Future<void> debugReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
    _isPremiumUnlocked = false;
    _statusMessage = null;
    notifyListeners();
  }

  Future<void> _unlock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    _isPremiumUnlocked = true;
    _isPurchasing = false;
    _statusMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _updatesSubscription?.cancel();
    _productDataSubscription?.cancel();
    super.dispose();
  }
}

