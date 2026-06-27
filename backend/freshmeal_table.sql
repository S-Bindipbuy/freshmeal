DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TYPE IF EXISTS order_status;

CREATE TYPE order_status AS ENUM (
    'pending',
    'paid',
    'confirmed',
    'preparing',
    'delivered',
    'cancelled'
);

CREATE TYPE role AS ENUM (
    'admin',
    'customer',
    'restaurant'
);

CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role role NOT NULL DEFAULT 'customer',
    avatar TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    image TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    available BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status order_status NOT NULL DEFAULT 'pending',
    total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_time NUMERIC(10,2) NOT NULL CHECK (price_at_time >= 0),
    UNIQUE (order_id, product_id)
);

-- indexes
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_products_available_partial ON products(id) WHERE available = TRUE;
CREATE INDEX idx_orders_user_id_created_at ON orders(user_id, created_at DESC);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Revenue views (only count paid / delivered orders)
DROP VIEW IF EXISTS monthly_revenue;
CREATE VIEW monthly_revenue AS
SELECT
    EXTRACT(YEAR  FROM created_at)::INT AS year,
    EXTRACT(MONTH FROM created_at)::INT AS month,
    COUNT(*)                             AS order_count,
    COALESCE(SUM(total), 0)             AS revenue
FROM orders
WHERE status IN ('paid', 'delivered')
GROUP BY year, month
ORDER BY year DESC, month DESC;

DROP VIEW IF EXISTS yearly_revenue;
CREATE VIEW yearly_revenue AS
SELECT
    EXTRACT(YEAR FROM created_at)::INT AS year,
    COUNT(*)                            AS order_count,
    COALESCE(SUM(total), 0)            AS revenue
FROM orders
WHERE status IN ('paid', 'delivered')
GROUP BY year
ORDER BY year DESC;

-- Default admin user (password: admin123)
INSERT INTO users (email, name, password_hash, role) 
VALUES ('admin@freshmeal.com', 'Admin', '$2a$12$/iS0sL7dKiBJL/fhCdErzeZ6oJ3FRbNFG2BBrnEtreTsdHIquQQQ2', 'admin')
ON CONFLICT (email) DO NOTHING;
