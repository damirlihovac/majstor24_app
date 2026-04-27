final payment = context.read<PaymentNotifier>();

final url = await payment.startPayment(
  trx: trx,
  cardId: cardId,
);

if (url != null) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BankartWebView(url: url),
    ),
  );
}