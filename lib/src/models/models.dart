import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

import './enums.dart';

class ShippingAddress {
  const ShippingAddress({
    required this.city,
    required this.address,
    required this.zip,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      city: json['city'],
      address: json['address'],
      zip: json['zip'],
    );
  }

  final String city;
  final String address;
  final String zip;

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'address': address,
      'zip': zip,
    };
  }
}

class BuyerHistory {
  // true;

  BuyerHistory({
    required this.registeredSince,
    required this.loyaltyLevel,
    this.wishlistCount,
    this.isSocialNetworksConnected,
    this.isPhoneNumberVerified,
    this.isEmailVerified,
  });

  factory BuyerHistory.fromJson(Map<String, dynamic> json) {
    return BuyerHistory(
      registeredSince: json['registered_since'] as String,
      loyaltyLevel: json['loyalty_level'] as int,
      wishlistCount:
          json['wishlist_count'] != null ? json['wishlist_count'] as int : null,
      isSocialNetworksConnected: json['is_social_networks_connected'] != null
          ? json['is_social_networks_connected'] as bool
          : null,
      isPhoneNumberVerified: json['is_phone_number_verified'] != null
          ? json['is_phone_number_verified'] as bool
          : null,
      isEmailVerified: json['is_email_verified'] != null
          ? json['is_email_verified'] as bool
          : null,
    );
  }

  final String registeredSince; // "2019-08-24T14:15:22Z";
  final int loyaltyLevel; // 0;
  final int? wishlistCount; // 0;
  final bool? isSocialNetworksConnected; // true;
  final bool? isPhoneNumberVerified; // true;
  final bool? isEmailVerified;

  Map<String, dynamic> toJson() {
    return {
      'registered_since': registeredSince,
      'loyalty_level': loyaltyLevel,
      'wishlist_count': wishlistCount,
      'is_social_networks_connected': isSocialNetworksConnected,
      'is_phone_number_verified': isPhoneNumberVerified,
      'is_email_verified': isEmailVerified,
    };
  }
}

class Buyer {
  // "2019-08-24"

  Buyer({
    required this.email,
    required this.phone,
    required this.name,
    this.dob,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      email: json['email'],
      phone: json['phone'],
      name: json['name'],
      dob: json['dob'],
    );
  }

  final String email;
  final String phone;
  final String name;
  final String? dob;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'dob': dob,
    };
  }
}

class ProductWebURL {
  ProductWebURL({required this.webUrl});

  factory ProductWebURL.fromJson(Map<String, dynamic> json) {
    return ProductWebURL(webUrl: json['web_url']);
  }

  final String webUrl;

  Map<String, dynamic> toJson() {
    return {'web_url': webUrl};
  }
}

class Identifiable {
  Identifiable({required this.id});

  factory Identifiable.fromJson(Map<String, dynamic> json) {
    return Identifiable(id: json['id']);
  }

  final String id;

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class AvailableProducts {
  AvailableProducts({
    this.installments,
  });

  factory AvailableProducts.fromJson(Map<String, dynamic> json) {
    return AvailableProducts(
      installments: json['installments'] != null
          ? (json['installments'] as List<dynamic>)
              .map((i) => ProductWebURL.fromJson(i))
              .toList()
          : null,
    );
  }

  final List<ProductWebURL>? installments;
}

class SessionConfiguration {
  SessionConfiguration({required this.availableProducts});

  factory SessionConfiguration.fromJson(Map<String, dynamic> json) {
    return SessionConfiguration(
      availableProducts: AvailableProducts.fromJson(json['available_products']),
    );
  }

  final AvailableProducts availableProducts;
}

class CheckoutSession {
  CheckoutSession({
    required this.id,
    required this.status,
    required this.payment,
    required this.configuration,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'],
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.created,
      ),
      payment: Identifiable.fromJson(json['payment']),
      configuration: SessionConfiguration.fromJson(json['configuration']),
    );
  }

  final String id;
  final SessionStatus status;
  final Identifiable payment;
  final SessionConfiguration configuration;
}

// https://docs.tabby.ai/#operation/postCheckoutSession
class Payment {
  Payment({
    required this.amount,
    required this.currency,
    required this.buyer,
    required this.buyerHistory,
    required this.shippingAddress,
    required this.order,
    required this.orderHistory,
    this.description,
  });

  final String amount;
  final Currency currency;
  final Buyer buyer;
  final BuyerHistory buyerHistory;
  final ShippingAddress? shippingAddress;
  final Order order;
  final List<OrderHistoryItem> orderHistory;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency.displayName,
      'buyer': buyer.toJson(),
      'buyer_history': buyerHistory.toJson(),
      'shipping_address': shippingAddress?.toJson(),
      'order': order.toJson(),
      'order_history': orderHistory,
      'description': description
    };
  }
}

class OrderItem {
  // 2.00

  OrderItem({
    required this.title,
    required this.quantity,
    required this.unitPrice,
    required this.category,
    this.description,
    this.productUrl,
    this.referenceId,
    this.brand,
    this.color,
    this.gender,
    this.imageUrl,
    this.discountAmount,
  });

  final String title; // 'Sample Item #1'
  final int quantity; // 1
  final String unitPrice; // '300.00'
  final String category; // jeans / dress / shorts / etc
  final String? description; // 'To be displayed in tabby order information'
  final String? productUrl; // https://tabby.store/p/SKU123
  final String? referenceId; // 'SKU123'
  final String? brand;
  final String? color;
  final String? gender; // 'Male' | 'Female' | 'Kids' | 'Other';
  final String? imageUrl;
  final String? discountAmount;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'quantity': quantity,
      'unit_price': unitPrice,
      'category': category,
      'description': description,
      'product_url': productUrl,
      'reference_id': referenceId,
      'brand': brand,
      'color': color,
      'gender': gender,
      'image_url': imageUrl,
      'discount_amount': discountAmount,
    };
  }
}

class Order {
  Order({
    required this.referenceId,
    required this.items,
    this.shippingAmount,
    this.taxAmount,
    this.discountAmount,
  });

  final String referenceId; // #xxxx-xxxxxx-xxxx
  final List<OrderItem> items;
  final String? shippingAmount; // '50'
  final String? taxAmount; // '500'
  final String? discountAmount;

  Map<String, dynamic> toJson() {
    return {
      'reference_id': referenceId,
      'items': items,
      'shipping_amount': shippingAmount,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
    };
  }
}

class OrderHistoryItem {
  OrderHistoryItem({
    required this.amount,
    required this.status,
    required this.purchasedAt,
    this.paymentMethod,
    this.buyer,
    this.shippingAddress,
    this.items,
  });

  final String amount; // "0.00";
  final OrderHistoryItemStatus status;
  final String purchasedAt; // "2019-08-24T14:15:22Z";
  final OrderHistoryItemPaymentMethod? paymentMethod;
  final Buyer? buyer;
  final ShippingAddress? shippingAddress;
  final List<OrderItem>? items;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'status': status.name,
      'purchased_at': purchasedAt,
      'payment_method': paymentMethod?.name,
      'buyer': buyer,
      'shipping_address': shippingAddress,
      'items': items,
    };
  }
}

class MerchantUrls {
  MerchantUrls({
    required this.success,
    required this.failure,
    required this.cancel,
  });

  final String success;
  final String failure;
  final String cancel;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'failure': failure,
      'cancel': cancel,
    };
  }
}

class TabbyProduct {
  TabbyProduct({
    required this.type,
    required this.webUrl,
  });

  final TabbyPurchaseType type;
  final String webUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabbyProduct &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          webUrl == other.webUrl;

  @override
  int get hashCode => type.hashCode ^ webUrl.hashCode;
}

class TabbySessionAvailableProducts {
  TabbySessionAvailableProducts({
    this.installments,
  });

  final TabbyProduct? installments;
}

class TabbySession {
  TabbySession({
    required this.status,
    required this.sessionId,
    required this.paymentId,
    required this.availableProducts,
  });

  final SessionStatus status;
  final String sessionId;
  final String paymentId;
  final TabbySessionAvailableProducts availableProducts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabbySession &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          paymentId == other.paymentId;

  @override
  int get hashCode => sessionId.hashCode ^ paymentId.hashCode;
}

class TabbyCheckoutPayload {
  TabbyCheckoutPayload({
    required this.merchantCode,
    required this.lang,
    required this.payment,
  });

  final String merchantCode; // 'ae' | 'sa',
  final Lang lang; // 'en' | 'ar,
  final Payment payment;

  Map<String, dynamic> toJson() {
    return {
      'merchant_code': merchantCode,
      'lang': lang.name,
      'payment': payment,
    };
  }
}

class TransactionStatusResponse {
  TransactionStatusResponse({
    required this.id,
    required this.isPaid,
    this.rejectionReason,
  });

  factory TransactionStatusResponse.fromJson(Map<String, dynamic> json) {
    return TransactionStatusResponse(
      id: json['id'],
      isPaid: json['is_paid'],
      rejectionReason: json['rejection_reason'],
    );
  }

  final String id;
  final bool isPaid;
  final String? rejectionReason;
}

class EventProperties {
  EventProperties({
    required this.currency,
    required this.lang,
    this.installmentsCount,
  });

  final Currency currency;
  final Lang lang;
  final int? installmentsCount;

  Map<String, dynamic> toJson() {
    return {
      'currency': currency.displayName,
      'lang': lang.name,
      'installments_count': installmentsCount,
    };
  }
}
