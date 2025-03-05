import 'package:flutter/material.dart';
import 'package:tabby_flutter/mock.dart';
import 'package:tabby_flutter/pages/chechout_page.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class NewSession extends StatefulWidget {
  const NewSession({super.key});

  @override
  State<NewSession> createState() => _NewSessionState();
}

class _NewSessionState extends State<NewSession> {
  String _status = 'idle';
  TabbySession? session;

  late Lang lang;

  String _amount = '340';
  late TextEditingController _amountController;
  String _email = 'id.success@tabby.ai';
  late TextEditingController _emailController;
  String _phone = '+971500000001';
  late TextEditingController _phoneController;
  String _merchantCode = 'ae';
  late TextEditingController _merchantCodeController;
  Currency _selectedCurrency = Currency.aed;

  void _setStatus(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _amount);
    _emailController = TextEditingController(text: _email);
    _phoneController = TextEditingController(text: _phone);
    _merchantCodeController = TextEditingController(text: _merchantCode);
    WidgetsBinding.instance.addPostFrameCallback((_) => getCurrentLang());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void getCurrentLang() {
    final myLocale = Localizations.localeOf(context);
    setState(() {
      lang = myLocale.languageCode == 'ar' ? Lang.ar : Lang.en;
    });
  }

  Future<void> createSession() async {
    try {
      _setStatus('pending');

      final s = await TabbySDK().createSession(TabbyCheckoutPayload(
        merchantCode: _merchantCode,
        lang: lang,
        payment: createMockPayload(
          amount: _amount,
          currency: _selectedCurrency,
          email: _email,
          phone: _phone,
        ),
      ));

      debugPrint('Session id: ${s.sessionId}');

      setState(() {
        session = s;
      });
      _setStatus('created');
    } catch (e, s) {
      printError(e, s);
      _setStatus('error');
    }
  }

  void openCheckOutPage() {
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session not available'),
        ),
      );
      return;
    }
    if (session!.status == SessionStatus.rejected) {
      final rejectionText =
          lang == Lang.ar ? TabbySDK.rejectionTextAr : TabbySDK.rejectionTextEn;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rejectionText),
        ),
      );
      return;
    }
    if (session!.availableProducts.installments == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session has no products'),
        ),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: TabbyCheckoutNavParams(
        selectedProduct: session!.availableProducts.installments!,
      ),
    );
  }

  void openInAppBrowser() {
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session not available'),
        ),
      );
      return;
    }
    if (session!.status == SessionStatus.rejected) {
      final rejectionText =
          lang == Lang.ar ? TabbySDK.rejectionTextAr : TabbySDK.rejectionTextEn;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rejectionText),
        ),
      );
      return;
    }
    if (session!.availableProducts.installments == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session has no products'),
        ),
      );
      return;
    }
    TabbyWebView.showWebView(
      context: context,
      webUrl: session!.availableProducts.installments!.webUrl,
      onResult: (WebViewResult resultCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultCode.name),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  void refreshSession() {
    setState(() {
      session = null;
    });
  }

  void noop() {}

  void _updateAmount(String newAmount) {
    setState(() {
      _amount = newAmount;
    });
  }

  void _updateEmail(String newEmail) {
    setState(() {
      _email = newEmail;
    });
  }

  void _updatePhone(String newPhone) {
    setState(() {
      _phone = newPhone;
    });
  }

  void _updateMerchantCode(String newMerchantCode) {
    setState(() {
      _merchantCode = newMerchantCode;
    });
  }

  void _updateCurrency(Currency? newCurrency) {
    if (newCurrency != null) {
      setState(() {
        _selectedCurrency = newCurrency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadyToSubmit = _amount.isNotEmpty &&
        _email.isNotEmpty &&
        _phone.isNotEmpty &&
        _merchantCode.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tabby Checkout'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: refreshSession,
            icon: const Icon(Icons.refresh),
            color: Colors.black,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: double.infinity),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _updateAmount,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_exchange, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Currency>(
                            value: _selectedCurrency,
                            isExpanded: true,
                            hint: const Text('Select Currency'),
                            items: Currency.values.map((Currency currency) {
                              return DropdownMenuItem<Currency>(
                                value: currency,
                                child: Text(currency.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: _updateCurrency,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _updateEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: _updatePhone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextField(
                  controller: _merchantCodeController,
                  decoration: InputDecoration(
                    labelText: 'Merchant Code',
                    hintText: 'Enter merchant code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.abc),
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: _updateMerchantCode,
                ),
              ),
              const Spacer(),
              session == null
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: !isReadyToSubmit
                          ? null
                          : _status == 'pending'
                              ? noop
                              : createSession,
                      child: _status == 'pending'
                          ? const SizedBox(
                              width: 24.0, // Set desired width
                              height: 24.0, // Set desired height
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Session'),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: openInAppBrowser,
                      child: const Text('Open checkout in-app browser'),
                    ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
