const paymentWebhook = async (req, res) => {
  try {
    const {
      orderId,
      status,
      transactionId
    } = req.body;

    const order = await prisma.order.findUnique({
      where: { id: orderId },
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (status === "success") {
      await prisma.order.update({
        where: { id: orderId },
        data: {
          paymentStatus: "PAID",
          status: "CONFIRMED",
          transactionId,
        },
      });
    } else {
      await prisma.order.update({
        where: { id: orderId },
        data: {
          paymentStatus: "FAILED",
          status: "CANCELLED",
        },
      });
    }

    res.status(200).json({ message: "Webhook processed" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};