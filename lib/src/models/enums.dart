enum Lang { en, ar }

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

enum Environment {
  production,
}

extension EnvironmentExt on Environment {
  String get host {
    switch (this) {
      case Environment.production:
        return 'https://api.tabby.ai';
    }
  }

  String get analyticsHost {
    switch (this) {
      case Environment.production:
        return 'https://dp-event-collector.tabby.ai/v1/t';
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

enum AnalyticsEvent {
  snipperCardRendered, // = 'Snippet Cart Rendered',
  learnMoreClicked, // = 'Learn More Clicked',
  learnMorePopUpOpened, // = 'Learn More Pop Up Opened',
  learnMorePopUpClosed, // = 'Learn More Pop Up Closed',
}

extension AnalyticsEventExt on AnalyticsEvent {
  String get name {
    switch (this) {
      case AnalyticsEvent.snipperCardRendered:
        return 'Snippet Cart Rendered';
      case AnalyticsEvent.learnMoreClicked:
        return 'Learn More Clicked';
      case AnalyticsEvent.learnMorePopUpOpened:
        return 'Learn More Pop Up Opened';
      case AnalyticsEvent.learnMorePopUpClosed:
        return 'Learn More Pop Up Closed';
    }
  }
}
