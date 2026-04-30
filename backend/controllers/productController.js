import { prisma } from "../config/prisma.js";

const createProduct = async (req, res) => {
  try {
    const { title, description, price, stock, image } = req.body;

     const product = await prisma.product.create({
      data: {
        title,
        description,
        price: Number(price),
        stock: Number(stock),
        image,
      },
    });

    res.status(201).json({
      message: "Product created successfully",
      product,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

// const getAllProducts = async (req, res) => {
//   try {
//     const products = await prisma.product.findMany({
//       include: {
//         seller: {
//           select: {
//             id: true,
//             name: true,
//             email: true,
//           },
//         },
//       },
//     });

//     res.status(200).json(products);
//   } catch (error) {
//     res.status(500).json({
//       message: error.message,
//     });
//   }
// };

const getAllProducts = async (req, res) => {
  try {
    const {
      search,
      minPrice,
      maxPrice,
      page = 1,
      limit = 10,
    } = req.query;

    const filters = {};

    // 🔍 SEARCH by title
    if (search) {
      filters.title = {
        contains: search,
        mode: "insensitive",
      };
    }

    // 💰 PRICE FILTER
    if (minPrice || maxPrice) {
      filters.price = {
        gte: minPrice ? Number(minPrice) : undefined,
        lte: maxPrice ? Number(maxPrice) : undefined,
      };
    }

    const skip = (page - 1) * limit;

    const products = await prisma.product.findMany({
      where: filters,
      skip: Number(skip),
      take: Number(limit),
      orderBy: {
        createdAt: "desc",
      },
    });

    const total = await prisma.product.count({
      where: filters,
    });

    res.status(200).json({
      products,
      total,
      page: Number(page),
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getSingleProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await prisma.product.findUnique({
      where: {
        id,
      },

      include: {
        seller: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    if (!product) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.status(200).json(product);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const updatedProduct = await prisma.product.update({
      where: { id },
      data: req.body,
    });

    res.status(200).json({
      message: "Product updated successfully",
      updatedProduct,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.product.delete({
      where: { id },
    });

    res.status(200).json({
      message: "Product deleted successfully",
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export { createProduct, getAllProducts, getSingleProduct, updateProduct, deleteProduct };