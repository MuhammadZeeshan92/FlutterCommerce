import express from "express";

import {
  createOrder,
  getMyOrders,
  getAllOrders,
  updateOrderStatus,
  getOrderById
} from "../controllers/orderController.js";

import authMiddleware from "../middleware/authMiddleware.js";
import roleMiddleware from "../middleware/roleMiddleware.js";

const router = express.Router();

// BUYER
router.get("/:id", authMiddleware, getOrderById);
router.post("/", authMiddleware, createOrder);
router.get("/my", authMiddleware, getMyOrders);

// ADMIN
router.get("/", authMiddleware, roleMiddleware("ADMIN"), getAllOrders);

router.put(
  "/:id",
  authMiddleware,
  roleMiddleware("ADMIN"),
  updateOrderStatus
);


router.put(
  "/:id/status",
  authMiddleware,
  roleMiddleware("ADMIN"),
  updateOrderStatus
);
export default router;