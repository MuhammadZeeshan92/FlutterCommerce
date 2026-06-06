const initiatePayment = async (req, res) => {
  try {
    const { orderId } = req.body;

    const order = await prisma.order.findUnique({
      where: { id: orderId },
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (order.paymentMethod === "cod") {
      return res.status(400).json({
        message: "COD does not require payment",
      });
    }

    // 🔥 STEP: Create payment request (mock for now)
    const paymentUrl = `https://sandbox-payment-gateway.com/pay?orderId=${order.id}`;

    return res.status(200).json({
      paymentUrl,
      orderId: order.id,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};