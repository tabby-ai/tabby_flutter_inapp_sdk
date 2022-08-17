// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import './enums.dart';

class ShippingAddress {
  final String city;
  final String address;
  final String zip;

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

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'address': address,
      'zip': zip,
    };
  }
}

class BuyerHistory {
  final String registeredSince; // "2019-08-24T14:15:22Z";
  final int loyaltyLevel; // 0;
  final int? wishlistCount; // 0;
  final bool? isSocialNetworksConnected; // true;
  final bool? isPhoneNumberVerified; // true;
  final bool? isEmailVerified; // true;

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
  final String email;
  final String phone;
  final String name;
  final String? dob; // "2019-08-24"

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
  final String web_url;
  ProductWebURL({required this.web_url});

  factory ProductWebURL.fromJson(Map<String, dynamic> json) {
    return ProductWebURL(web_url: json['web_url']);
  }

  Map<String, dynamic> toJson() {
    return {'web_url': web_url};
  }
}

class Identifiable {
  final String id;

  Identifiable({required this.id});

  factory Identifiable.fromJson(Map<String, dynamic> json) {
    return Identifiable(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class AvailableProducts {
  final List<ProductWebURL>? installments;
  final List<ProductWebURL>? credit_card_installments;
  final List<ProductWebURL>? monthly_billing;
  AvailableProducts({
    this.installments,
    this.credit_card_installments,
    this.monthly_billing,
  });

  factory AvailableProducts.fromJson(Map<String, dynamic> json) {
    return AvailableProducts(
      installments: json['installments'] != null
          ? (json['installments'] as List<dynamic>)
              .map((i) => ProductWebURL.fromJson(i))
              .toList()
          : null,
      credit_card_installments: json['credit_card_installments'] != null
          ? (json['credit_card_installments'] as List<dynamic>)
              .map((i) => ProductWebURL.fromJson(i))
              .toList()
          : null,
      monthly_billing: json['monthly_billing'] != null
          ? (json['monthly_billing'] as List<dynamic>)
              .map((i) => ProductWebURL.fromJson(i))
              .toList()
          : null,
    );
  }
}

class SessionConfiguration {
  final AvailableProducts available_products;
  SessionConfiguration({required this.available_products});

  factory SessionConfiguration.fromJson(Map<String, dynamic> json) {
    return SessionConfiguration(
      available_products:
          AvailableProducts.fromJson(json['available_products']),
    );
  }
}

class CheckoutSession {
  final String id;
  final Identifiable payment;
  final SessionConfiguration configuration;
  CheckoutSession({
    required this.id,
    required this.payment,
    required this.configuration,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'],
      payment: Identifiable.fromJson(json['payment']),
      configuration: SessionConfiguration.fromJson(json['configuration']),
    );
  }
}

// https://docs.tabby.ai/#operation/postCheckoutSession
class Payment {
  final String amount;
  final Currency currency;
  final Buyer buyer;
  final BuyerHistory buyerHistory;
  final ShippingAddress shippingAddress;
  final Order order;
  final List<OrderHistoryItem> orderHistory;
  final String? description;

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

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency.name,
      'buyer': buyer.toJson(),
      "buyer_history": buyerHistory.toJson(),
      'shipping_address': shippingAddress.toJson(),
      'order': order.toJson(),
      'order_history': orderHistory,
      'description': description
    };
  }
}

class OrderItem {
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
  final String? discountAmount; // 2.00

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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'quantity': quantity,
      'unit_price': unitPrice,
      "category": category,
      'description': description,
      "product_url": productUrl,
      "reference_id": referenceId,
      "brand": brand,
      "color": color,
      "gender": gender,
      "image_url": imageUrl,
      "discount_amount": discountAmount,
    };
  }
}

class Order {
  final String referenceId; // #xxxx-xxxxxx-xxxx
  final List<OrderItem> items;
  final String? shippingAmount; // '50'
  final String? taxAmount; // '500'
  final String? discountAmount; // '500'

  Order({
    required this.referenceId,
    required this.items,
    this.shippingAmount,
    this.taxAmount,
    this.discountAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      "reference_id": referenceId,
      "items": items,
      "shipping_amount": shippingAmount,
      "tax_amount": taxAmount,
      "discount_amount": discountAmount,
    };
  }
}

class OrderHistoryItem {
  final String amount; // "0.00";
  final OrderHistoryItemStatus status;
  final String purchasedAt; // "2019-08-24T14:15:22Z";
  final OrderHistoryItemPaymentMethod? paymentMethod;
  final Buyer? buyer;
  final ShippingAddress? shippingAddress;
  final List<OrderItem>? items;

  OrderHistoryItem({
    required this.amount,
    required this.status,
    required this.purchasedAt,
    this.paymentMethod,
    this.buyer,
    this.shippingAddress,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "status": status.name,
      "purchased_at": purchasedAt,
      'payment_method': paymentMethod?.name,
      'buyer': buyer,
      'shipping_address': shippingAddress,
      'items': items,
    };
  }
}

class TabbyProduct {
  final TabbyPurchaseType type;
  final String webUrl;

  TabbyProduct({
    required this.type,
    required this.webUrl,
  });

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
  final TabbyProduct? installments;
  final TabbyProduct? credit_card_installments;
  final TabbyProduct? monthly_billing;

  TabbySessionAvailableProducts({
    this.installments,
    this.credit_card_installments,
    this.monthly_billing,
  });
}

class TabbySession {
  final String sessionId;
  final String paymentId;
  final TabbySessionAvailableProducts availableProducts;

  TabbySession({
    required this.sessionId,
    required this.paymentId,
    required this.availableProducts,
  });

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
  final String merchantCode; // 'ae',
  final Lang lang; // 'en' | 'ar,
  final Payment payment;

  TabbyCheckoutPayload({
    required this.merchantCode,
    required this.lang,
    required this.payment,
  });

  Map<String, dynamic> toJson() {
    return {
      "merchant_code": merchantCode,
      "lang": lang.name,
      "payment": payment,
    };
  }
}

class TabbyCheckoutNavParams {
  final TabbySession session;
  final TabbyProduct selectedProduct;

  TabbyCheckoutNavParams({
    required this.session,
    required this.selectedProduct,
  });
}
