CREATE TABLE branches (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE orders ADD COLUMN branch_id BIGINT NULL REFERENCES branches(id);

CREATE INDEX idx_orders_branch_id ON orders(branch_id);

INSERT INTO branches (name, address, lat, lng) VALUES
  ('Freshmeal Downtown', '123 Main Street, Downtown', 3.1390, 101.6869),
  ('Freshmeal Mall', '456 Shopping Ave, Mall Area', 3.1570, 101.7120),
  ('Freshmeal Heights', '789 Hilltop Road, Heights', 3.1200, 101.6500);
