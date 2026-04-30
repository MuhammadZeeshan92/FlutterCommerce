const getAdminStats = async (req, res) => {
  try {
    const totalProducts = await prisma.product.count();
    const totalOrders = await prisma.order.count();

    const revenue = await prisma.order.aggregate({
      _sum: {
        totalAmount: true,
      },
    });

    res.status(200).json({
      totalProducts,
      totalOrders,
      totalRevenue: revenue._sum.totalAmount || 0,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};