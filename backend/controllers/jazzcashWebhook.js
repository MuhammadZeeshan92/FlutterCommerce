export const jazzcashWebhook = async (req, res) => {
  try {
    const { transactionId, status } = req.body;

    const order = await prisma.order.findFirst({
      where: { transactionId },
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (status === "SUCCESS") {
      await prisma.order.update({
        where: { id: order.id },
        data: {
          paymentStatus: "PAID",
          status: "PAID",
        },
      });
    }

    if (status === "FAILED") {
      await prisma.order.update({
        where: { id: order.id },
        data: {
          paymentStatus: "FAILED",
          status: "CANCELLED",
        },
      });
    }

    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};