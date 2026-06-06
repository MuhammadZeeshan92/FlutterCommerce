import { prisma } from "../config/prisma.js";
import crypto from "crypto";

const initiateJazzCashPayment = async (req, res) => {
  try {
    const { orderId } = req.body;

    const order = await prisma.order.findUnique({
      where: { id: orderId },
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    // 🔥 fake transaction id (real JazzCash gives this)
    const transactionId = crypto.randomUUID();

    // Save payment reference
    await prisma.order.update({
      where: { id: orderId },
      data: {
        paymentMethod: "JAZZCASH",
        paymentId: transactionId,
      },
    });

    // 🔥 THIS is where real JazzCash URL would be
    const paymentUrl = `https://fake-jazzcash-gateway.com/pay?txn=${transactionId}&amount=${order.totalAmount}`;

    res.json({
      paymentUrl,
      transactionId,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export default initiateJazzCashPayment;