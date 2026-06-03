import { prisma } from "../config/prisma.js";

const getDashboardStats = async (req, res) => {
  try {
    const totalProducts = await prisma.product.count();

    const totalUsers = await prisma.user.count();

    const totalOrders = await prisma.order.count();



    res.status(200).json({
      totalProducts,
      totalUsers,
      totalOrders,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

export default getDashboardStats;