// ignore_for_file: constant_identifier_names

enum Lang { en, ar }

extension LangExt on Lang {
  String get name {
    switch (this) {
      case Lang.ar:
        return 'ar';
      case Lang.en:
        return 'en';
    }
  }
}

enum Currency { aed, sar, kwd, bdh, egp }

extension CurrencyExt on Currency {
  String get name {
    switch (this) {
      case Currency.aed:
        return 'AED';
      case Currency.sar:
        return 'SAR';
      case Currency.kwd:
        return 'KWD';
      case Currency.bdh:
        return 'BDH';
      case Currency.egp:
        return 'EGP';
    }
  }
}

enum TabbyPurchaseType {
  installments,
  credit_card_installments,
  monthly_billing,
}

extension TabbyPurchaseTypeExt on TabbyPurchaseType {
  String get name {
    switch (this) {
      case TabbyPurchaseType.installments:
        return 'installments';
      case TabbyPurchaseType.credit_card_installments:
        return 'credit_card_installments';
      case TabbyPurchaseType.monthly_billing:
        return 'monthly_billing';
    }
  }
}

enum OrderHistoryItemStatus {
  newOne,
  processing,
  complete,
  refunded,
  canceled,
  unknown,
}

extension OrderHistoryItemStatusExt on OrderHistoryItemStatus {
  String get name {
    switch (this) {
      case OrderHistoryItemStatus.newOne:
        return 'new';
      case OrderHistoryItemStatus.processing:
        return 'processing';
      case OrderHistoryItemStatus.complete:
        return 'complete';
      case OrderHistoryItemStatus.refunded:
        return 'refunded';
      case OrderHistoryItemStatus.canceled:
        return 'canceled';
      case OrderHistoryItemStatus.unknown:
        return 'unknown';
    }
  }
}

enum OrderHistoryItemPaymentMethod {
  card,
  cod,
}

enum Environment {
  stage,
  production,
}

extension EnvironmentExt on Environment {
  String get host {
    switch (this) {
      case Environment.stage:
        return 'https://api.tabby.dev/';
      case Environment.production:
        return 'https://api.tabby.ai/';
    }
  }
}

enum WebViewResult {
  close,
  authorized,
  rejected,
  expired,
}

extension WebViewResultExt on WebViewResult {
  String get name {
    switch (this) {
      case WebViewResult.close:
        return 'close';
      case WebViewResult.authorized:
        return 'authorized';
      case WebViewResult.rejected:
        return 'rejected';
      case WebViewResult.expired:
        return 'expired';
    }
  }
}
