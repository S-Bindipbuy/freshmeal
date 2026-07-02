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
  ('Freshmeal Riverside', '#123 Sisowath Quay, Riverside', 11.5725, 104.9361),
  ('Freshmeal BKK', '#456 Norodom Blvd, Boeung Keng Kang', 11.5433, 104.9195),
  ('Freshmeal Toul Kork', '#789 Russian Blvd, Toul Kork', 11.5816, 104.9041);
