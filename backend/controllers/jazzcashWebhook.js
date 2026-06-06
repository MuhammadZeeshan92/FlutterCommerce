const jazzcashWebhook = async (req, res) => {
  try {
    const { transactionId, status } = req.body;

    const order = await prisma.order.findFirst({
      where: { paymentId: transactionId },
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (status === "SUCCESS") {
      await prisma.order.update({
        where: { id: order.id },
        data: { status: "CONFIRMED" },
      });
    }

    if (status === "FAILED") {
      await prisma.order.update({
        where: { id: order.id },
        data: { status: "CANCELLED" },
      });
    }

    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export default jazzcashWebhook;