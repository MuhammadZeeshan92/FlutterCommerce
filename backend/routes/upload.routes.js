import express from "express";
import { generateSignature } from "../controllers/upload.controller.js";

const router = express.Router();

router.get("/signature", generateSignature);

export default router;