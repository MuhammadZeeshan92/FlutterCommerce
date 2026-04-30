import express from "express";
import authMiddleware from "../middleware/authMiddleware.js";
import roleMiddleware from "../middleware/roleMiddleware.js";
import { getAdminStats } from "../controllers/adminController.js";

const router = express.Router();

router.get(
  "/admin/stats",
  authMiddleware,
  roleMiddleware("ADMIN"),
  getAdminStats
);

export default router;