import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class ApiKeyPage extends StatefulWidget {
  const ApiKeyPage({Key? key}) : super(key: key);

  @override
  State<ApiKeyPage> createState() => _ApiKeyPageState();
}

class _ApiKeyPageState extends State<ApiKeyPage> {
  late TextEditingController _apiKeyController;
  String _apiKey = '';

  void openNextPage() {
    TabbySDK().setup(withApiKey: _apiKey);
    Navigator.pushNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: _apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _updateApiKey(String newApiKey) {
    setState(() {
      _apiKey = newApiKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabby Flutter SDK demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 12, right: 12),
              child: TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your Tabby API key',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.key),
                ),
                onChanged: _updateApiKey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                onPressed: _apiKey.isNotEmpty ? openNextPage : null,
                child: const Text('Set API Key'),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
