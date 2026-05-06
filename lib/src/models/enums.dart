enum Lang { en, ar }

extension LangDisplayNam on Lang {
  String get displayName {
    switch (this) {
      case Lang.en:
        return 'en';
      case Lang.ar:
        return 'ar';
    }
  }
}

enum Currency { aed, sar, kwd, bhd, qar }

extension CurrencyExt on Currency {
  String get displayName {
    switch (this) {
      case Currency.aed:
        return 'AED';
      case Currency.sar:
        return 'SAR';
      case Currency.kwd:
        return 'KWD';
      case Currency.bhd:
        return 'BHD';
      case Currency.qar:
        return 'QAR';
    }
  }

  String get countryName {
    switch (this) {
      case Currency.aed:
        return 'emirates';
      case Currency.sar:
        return 'saudi';
      case Currency.kwd:
        return 'kuwait';
      case Currency.bhd:
        return 'bahrain';
      case Currency.qar:
        return 'qatar';
    }
  }

  int get decimals {
    switch (this) {
      case Currency.aed:
        return 2;
      case Currency.sar:
        return 2;
      case Currency.kwd:
        return 3;
      case Currency.bhd:
        return 3;
      case Currency.qar:
        return 2;
    }
  }
}

enum TabbyPurchaseType {
  installments,
}

extension TabbyPurchaseTypeExt on TabbyPurchaseType {
  String get name {
    switch (this) {
      case TabbyPurchaseType.installments:
        return 'installments';
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

enum Environment { production, staging }

extension EnvironmentExt on Environment {
  /// Host used only for the bootstrap `/api/v1/sdk/config` call. Per-request
  /// hosts are resolved from the loaded `SdkConfig` based on currency.
  String get bootstrapApiBaseUrl {
    switch (this) {
      case Environment.production:
        return 'https://api.tabby.ai';
      case Environment.staging:
        return 'https://api.tabby.dev';
    }
  }
}

enum WebViewResult {
  close,
  authorized,
  rejected,
  expired,
}

enum SessionStatus {
  created,
  rejected,
}

enum JSEventType {
  onChangeDimensions,
  onLearnMoreClicked,
}

extension JSEventTypeExt on JSEventType {
  String get dtoName {
    switch (this) {
      case JSEventType.onChangeDimensions:
        return 'onChangeDimensions';
      case JSEventType.onLearnMoreClicked:
        return 'onLearnMoreClicked';
    }
  }
}
