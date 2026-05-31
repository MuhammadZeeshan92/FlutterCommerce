import cloudinary from "../config/cloudinary.js";

const generateSignature = async (req, res) => {
  try {
    const timestamp = Math.round(Date.now() / 1000);

    const signature = cloudinary.utils.api_sign_request(
      {
        timestamp,
        folder: "ecommerce-products",
      },
      process.env.CLOUDINARY_API_SECRET
    );

    res.status(200).json({
      timestamp,
      signature,
      cloudName: process.env.CLOUDINARY_CLOUD_NAME,
      apiKey: process.env.CLOUDINARY_API_KEY,
      folder: "ecommerce-products",
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

export { generateSignature };