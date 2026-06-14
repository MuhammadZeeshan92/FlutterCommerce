import { prisma } from "../config/prisma.js";
import crypto from "crypto";

export const initiateJazzCash = async (req, res) => {
  try {
    const { orderId } = req.body;

    console.log("ORDER ID RECEIVED:", orderId);

    if (!orderId) {
      return res.status(400).json({
        message: "orderId is required to start JazzCash payment.",
      });
    }

    const order = await prisma.order.findUnique({
      where: { id: orderId },
    });

    console.log("ORDER FOUND:", order);

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (order.paymentMethod !== "jazzcash" && order.paymentMethod !== "JAZZCASH") {
      return res.status(400).json({
        message: "This order was not created for JazzCash payment.",
      });
    }

    if (order.status === "PAID" || order.paymentStatus === "PAID") {
      return res.status(400).json({
        message: "This order is already paid.",
      });
    }

    // 🔐 generate transaction id
    const transactionId = crypto.randomUUID();

    // update order
    await prisma.order.update({
      where: { id: orderId },
      data: {
        paymentMethod: "JAZZCASH",
        paymentStatus: "PENDING",
        transactionId,
        status: "AWAITING_PAYMENT",
      },
    });

    // 🔥 FAKE gateway URL (real JazzCash replaces this)
    const paymentUrl =
      `https://fake-jazzcash-gateway.com/pay?txn=${transactionId}&amount=${order.totalAmount}`;

    res.json({
      paymentUrl,
      transactionId,
    });
  } catch (err) {
    console.error("========== JAZZCASH ERROR ==========");
    console.error(err);
    console.error("===================================");

    res.status(500).json({
      message: err.message,
    });
  }
};