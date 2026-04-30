import express from "express";
import authMiddleware from "../middleware/authMiddleware.js";
import roleMiddleware from "../middleware/roleMiddleware.js";

const router = express.Router();

router.get(
  "/buyer",
  authMiddleware,
  roleMiddleware("BUYER"),
  (req, res) => {
    res.json({
      message: "Buyer route accessed",
      user: req.user,
    });
  }
);

router.get(
  "/seller",
  authMiddleware,
  roleMiddleware("SELLER"),
  (req, res) => {
    res.json({
      message: "Seller route accessed",
      user: req.user,
    });
  }
);

router.get(
  "/admin",
  authMiddleware,
  roleMiddleware("ADMIN"),
  (req, res) => {
    res.json({
      message: "Admin route accessed",
      user: req.user,
    });
  }
);

export default router;