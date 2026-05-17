-- ============================================
-- CLEAN LAYER: Deduplication, null handling,
-- standardisation
-- ============================================

CREATE TABLE clean_customers AS
SELECT DISTINCT ON (customer_unique_id)
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    UPPER(TRIM(customer_city))  AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw_customers
ORDER BY customer_unique_id;

CREATE TABLE clean_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE WHEN order_delivered_customer_date IS NULL THEN true ELSE false END AS is_delivery_missing,
    CASE WHEN order_approved_at IS NULL THEN true ELSE false END AS is_approval_missing
FROM raw_orders
WHERE order_status NOT IN ('unavailable', 'canceled');

CREATE TABLE clean_order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    ROUND(price + freight_value, 2) AS total_item_value
FROM raw_order_items
WHERE price > 0;

CREATE TABLE clean_order_payments AS
SELECT DISTINCT ON (order_id)
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM raw_order_payments
ORDER BY order_id, payment_value DESC;

CREATE TABLE clean_order_reviews AS
SELECT DISTINCT ON (review_id)
    review_id,
    order_id,
    COALESCE(review_score, 0)                      AS review_score,
    COALESCE(review_comment_title, 'No Title')     AS review_comment_title,
    COALESCE(review_comment_message, 'No Comment') AS review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM raw_order_reviews
ORDER BY review_id;

CREATE TABLE clean_category_translation AS
SELECT DISTINCT ON (product_category_name)
    product_category_name,
    product_category_name_english
FROM raw_category_translation
ORDER BY product_category_name;

CREATE TABLE clean_products AS
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, 'uncategorized') AS product_category,
    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g
FROM raw_products p
LEFT JOIN clean_category_translation t
    ON p.product_category_name = t.product_category_name;
