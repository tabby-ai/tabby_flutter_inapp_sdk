import 'package:flutter/material.dart';
import 'package:tabby_flutter/internal/TabbySdk.dart';
import 'package:tabby_flutter/internal/mock.dart';
import 'package:tabby_flutter/models/enums.dart';
import 'package:tabby_flutter/models/models.dart';

// import 'package:tabby_flutter/internal/TabbyCheckoutView.dart';
import 'internal/TabbyCheckoutViewWithApplePay.dart';

void main() {
  Tabby.setup(withApiKey: 'pk_test_528adcfa-b906-47b5-9f66-e5cf967e0095');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabby Flutter SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/checkout': (context) => const TabbyCheckoutViewWithApplePay(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'idle';
  TabbySession? session;

  void _setStatus(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  createSession() async {
    try {
      _setStatus('pending');
      final s = await Tabby.createSession(TabbyCheckoutPayload(
        merchantCode: 'sa',
        lang: Lang.en,
        payment: mockPayload,
      ));
      setState(() {
        session = s;
      });
      _setStatus('created');
    } catch (err) {
      print(err);
      _setStatus('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabby Flutter SDK demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${mockPayload.amount} ${mockPayload.currency.name}',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Text(
              mockPayload.buyer.email,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Text(
              mockPayload.buyer.phone,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: session?.availableProducts.installments != null
                        ? () {
                            if (session != null) {
                              Navigator.pushNamed(
                                context,
                                '/checkout',
                                arguments: TabbyCheckoutNavParams(
                                  session: session!,
                                  selectedProduct:
                                      session!.availableProducts.installments!,
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text('demo installments')),
                const ElevatedButton(
                    onPressed: null,
                    child: Text('demo credit_card_installments')),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: session == null ? createSession : null,
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }
}
