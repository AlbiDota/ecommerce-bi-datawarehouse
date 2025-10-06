-- ==============================
-- DIMENSION TABLES (STAR SCHEMA)
-- ==============================
-- DROP SEQUENCE seq_geo_sk ;
-- DROP SEQUENCE seq_review_sk;
DROP TABLE IF EXISTS dim_geography, dim_customer, dim_seller, dim_date, dim_product, fact_order_item, fact_payment, fact_review, fact_order CASCADE;
-- CREATE SEQUENCE seq_geo_sk START 1;
-- CREATE SEQUENCE seq_review_sk START 1;
-- ==============================
-- Surrogate
-- ==============================
DROP SEQUENCE IF EXISTS seq_customer_sk;
DROP SEQUENCE IF EXISTS seq_product_sk ;
DROP SEQUENCE IF EXISTS seq_seller_sk ;
DROP SEQUENCE IF EXISTS seq_date_sk ;
DROP SEQUENCE IF EXISTS seq_geo_sk ;
DROP SEQUENCE IF EXISTS seq_order_sk ;
DROP SEQUENCE IF EXISTS seq_order_item_sk ;
DROP SEQUENCE IF EXISTS seq_payment_sk;
DROP SEQUENCE IF EXISTS seq_review_sk ;

CREATE SEQUENCE seq_customer_sk START 1;
CREATE SEQUENCE seq_product_sk START 1;
CREATE SEQUENCE seq_seller_sk START 1;
CREATE SEQUENCE seq_date_sk START 1;
CREATE SEQUENCE seq_geo_sk START 1;
CREATE SEQUENCE seq_order_sk START 1;
CREATE SEQUENCE seq_order_item_sk START 1;
CREATE SEQUENCE seq_payment_sk START 1;
CREATE SEQUENCE seq_review_sk START 1;
-- ==============================
-- DIMENSION TABLES
-- ==============================

CREATE TABLE dim_customer
(
  seq_customer_sk BIGINT PRIMARY KEY DEFAULT nextval('seq_customer_sk'),
  customer_id VARCHAR(32),
  customer_unique_id VARCHAR(32), 
  customer_zip_code_prefix BIGINT,
  customer_city VARCHAR(32),
  customer_state VARCHAR(2)
);

CREATE TABLE dim_product
(
  seq_product_sk BIGINT PRIMARY KEY DEFAULT nextval('seq_product_sk'),
  product_id VARCHAR(32),
  product_category_name VARCHAR(46),
  product_name_length BIGINT,
  product_description_length BIGINT,
  product_photos_qty BIGINT,
  product_weight_g BIGINT,
  product_length_cm BIGINT,
  product_height_cm BIGINT,
  product_width_cm BIGINT
);

CREATE TABLE dim_seller
(
  seq_seller_sk BIGINT PRIMARY KEY DEFAULT nextval('seq_seller_sk'),
  seller_id VARCHAR(32),
  seller_zip_code_prefix BIGINT,
  seller_city VARCHAR(40),
  seller_state VARCHAR(2)
);

CREATE TABLE dim_geography
(
  seq_geo_sk BIGINT PRIMARY KEY DEFAULT nextval('seq_geo_sk'),
  geolocation_zip_code_prefix BIGINT,
  geolocation_lat NUMERIC(43, 20),
  geolocation_lng NUMERIC(35, 16),
  geolocation_city VARCHAR(38),
  geolocation_state VARCHAR(2)
);

-- ==============================
-- FACT TABLES
-- ==============================

CREATE TABLE fact_order
(
  seq_order_sk BIGINT PRIMARY KEY DEFAULT nextval('seq_order_sk'),
  order_id VARCHAR(32),
  seq_customer_sk BIGINT,
  --customer_id VARCHAR(32) NOT NULL,  
  order_status VARCHAR(11),
  order_purchase_timestamp VARCHAR(19),
  order_approved_at VARCHAR(19),
  order_delivered_carrier_date TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP,
  CONSTRAINT fk_order_customer FOREIGN KEY (seq_customer_sk) 
      REFERENCES dim_customer(seq_customer_sk)
);

-- SELECT * FROM public.dim_customer
-- ORDER BY seq_customer_sk ASC; 

CREATE TABLE fact_order_item
(
  seq_order_sk BIGINT,
  --order_id VARCHAR(32) NOT NULL,
  order_item_id BIGINT NOT NULL,
  -- product_id VARCHAR(32) NOT NULL,
  -- seller_id VARCHAR(32) NOT NULL,
  seq_product_sk BIGINT,
  seq_seller_sk BIGINT,
  shipping_limit_date TIMESTAMP,
  price NUMERIC(9, 2),
  freight_value NUMERIC(8, 2),
  PRIMARY KEY (seq_order_sk, order_item_id),
  CONSTRAINT fk_order_item_order FOREIGN KEY (seq_order_sk) 
      REFERENCES fact_order(seq_order_sk),
  CONSTRAINT fk_order_item_product FOREIGN KEY (seq_product_sk) 
      REFERENCES dim_product(seq_product_sk),
  CONSTRAINT fk_order_item_seller FOREIGN KEY (seq_seller_sk) 
      REFERENCES dim_seller(seq_seller_sk)
);

CREATE TABLE fact_payment
(
  seq_order_sk BIGINT NOT NULL,
  payment_sequential BIGINT NOT NULL,
  payment_type VARCHAR(11),
  payment_installments BIGINT,
  payment_value NUMERIC(10, 2),
  PRIMARY KEY (seq_order_sk, payment_sequential),
  CONSTRAINT fk_payment_order FOREIGN KEY (seq_order_sk) 
      REFERENCES fact_order(seq_order_sk)
);


CREATE TABLE fact_review
(
  seq_review_sk BIGSERIAL PRIMARY KEY,
  review_id VARCHAR(32),
  seq_order_sk BIGINT NOT NULL,
  review_score BIGINT,
  review_comment_title VARCHAR(35),
  review_comment_message VARCHAR(269),
  review_creation_date TIMESTAMP,
  review_answer_timestamp VARCHAR(19),
  CONSTRAINT fk_review_order FOREIGN KEY (seq_order_sk) 
      REFERENCES fact_order(seq_order_sk)
);

