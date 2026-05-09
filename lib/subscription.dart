import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String selectedPlan = '1_month';
  bool _isLoading = false;

  Future<void> buy() async {
    setState(() => _isLoading = true);
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentWebView(plan: selectedPlan)));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выберите тариф')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RadioListTile<String>(
              title: const Text('1 месяц — 199 ₽'),
              value: '1_month',
              groupValue: selectedPlan,
              onChanged: (val) => setState(() => selectedPlan = val!),
            ),
            RadioListTile<String>(
              title: const Text('3 месяца — 449 ₽'),
              value: '3_months',
              groupValue: selectedPlan,
              onChanged: (val) => setState(() => selectedPlan = val!),
            ),
            RadioListTile<String>(
              title: const Text('12 месяцев — 1290 ₽'),
              value: '12_months',
              groupValue: selectedPlan,
              onChanged: (val) => setState(() => selectedPlan = val!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : buy,
              child: const Text('💳 Оплатить'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentWebView extends StatelessWidget {
  final String plan;
  const PaymentWebView({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://ваш_сервер_оплаты?plan=$plan'));

    return Scaffold(
      appBar: AppBar(title: const Text('Оплата')),
      body: WebViewWidget(controller: controller),
    );
  }
}
