
import express from "express";
import {
  initiateJazzCash,
} from "../controllers/initiateJazzCashPayment.js";
import { jazzcashWebhook } from "../controllers/jazzcashWebhook.js";

const router = express.Router();

router.post("/jazzcash/initiate", initiateJazzCash);
router.post("/jazzcash/webhook", jazzcashWebhook);

export default router;