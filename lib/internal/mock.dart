import 'package:tabby_flutter/models/enums.dart';
import 'package:tabby_flutter/models/models.dart';

final mockPayload = Payment(
  amount: '340',
  currency: Currency.sar,
  buyer: Buyer(
    email: 'id.card.success@tabby.ai',
    phone: '500000001',
    name: 'Yazan Khalid',
    dob: '2019-08-24',
  ),
  buyerHistory: BuyerHistory(
    loyaltyLevel: 0,
    registeredSince: '2019-08-24T14:15:22Z',
    wishlistCount: 0,
  ),
  shippingAddress: const ShippingAddress(
    city: 'string',
    address: 'string',
    zip: 'string',
  ),
  order: Order(referenceId: 'id123', items: [
    OrderItem(
      title: 'Jersey',
      description: 'Jersey',
      quantity: 1,
      unitPrice: '10.00',
      referenceId: 'uuid',
      productUrl: 'http://example.com',
      category: 'clothes',
    )
  ]),
  orderHistory: [
    OrderHistoryItem(
      purchasedAt: '2019-08-24T14:15:22Z',
      amount: '10.00',
      paymentMethod: OrderHistoryItemPaymentMethod.card,
      status: OrderHistoryItemStatus.newOne,
    )
  ],
);
