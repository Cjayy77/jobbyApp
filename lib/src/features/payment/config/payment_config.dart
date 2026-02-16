class PaymentConfig {
  // MTN Mobile Money Configuration
  static const mtnSandboxEndpoint =
      'https://sandbox.momodeveloper.mtn.com/collection/v1_0';
  static const mtnProductionEndpoint =
      'https://proxy.momoapi.mtn.com/collection/v1_0';

  static const mtnApiUser = 'your-mtn-api-user';
  static const mtnApiKey = 'your-mtn-api-key';
  static const mtnSubscriptionKey = 'your-subscription-key';

  // Orange Money Configuration
  static const orangeSandboxEndpoint =
      'https://api.orange.com/orange-money-webpay/dev/v1';
  static const orangeProductionEndpoint =
      'https://api.orange.com/orange-money-webpay/v1';

  static const orangeMerchantKey = 'your-merchant-key';
  static const orangeApiKey = 'your-api-key';
  // General Configuration
  static const isProduction = false;
  static const jobPostingFee = 1000.0; // XAF
  static const eventPostingFee = 500.0; // XAF
  static const currency = 'XAF';

  // Webhook Configuration
  static const webhookBaseUrl = 'https://your-server.com/api/payments';
  static const mtnCallbackUrl = '$webhookBaseUrl/mtn/callback';
  static const orangeCallbackUrl = '$webhookBaseUrl/orange/callback';
}
