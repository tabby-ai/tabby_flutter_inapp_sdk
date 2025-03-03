import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

Payment createMockPayload({
  required String amount,
  required String email,
  required String phone,
  required Currency currency,
}) {
  return Payment(
    amount: amount,
    currency: currency,
    buyer: Buyer(
      email: email,
      phone: phone,
      name: 'Mohammad Khalid',
    ),
    buyerHistory: BuyerHistory(
      loyaltyLevel: 0,
      registeredSince: '2019-08-24T14:15:22Z',
      wishlistCount: 0,
      isEmailVerified: true,
      isPhoneNumberVerified: true,
      isSocialNetworksConnected: true,
    ),
    shippingAddress: const ShippingAddress(
      city: 'Dubai',
      address: 'string',
      zip: 'string',
    ),
    order: Order(
      referenceId: 'id123',
      items: [
        OrderItem(
          title: 'Jersey',
          description: 'Jersey',
          quantity: 1,
          unitPrice: '10.00',
          referenceId: 'uuid',
          productUrl: 'http://example.com',
          category: 'clothes',
        )
      ],
    ),
    orderHistory: [
      OrderHistoryItem(
        purchasedAt: '2019-08-24T14:15:22Z',
        amount: '10.00',
        paymentMethod: OrderHistoryItemPaymentMethod.card,
        status: OrderHistoryItemStatus.newOne,
      )
    ],
  );
}
