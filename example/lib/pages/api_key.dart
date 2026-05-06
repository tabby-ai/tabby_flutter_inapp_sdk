import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

const _preConfiguredApiKey = String.fromEnvironment(
  'demoapp.apiKey',
  defaultValue: '',
);

const _preConfiguredEnv = String.fromEnvironment(
  'demoapp.defaultEnv',
  defaultValue: 'production',
);

class ApiKeyPage extends StatefulWidget {
  const ApiKeyPage({super.key});

  @override
  State<ApiKeyPage> createState() => _ApiKeyPageState();
}

class _ApiKeyPageState extends State<ApiKeyPage> {
  late TextEditingController _apiKeyController;
  Environment _env =
      _preConfiguredEnv == Environment.staging.name
          ? Environment.staging
          : Environment.production;
  String _apiKey = kDebugMode ? _preConfiguredApiKey : '';
  bool _busy = false;

  Future<void> openNextPage() async {
    setState(() => _busy = true);
    try {
      await TabbySDK().setup(withApiKey: _apiKey, environment: _env);
      if (!mounted) return;
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tabby setup failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

  void _updateEnvironment(Environment? newEnvironment) {
    if (newEnvironment != null) {
      setState(() {
        _env = newEnvironment;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Spacer(),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Environment>(
                  value: _env,
                  isExpanded: true,
                  hint: const Text('Change Environment'),
                  items:
                      Environment.values.map((Environment e) {
                        return DropdownMenuItem<Environment>(
                          value: e,
                          child: Text(
                            "${e.name.toUpperCase()} (${e.bootstrapApiBaseUrl})",
                          ),
                        );
                      }).toList(),
                  onChanged: _updateEnvironment,
                ),
              ),
            ),
            SizedBox(height: 8),
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
                onPressed: (_apiKey.isNotEmpty && !_busy) ? openNextPage : null,
                child:
                    _busy
                        ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text('Set API Key'),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
