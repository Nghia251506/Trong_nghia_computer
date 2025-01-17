create database TNC;

use TNC;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    role ENUM('admin', 'customer') DEFAULT 'customer',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(50) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    category_id INT,
    brand_id INT,
    image_url VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);



CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE order_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    permissions JSON, -- JSON lưu trữ các quyền như ['manage_users', 'manage_orders', 'manage_products']
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE discounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percentage INT CHECK (discount_percentage BETWEEN 1 AND 100),
    start_date DATETIME,
    end_date DATETIME,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id)
);

CREATE TABLE banners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    link_url VARCHAR(255),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(50) NOT NULL,
    value TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE bills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL, -- Người lập hóa đơn
    customer_name VARCHAR(100), -- Tên khách hàng (nếu không có tài khoản)
    customer_phone VARCHAR(15), -- Số điện thoại khách hàng
    total_price BIGINT NOT NULL,
    payment_method ENUM('cash', 'credit_card', 'online') DEFAULT 'cash', -- Phương thức thanh toán
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id)
);

CREATE TABLE bill_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price BIGINT NOT NULL, -- Giá tại thời điểm bán
    FOREIGN KEY (bill_id) REFERENCES bills(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

DELIMITER //

CREATE PROCEDURE AddProductWithCode(
    IN product_name VARCHAR(255),
    IN product_description TEXT,
    IN product_price BIGINT,
    IN product_quantity INT,
    IN product_category_id INT,
    IN product_brand_id INT,
    IN product_image VARCHAR(255)
)
BEGIN
    DECLARE prefix_category VARCHAR(10);
    DECLARE prefix_brand VARCHAR(10);
    DECLARE new_code VARCHAR(50);

    -- Lấy prefix của category
    SELECT LEFT(name, 3)
    INTO prefix_category
    FROM categories
    WHERE id = product_category_id;

    -- Lấy prefix của brand
    SELECT LEFT(name, 3)
    INTO prefix_brand
    FROM brands
    WHERE id = product_brand_id;

    -- Tạo mã sản phẩm dạng PREFIX_CATEGORY-PREFIX_BRAND-ID
    INSERT INTO products (name,description, price, quantity, category_id, brand_id, image_url)
    VALUES (product_name,product_description, product_price, product_quantity, product_category_id, product_brand_id,product_image);

    SET new_code = CONCAT(UCASE(prefix_category), '-', UCASE(prefix_brand), '-', LPAD(LAST_INSERT_ID(), 3, '0'));

    -- Cập nhật mã sản phẩm
    UPDATE products
    SET code = new_code
    WHERE id = LAST_INSERT_ID();
END //

DELIMITER ;



-- DML --
use TNC;
-- brand --
insert into brands (`brand_name`) values("Dell");
insert into brands (`brand_name`) values("Asus");
insert into brands (`brand_name`) values("Lenovo");
insert into brands (`brand_name`) values("Gigabyte");
insert into brands (`brand_name`) values("Macbook");

-- categories --
insert into categories (`category_name`) values("Laptop Văn Phòng");
insert into categories (`category_name`) values("Laptop Gaming");
insert into categories (`category_name`) values("PC Văn Phòng");
insert into categories (`category_name`) values("PC Gaming");
insert into categories (`category_name`) values("PC Workstation");

-- products --

CALL AddProductWithCode(
    'Laptop Dell XPS', 
    'Máy tính xách tay hiệu suất cao', 
    25000000, 
    10, 
    6, 
    1, 
    'dell_xps_image.png'
);

CALL AddProductWithCode(
    'Laptop Asus TUF F15', 
    'Máy tính xách tay GAMING hiệu suất cao', 
    30000000, 
    10, 
    7, 
    2, 
    'Asus_tuf.png'
);


