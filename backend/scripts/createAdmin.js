import bcrypt from "bcrypt";

import { prisma } from "../config/prisma.js";

const createAdmin = async () => {
  try {
    const existingAdmin = await prisma.user.findUnique({
      where: {
        email: "admin@gmail.com",
      },
    });

    if (existingAdmin) {
      console.log("Admin already exists");
      process.exit();
    }

    const hashedPassword = await bcrypt.hash(
      "admin123",
      10
    );

    const admin = await prisma.user.create({
      data: {
        name: "Admin",
        email: "admin@gmail.com",
        password: hashedPassword,
        role: "ADMIN",
      },
    });

    console.log("Admin created successfully");
    console.log(admin);

    process.exit();
  } catch (error) {
    console.log(error);

    process.exit(1);
  }
};

createAdmin();