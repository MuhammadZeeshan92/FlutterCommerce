import express from "express";
import getDashboardStats from "../controllers/statsController.js";
import authMiddleware from "../middleware/authMiddleware.js";
import roleMiddleware from "../middleware/roleMiddleware.js";

const router = express.Router();

router.get(
    "/dashboard/stats",
    authMiddleware,
    roleMiddleware("ADMIN"),
    getDashboardStats
);

export default router;
