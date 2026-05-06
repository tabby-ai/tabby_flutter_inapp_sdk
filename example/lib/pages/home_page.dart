import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _merchantCode = 'ae';
  late TextEditingController _merchantCodeController;
  Currency _selectedCurrency = Currency.aed;
  Lang _selectedLanguage = Lang.en;
  String _amount = '340';
  late TextEditingController _amountController;
  int _installmentsCount = 4;
  late TextEditingController _installmentsCountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _amount);
    _merchantCodeController = TextEditingController(text: _merchantCode);
    _installmentsCountController = TextEditingController(
      text: _installmentsCount.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantCodeController.dispose();
    super.dispose();
  }

  void openNewSessionPage() {
    Navigator.pushNamed(context, '/new_session');
  }

  void _updateMerchantCode(String newMerchantCode) {
    setState(() {
      _merchantCode = newMerchantCode;
    });
  }

  void _updateAmount(String newAmount) {
    setState(() {
      _amount = newAmount;
    });
  }

  void _updateInstallmentsCount(String newInstallmentsCount) {
    setState(() {
      _installmentsCount = int.tryParse(newInstallmentsCount) ?? 4;
    });
  }

  void _updateCurrency(Currency? newCurrency) {
    if (newCurrency != null) {
      setState(() {
        _selectedCurrency = newCurrency;
      });
    }
  }

  void _updateLanguage(Lang? newLanguage) {
    if (newLanguage != null) {
      setState(() {
        _selectedLanguage = newLanguage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabby Flutter SDK demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: TabbyScrollableBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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
                padding: const EdgeInsets.only(bottom: 12.0),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: _installmentsCountController,
                  decoration: InputDecoration(
                    labelText: 'Installments Count',
                    hintText: 'Enter number of installments',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.format_list_numbered),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _updateInstallmentsCount,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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
                            items:
                                Currency.values.map((Currency currency) {
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
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Lang>(
                            value: _selectedLanguage,
                            isExpanded: true,
                            hint: const Text('Select Language'),
                            items:
                                Lang.values.map((Lang l) {
                                  return DropdownMenuItem<Lang>(
                                    value: l,
                                    child: Text(l.displayName),
                                  );
                                }).toList(),
                            onChanged: _updateLanguage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text('lib/src/internal/tabby_product_page_snippet.dart'),
              const SizedBox(height: 8),
              TabbyProductPageSnippet(
                price: double.tryParse(_amount) ?? 0.0,
                currency: _selectedCurrency,
                lang: _selectedLanguage,
                apiKey: TabbySDK().publicKey,
                merchantCode: _merchantCode,
                installmentsCount: _installmentsCount,
              ),
              const Text('lib/src/internal/tabby_card_snippet.dart'),
              const SizedBox(height: 8),
              TabbyCardSnippet(
                price: double.tryParse(_amount) ?? 0.0,
                currency: _selectedCurrency,
                lang: _selectedLanguage,
                apiKey: TabbySDK().publicKey,
                merchantCode: _merchantCode,
                installmentsCount: _installmentsCount,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ElevatedButton(
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
          onPressed: openNewSessionPage,
          child: const Text('Test Checkout Session'),
        ),
      ),
    );
  }
}

class TabbyScrollableBody extends StatelessWidget {
  /// Content.
  final Widget child;

  /// Top padding.
  final double? topPadding;

  /// Bottom padding.
  final double? bottomPadding;

  /// Keyboard Dismiss behaviour
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// [TabbyScrollableBody] constructor.
  const TabbyScrollableBody({
    required this.child,
    this.bottomPadding,
    this.topPadding,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: keyboardDismissBehavior,
      padding: EdgeInsets.only(
        top: topPadding ?? 6.0,
        bottom: bottomPadding ?? 8.0,
        left: 16,
        right: 16,
      ),
      child: TabbyLostFocusWrapper(child: child),
    );
  }
}

class TabbyLostFocusWrapper extends StatelessWidget {
  /// Child widget.
  final Widget child;

  /// Creates an instance of [TabbyLostFocusWrapper].
  const TabbyLostFocusWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
