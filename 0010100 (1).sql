-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 04, 2024 at 06:04 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `.project .`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddReview` (IN `prod_id` INT, IN `user_id` INT, IN `rating` INT, IN `comment` TEXT)   BEGIN
    INSERT INTO Reviews (Product_ID, User_ID, Rating, Comment, Date_Posted)
    VALUES (prod_id, user_id, rating, comment, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddToWishlist` (IN `user_id` INT, IN `product_id` INT)   BEGIN
    INSERT INTO Wishlist (User_ID, Product_ID, Date_Added)
    VALUES (user_id, product_id, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ApplyCoupon` (IN `order_id` INT, IN `coupon_code` VARCHAR(60))   BEGIN
    DECLARE discount INT;
    DECLARE price DECIMAL(10,2);

    -- Get the discount percentage from the coupon
    SELECT Discount_Percentage INTO discount
    FROM Coupons
    WHERE Code = coupon_code AND Expiry_Date >= CURDATE();

    -- Calculate the new price
    SELECT Total_Amount INTO price FROM Orders WHERE Order_ID = order_id;
    UPDATE Orders SET Total_Amount = price - (price * discount / 100) WHERE Order_ID = order_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ApplyDiscount` (IN `order_id` INT, IN `coupon_code` VARCHAR(255))   BEGIN
    DECLARE discount_amount DECIMAL(10, 2);

    -- Retrieve the discount amount from the Coupons table
    SELECT Discount_Amount INTO discount_amount
    FROM Coupons
    WHERE Code = coupon_code AND CURDATE() <= Expiry_Date;

    -- Update the total amount in the Orders table
    UPDATE Orders
    SET Total_Amount = Total_Amount - discount_amount
    WHERE Order_ID = order_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CalculateTotalRevenue` (IN `startDate` DATE, IN `endDate` DATE)   BEGIN
    SELECT SUM(Total_Amount) AS Total_Revenue
    FROM Orders
    WHERE Order_Date BETWEEN startDate AND endDate;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RemoveFromWishlist` (IN `p_user_id` INT, IN `p_product_id` INT)   BEGIN
    DELETE FROM wishlists
    WHERE user_id = p_user_id AND product_id = p_product_id;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `ApplyCoupon` (`code` VARCHAR(10), `original_price` DECIMAL(10,2)) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE discount DECIMAL(10,2);
    DECLARE new_price DECIMAL(10,2);
    SELECT Discount_Percentage INTO discount FROM Coupons WHERE Code = code AND Expiry_Date >= CURDATE();
    IF discount IS NULL THEN
        RETURN original_price;
    ELSE
        SET new_price = original_price - (original_price * (discount / 100));
        RETURN new_price;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `Brand_ID` int(11) NOT NULL,
  `Name` varchar(60) NOT NULL,
  `Description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`Brand_ID`, `Name`, `Description`) VALUES
(1, 'Samsung', 'Leading manufacturer of electronic devices, including smartphones and home appliances'),
(2, 'Nike', 'Global leader in athletic footwear, apparel, and equipment'),
(3, 'Sony', 'Specializes in electronics, gaming, and entertainment products'),
(4, 'Adidas', 'Designs and manufactures sports shoes, clothing, and accessories'),
(5, 'Apple', 'Innovates in consumer electronics and software, known for its iPhones and Mac computers');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `Cart_ID` int(11) NOT NULL,
  `User_ID` int(11) DEFAULT NULL,
  `Date_Added` datetime DEFAULT NULL,
  `Status` varchar(168) DEFAULT NULL,
  `Product_ID` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`Cart_ID`, `User_ID`, `Date_Added`, `Status`, `Product_ID`, `Quantity`) VALUES
(1, 1, '2023-05-04 00:00:00', NULL, 5, 2),
(2, 2, '2023-05-04 00:00:00', NULL, 3, 1),
(3, 3, '2023-05-04 00:00:00', NULL, 1, 3),
(4, 1, '2024-05-04 14:05:03', NULL, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `Category_ID` int(11) NOT NULL,
  `Name` varchar(60) NOT NULL,
  `Description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`Category_ID`, `Name`, `Description`) VALUES
(1, 'Electronics', 'All electronic items'),
(2, 'Clothing', 'Apparel and accessories'),
(3, 'Home Appliances', 'Household appliances'),
(4, 'Electronics', 'All electronic items'),
(5, 'Clothing', 'Apparel and accessories'),
(6, 'Home Appliances', 'Household appliances'),
(7, 'Books', 'Literature and textbooks'),
(8, 'Gardening', 'Tools and plant supplies'),
(9, 'Sports', 'Sports gear and fitness equipment');

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `Coupon_ID` int(11) NOT NULL,
  `Code` varchar(60) NOT NULL,
  `Discount_Amount` decimal(10,2) DEFAULT NULL,
  `Expiry_Date` date DEFAULT NULL,
  `Discount_Percentage` decimal(5,2) DEFAULT NULL,
  `times_used` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coupons`
--

INSERT INTO `coupons` (`Coupon_ID`, `Code`, `Discount_Amount`, `Expiry_Date`, `Discount_Percentage`, `times_used`) VALUES
(1, 'SAVE10', NULL, '2024-12-31', 10.00, 1),
(2, '20OFF', NULL, '2024-12-31', 20.00, 1),
(3, 'WINTER25', NULL, '2025-01-31', 25.00, 1),
(4, 'SUMMER15', NULL, '2024-07-31', 15.00, 1),
(5, 'SUMMER21', NULL, '2025-08-31', 15.00, 501);

-- --------------------------------------------------------

--
-- Table structure for table `orderdetaillogs`
--

CREATE TABLE `orderdetaillogs` (
  `LogID` int(11) NOT NULL,
  `OrderDetailID` int(11) DEFAULT NULL,
  `ProductID` int(11) DEFAULT NULL,
  `LogTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `Order_ID` int(11) NOT NULL,
  `User_ID` int(11) DEFAULT NULL,
  `Order_Date` datetime DEFAULT NULL,
  `Status` varchar(240) DEFAULT NULL,
  `Total_Amount` decimal(10,2) DEFAULT NULL,
  `Coupon_ID` int(11) DEFAULT NULL,
  `Product_Key` varchar(255) DEFAULT NULL,
  `Product_ID` varchar(255) DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`Order_ID`, `User_ID`, `Order_Date`, `Status`, `Total_Amount`, `Coupon_ID`, `Product_Key`, `Product_ID`, `Quantity`) VALUES
(1, 1, '2023-01-01 00:00:00', NULL, 2630.50, NULL, NULL, NULL, NULL),
(2, 2, '2023-01-02 00:00:00', NULL, 430.00, NULL, NULL, NULL, NULL),
(3, 1, '2024-05-04 00:00:00', NULL, 400.00, NULL, NULL, NULL, NULL),
(4, 2, '2024-05-04 00:00:00', NULL, 150.00, NULL, NULL, NULL, NULL),
(5, 3, '2024-05-05 00:00:00', NULL, 300.00, NULL, NULL, NULL, NULL),
(6, 4, '2024-05-05 00:00:00', NULL, 450.00, NULL, NULL, NULL, NULL),
(7, 5, '2024-05-06 00:00:00', NULL, 120.00, NULL, NULL, NULL, NULL),
(8, 1, '2024-05-04 14:07:01', 'Pending', 59.99, NULL, NULL, NULL, NULL),
(9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(123, 456, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(1001, 4, '0000-00-00 00:00:00', 'mneigkoamnoikav', 1000.00, 3, NULL, NULL, NULL),
(2001, 4, '0000-00-00 00:00:00', 'mneigkoamnoikav', 1000.00, 3, NULL, NULL, NULL),
(5412, 101, NULL, NULL, 200.00, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `Order_Detail_ID` int(11) NOT NULL,
  `Order_ID` int(11) DEFAULT NULL,
  `Product_ID` int(11) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_details`
--

INSERT INTO `order_details` (`Order_Detail_ID`, `Order_ID`, `Product_ID`, `Price`) VALUES
(1, 1, 1, 1200.00),
(2, 2, 2, 20.00),
(3, 2, 3, 15.00),
(4, 1, 1, 50.00),
(5, 1, 2, 100.00),
(6, 2, 3, 20.00),
(7, 2, 4, 150.00),
(8, 3, 1, 200.00);

--
-- Triggers `order_details`
--
DELIMITER $$
CREATE TRIGGER `AfterInsertOrderDetails` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
    DECLARE subtotal DECIMAL(10, 2);
    SET subtotal = NEW.Quantity * NEW.Price;
    UPDATE Orders SET Total_Amount = Total_Amount + subtotal WHERE Order_ID = NEW.Order_ID;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `CalculateSubtotalAfterInsert` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
    -- Calculate subtotal for the new order detail
    DECLARE subtotal DECIMAL(10, 2);
    SET subtotal = NEW.Quantity * NEW.Price;

    -- Update the subtotal in the order details table
    UPDATE order_details
    SET Price = NEW.Price,
        Subtotal = subtotal
    WHERE Order_Detail_ID = NEW.Order_Detail_ID;

    -- Update the total amount in the orders table
    UPDATE orders
    SET Total_Amount = Total_Amount + subtotal
    WHERE Order_ID = NEW.Order_ID;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `CalculateTotalAmount` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
    DECLARE subtotal DECIMAL(10, 2);
    SET subtotal = NEW.Quantity * NEW.Price;

    -- Update the total amount in the orders table
    UPDATE orders
    SET Total_Amount = Total_Amount + subtotal
    WHERE Order_ID = NEW.Order_ID;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateOrderTotalAfterInsert` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
    UPDATE Orders
    SET Total_Amount = Total_Amount + (NEW.Quantity * NEW.Price)
    WHERE Order_ID = NEW.Order_ID;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateTotalAmount` AFTER INSERT ON `order_details` FOR EACH ROW BEGIN
    -- Update the total amount in the Orders table
    UPDATE Orders
    SET Total_Amount = Total_Amount + (NEW.Quantity * NEW.Price)
    WHERE Order_ID = NEW.Order_ID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `Product_ID` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Description` text DEFAULT NULL,
  `Price` decimal(10,2) NOT NULL,
  `Stock_Quantity` int(11) DEFAULT NULL,
  `Discount_price` decimal(10,2) DEFAULT NULL,
  `Posted_at` datetime DEFAULT NULL,
  `Category_ID` int(11) DEFAULT NULL,
  `Brand_ID` int(11) DEFAULT NULL,
  `Seller_ID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`Product_ID`, `Name`, `Description`, `Price`, `Stock_Quantity`, `Discount_price`, `Posted_at`, `Category_ID`, `Brand_ID`, `Seller_ID`) VALUES
(1, 'Product 1', 'Description of Product 1', 19.99, 100, NULL, NULL, 1, NULL, 1),
(2, 'Product 2', 'Description of Product 2', 29.99, 200, NULL, NULL, 1, NULL, 1),
(3, 'Product 50', 'Description of Product 50', 49.99, 50, NULL, NULL, 1, NULL, 1),
(4, 'Laptop', 'High performance laptop', 1200.00, 50, NULL, NULL, 1, NULL, NULL),
(5, 'T-shirt', 'Cotton t-shirt', 20.00, 150, NULL, NULL, 2, NULL, NULL),
(6, 'Microwave', 'Compact microwave oven', 99.99, 30, NULL, NULL, 3, NULL, NULL),
(7, 'Laptop', 'High performance laptop', 1200.00, 50, NULL, NULL, 1, NULL, NULL),
(8, 'T-shirt', 'Cotton t-shirt', 20.00, 150, NULL, NULL, 2, NULL, NULL),
(9, 'Microwave', 'Compact microwave oven', 99.99, 30, NULL, NULL, 3, NULL, NULL),
(54, 'Product 1', NULL, 0.00, 50, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `Review_ID` int(11) NOT NULL,
  `Product_ID` int(11) DEFAULT NULL,
  `User_ID` int(11) DEFAULT NULL,
  `Rating` int(11) DEFAULT NULL,
  `Comment` text DEFAULT NULL,
  `Date_Posted` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`Review_ID`, `Product_ID`, `User_ID`, `Rating`, `Comment`, `Date_Posted`) VALUES
(1, 101, 5, 4, 'Great product!', '2024-05-04 02:47:29'),
(2, 1, 1, 5, 'Excellent laptop!', NULL),
(3, 2, 2, 4, 'Good quality t-shirt but pricey.', NULL),
(4, 1, 1, 5, 'Excellent product, highly recommend!', '2024-05-04 00:00:00'),
(5, 1, 2, 4, 'Good quality, but a bit expensive.', '2024-05-05 00:00:00'),
(6, 2, 1, 3, 'Average product, not bad.', '2024-05-06 00:00:00'),
(7, 2, 3, 2, 'Below expectations, could be better.', '2024-05-07 00:00:00'),
(8, 3, 1, 5, 'Outstanding performance!', '2024-05-08 00:00:00'),
(9, 101, 1, 5, 'Great product!', '2024-05-04 00:00:00'),
(10, 1, 101, 5, 'Great product, I highly recommend it!', '2024-05-04 12:43:14'),
(11, 1, 1, 5, 'Great product!', '2024-05-04 14:06:35');

-- --------------------------------------------------------

--
-- Table structure for table `seller`
--

CREATE TABLE `seller` (
  `Seller_Email` varchar(255) NOT NULL,
  `Name` varchar(40) NOT NULL,
  `Password` varchar(50) NOT NULL,
  `Goods` varchar(120) DEFAULT NULL,
  `Rate` int(11) DEFAULT NULL,
  `Tax_Number` varchar(60) DEFAULT NULL,
  `Seller_ID` int(11) NOT NULL,
  `Contact_Number` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seller`
--

INSERT INTO `seller` (`Seller_Email`, `Name`, `Password`, `Goods`, `Rate`, `Tax_Number`, `Seller_ID`, `Contact_Number`) VALUES
('john@example.com', 'John Doe', '', NULL, NULL, NULL, 1, '123-456-7890'),
('jane@example.com', 'Jane Doe', '', NULL, NULL, NULL, 2, '234-567-8901'),
('alice@example.com', 'Alice Johnson', '', NULL, NULL, NULL, 3, '345-678-9012'),
('bob@example.com', 'Bob Smith', '', NULL, NULL, NULL, 4, '456-789-0123');

-- --------------------------------------------------------

--
-- Table structure for table `shipping`
--

CREATE TABLE `shipping` (
  `Shipping_ID` int(11) NOT NULL,
  `Order_ID` int(11) DEFAULT NULL,
  `Shipping_Date` datetime DEFAULT NULL,
  `Estimated_Delivery_Date` datetime DEFAULT NULL,
  `Shipping_Status` varchar(170) DEFAULT NULL,
  `Tracking_Number` varchar(90) DEFAULT NULL,
  `Cost` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `shipping`
--

INSERT INTO `shipping` (`Shipping_ID`, `Order_ID`, `Shipping_Date`, `Estimated_Delivery_Date`, `Shipping_Status`, `Tracking_Number`, `Cost`) VALUES
(1, 1, '2024-05-04 00:00:00', '2024-05-09 00:00:00', 'Shipped', 'TRK123456789', NULL),
(2, 2, '2024-05-05 00:00:00', '2024-05-10 00:00:00', 'Shipped', 'TRK123456790', NULL),
(3, 3, '2024-05-06 00:00:00', '2024-05-11 00:00:00', 'In Transit', 'TRK123456791', NULL),
(4, 4, '2024-05-07 00:00:00', '2024-05-12 00:00:00', 'In Transit', 'TRK123456792', NULL),
(5, 5, '2024-05-08 00:00:00', '2024-05-13 00:00:00', 'Delivered', 'TRK123456793', NULL),
(6, 1, '2024-05-04 00:00:00', '2024-05-09 00:00:00', 'Shipped', 'TRK123456789', 10.50),
(7, 2, '2024-05-05 00:00:00', '2024-05-10 00:00:00', 'Shipped', 'TRK123456790', 15.75),
(8, 3, '2024-05-06 00:00:00', '2024-05-11 00:00:00', 'In Transit', 'TRK123456791', 8.25),
(9, 4, '2024-05-07 00:00:00', '2024-05-12 00:00:00', 'In Transit', 'TRK123456792', 12.00),
(10, 5, '2024-05-08 00:00:00', '2024-05-13 00:00:00', 'Delivered', 'TRK123456793', 9.99);

-- --------------------------------------------------------

--
-- Table structure for table `trlog`
--

CREATE TABLE `trlog` (
  `LogID` int(11) NOT NULL,
  `TableName` varchar(155) DEFAULT NULL,
  `ActionType` varchar(50) DEFAULT NULL,
  `ActionDescription` text DEFAULT NULL,
  `ActionTime` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trlog`
--

INSERT INTO `trlog` (`LogID`, `TableName`, `ActionType`, `ActionDescription`, `ActionTime`) VALUES
(1, 'Orders', 'INSERT', 'Order with ID 5412 inserted. Total Amount: 200.00', '2024-05-04 14:27:04');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `User_ID` int(11) NOT NULL,
  `Username` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Age` int(11) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`User_ID`, `Username`, `Email`, `Password`, `Name`, `Age`, `Phone`, `Address`) VALUES
(1, '', 'john.doe@example.com', '', 'John Doe', NULL, NULL, '1234 Elm St'),
(2, '', 'jane.smith@example.com', '', 'Jane Smith', NULL, NULL, '5678 Oak St'),
(3, 'johndoe', 'johndoe@example.com', 'password123', NULL, 28, '555-0101', '123 Elm Street'),
(4, 'janedoe', 'janedoe@example.com', 'password456', NULL, 32, '555-0102', '124 Elm Street'),
(5, 'aliceblue', 'aliceblue@example.com', 'password789', NULL, 24, '555-0103', '125 Elm Street'),
(6, 'bobwhite', 'bobwhite@example.com', 'password101', NULL, 35, '555-0104', '126 Elm Street'),
(7, 'charliebrown', 'charliebrown@example.com', 'password102', NULL, 29, '555-0105', '127 Elm Street'),
(8, 'testuser', 'test@example.com', 'password123', 'Test User', 30, '555-1234', '123 Test St');

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `wishlist_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `added_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wishlists`
--

INSERT INTO `wishlists` (`wishlist_id`, `user_id`, `product_id`, `added_date`) VALUES
(1, 1, 101, '2024-05-04 10:01:29'),
(2, 2, 102, '2024-05-04 10:01:29');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`Brand_ID`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`Cart_ID`),
  ADD KEY `User_ID` (`User_ID`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`Category_ID`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`Coupon_ID`);

--
-- Indexes for table `orderdetaillogs`
--
ALTER TABLE `orderdetaillogs`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`Order_ID`),
  ADD KEY `User_ID` (`User_ID`),
  ADD KEY `FK_Coupon_Order` (`Coupon_ID`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`Order_Detail_ID`),
  ADD KEY `Order_ID` (`Order_ID`),
  ADD KEY `Product_ID` (`Product_ID`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`Product_ID`),
  ADD KEY `Category_ID` (`Category_ID`),
  ADD KEY `FK_Brand_Product` (`Brand_ID`),
  ADD KEY `FK_Product_Seller` (`Seller_ID`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`Review_ID`),
  ADD KEY `Product_ID` (`Product_ID`),
  ADD KEY `User_ID` (`User_ID`);

--
-- Indexes for table `seller`
--
ALTER TABLE `seller`
  ADD PRIMARY KEY (`Seller_ID`),
  ADD UNIQUE KEY `Seller_Email` (`Seller_Email`),
  ADD UNIQUE KEY `Seller_Email_2` (`Seller_Email`),
  ADD UNIQUE KEY `Tax_Number` (`Tax_Number`);

--
-- Indexes for table `shipping`
--
ALTER TABLE `shipping`
  ADD PRIMARY KEY (`Shipping_ID`),
  ADD KEY `Order_ID` (`Order_ID`);

--
-- Indexes for table `trlog`
--
ALTER TABLE `trlog`
  ADD PRIMARY KEY (`LogID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`User_ID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`wishlist_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `product_id` (`product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `Brand_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `Cart_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `Category_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `Coupon_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orderdetaillogs`
--
ALTER TABLE `orderdetaillogs`
  MODIFY `LogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `Order_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5421;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `Order_Detail_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `Product_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `Review_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `seller`
--
ALTER TABLE `seller`
  MODIFY `Seller_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `shipping`
--
ALTER TABLE `shipping`
  MODIFY `Shipping_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `trlog`
--
ALTER TABLE `trlog`
  MODIFY `LogID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `User_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `wishlist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `users` (`User_ID`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `FK_Coupon_Order` FOREIGN KEY (`Coupon_ID`) REFERENCES `coupons` (`Coupon_ID`),
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`User_ID`) REFERENCES `users` (`User_ID`);

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`Order_ID`) REFERENCES `orders` (`Order_ID`),
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`Product_ID`) REFERENCES `products` (`Product_ID`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `FK_Brand_Product` FOREIGN KEY (`Brand_ID`) REFERENCES `brands` (`Brand_ID`),
  ADD CONSTRAINT `FK_Product_Seller` FOREIGN KEY (`Seller_ID`) REFERENCES `seller` (`Seller_ID`),
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`Category_ID`) REFERENCES `categories` (`Category_ID`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`Product_ID`) REFERENCES `products` (`Product_ID`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`User_ID`) REFERENCES `users` (`User_ID`);

--
-- Constraints for table `shipping`
--
ALTER TABLE `shipping`
  ADD CONSTRAINT `shipping_ibfk_1` FOREIGN KEY (`Order_ID`) REFERENCES `orders` (`Order_ID`);

--
-- Constraints for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`User_ID`),
  ADD CONSTRAINT `wishlists_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`Product_ID`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `calculate_weekly_revenue` ON SCHEDULE EVERY 1 WEEK STARTS '2024-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    CALL CalculateTotalRevenue(CURDATE() - INTERVAL 1 WEEK, CURDATE());
    INSERT INTO revenue_data (period_start, period_end, total_revenue)
    VALUES (CURDATE() - INTERVAL 1 WEEK, CURDATE(), @TotalRevenue);
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
