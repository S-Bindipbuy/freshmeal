use actix_web::web::Data;
use actix_web::{HttpResponse, delete, get, patch, post, put, web};
use bcrypt::{DEFAULT_COST, hash, verify};
use futures_util::StreamExt;
use rust_decimal::Decimal;
use sqlx::Row;
use tokio::fs::{self, File};
use tokio::io::AsyncWriteExt;
use uuid::Uuid;

use crate::error::AppError;
use crate::models::*;
use crate::proto;
use crate::utils::*;

#[post("/admin/register")]
pub async fn new_admin(
    claims: Claims,
    config: Data<AppConfiguration>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let form = decode_proto::<proto::RegisterRequest>(&body)?;
    let hashed = hash(&form.password, DEFAULT_COST)?;
    let res = sqlx::query_as::<_, User>(
        "INSERT INTO users (email, name, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, email, name, password_hash, role, avatar",
    )
    .bind(&form.email)
    .bind(&form.name)
    .bind(&hashed)
    .bind("admin")
    .fetch_one(&config.db_pool)
    .await;

    match res {
        Ok(u) => {
            let resp = login_response(&u, &config.jwt_secret)?;
            Ok(encode_proto_status(
                &resp,
                actix_web::http::StatusCode::CREATED,
            ))
        }
        Err(e) => Err(AppError::Conflict(e.to_string())),
    }
}

#[post("/register")]
pub async fn register(
    config: Data<AppConfiguration>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    use bcrypt::{DEFAULT_COST, hash};

    let form = decode_proto::<proto::RegisterRequest>(&body)?;
    let hashed = hash(&form.password, DEFAULT_COST)?;
    let res = sqlx::query_as::<_, User>(
        "INSERT INTO users (email, name, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, email, name, password_hash, role, avatar",
    )
    .bind(&form.email)
    .bind(&form.name)
    .bind(&hashed)
    .bind("customer")
    .fetch_one(&config.db_pool)
    .await;

    match res {
        Ok(u) => {
            let resp = login_response(&u, &config.jwt_secret)?;
            Ok(encode_proto_status(
                &resp,
                actix_web::http::StatusCode::CREATED,
            ))
        }
        Err(e) => Err(AppError::Conflict(e.to_string())),
    }
}

#[post("/login")]
pub async fn login(
    config: Data<AppConfiguration>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    let form = decode_proto::<proto::LoginRequest>(&body)?;
    let user = sqlx::query_as::<_, User>(
        "SELECT id, email, name, password_hash, role, avatar FROM users WHERE email = $1",
    )
    .bind(&form.email)
    .fetch_optional(&config.db_pool)
    .await?;

    if let Some(u) = user {
        if verify(&form.password, &u.password_hash)? {
            let resp = login_response(&u, &config.jwt_secret)?;
            return Ok(encode_proto(&resp));
        }
    }

    Err(AppError::Unauthorized("Invalid credentials".into()))
}

#[post("/products")]
pub async fn insert_product(
    claims: Claims,
    config: Data<AppConfiguration>,
    mut payload: actix_multipart::Multipart,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let mut name = String::new();
    let mut desc: Option<String> = None;
    let mut price = Decimal::ZERO;
    let mut avail = false;
    let mut img = String::new();
    let mut category_id: Option<i64> = None;

    while let Some(item) = payload.next().await {
        let mut field = item?;
        let cd = field
            .content_disposition()
            .and_then(|c| c.get_name().map(|s| s.to_string()));

        match cd.as_deref() {
            Some("name") => {
                if let Some(chunk) = field.next().await {
                    name = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid name UTF-8".into()))?;
                }
            }
            Some("description") => {
                if let Some(chunk) = field.next().await {
                    desc =
                        Some(String::from_utf8(chunk?.to_vec()).map_err(|_| {
                            AppError::BadRequest("Invalid description UTF-8".into())
                        })?);
                }
            }
            Some("price") => {
                if let Some(chunk) = field.next().await {
                    price = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid price UTF-8".into()))?
                        .parse()
                        .map_err(|_| AppError::BadRequest("Invalid price format".into()))?;
                }
            }
            Some("available") => {
                if let Some(chunk) = field.next().await {
                    avail = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid availability UTF-8".into()))?
                        == "true";
                }
            }
            Some("category_id") => {
                if let Some(chunk) = field.next().await {
                    let value = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid category_id UTF-8".into()))?;
                    category_id = if value.trim().is_empty() {
                        None
                    } else {
                        Some(value.parse().map_err(|_| {
                            AppError::BadRequest("Invalid category_id format".into())
                        })?)
                    };
                }
            }
            Some("image") => {
                let file_extension = field
                    .content_disposition()
                    .and_then(|c| c.get_filename_ext().map(|s| s.to_string()))
                    .unwrap_or("".to_string());

                let _ = fs::create_dir_all("uploads/").await;
                let file_name = Uuid::new_v4();
                let path = format!("uploads/{}.{}", file_name, file_extension);
                let mut f = File::create(&path).await?;

                while let Some(chunk) = field.next().await {
                    f.write_all(&chunk?).await?;
                }

                img = format!("{}.{}", file_name, file_extension);
            }
            _ => {}
        }
    }

    let res = sqlx::query_as!(
        DbProduct,
        "INSERT INTO products (name, description, price, available, image, category_id) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *",
        name, desc, price, avail, img, category_id
    )
    .fetch_one(&config.db_pool)
    .await?;

    Ok(encode_proto_status(
        &proto::Product::from(res),
        actix_web::http::StatusCode::CREATED,
    ))
}

#[put("/products/{id}")]
pub async fn update_product(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
    mut payload: actix_multipart::Multipart,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let product_id = path.into_inner();
    let existing = sqlx::query_as!(
        DbProduct,
        "SELECT id, name, description, price, category_id, deleted_at, created_at, available, image FROM products WHERE id = $1",
        product_id
    )
    .fetch_optional(&config.db_pool)
    .await?
    .ok_or_else(|| AppError::BadRequest("Product not found".into()))?;

    let mut name = existing.name;
    let mut desc = existing.description;
    let mut price = existing.price;
    let mut avail = existing.available;
    let mut img = existing.image;
    let mut category_id = existing.category_id;

    while let Some(item) = payload.next().await {
        let mut field = item?;
        let cd = field
            .content_disposition()
            .and_then(|c| c.get_name().map(|s| s.to_string()));

        match cd.as_deref() {
            Some("name") => {
                if let Some(chunk) = field.next().await {
                    name = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid name UTF-8".into()))?;
                }
            }
            Some("description") => {
                if let Some(chunk) = field.next().await {
                    desc =
                        Some(String::from_utf8(chunk?.to_vec()).map_err(|_| {
                            AppError::BadRequest("Invalid description UTF-8".into())
                        })?);
                }
            }
            Some("price") => {
                if let Some(chunk) = field.next().await {
                    price = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid price UTF-8".into()))?
                        .parse()
                        .map_err(|_| AppError::BadRequest("Invalid price format".into()))?;
                }
            }
            Some("available") => {
                if let Some(chunk) = field.next().await {
                    avail = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid availability UTF-8".into()))?
                        == "true";
                }
            }
            Some("category_id") => {
                if let Some(chunk) = field.next().await {
                    let value = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid category_id UTF-8".into()))?;
                    category_id = if value.trim().is_empty() {
                        None
                    } else {
                        Some(value.parse().map_err(|_| {
                            AppError::BadRequest("Invalid category_id format".into())
                        })?)
                    };
                }
            }
            Some("image") => {
                let file_extension = field
                    .content_disposition()
                    .and_then(|c| c.get_filename_ext().map(|s| s.to_string()))
                    .unwrap_or("jpg".to_string());
                let _ = fs::create_dir_all("uploads/").await;
                let file_name = Uuid::new_v4();
                let path = format!("uploads/{}.{}", file_name, file_extension);
                let mut f = File::create(&path).await?;

                while let Some(chunk) = field.next().await {
                    f.write_all(&chunk?).await?;
                }

                img = format!("{}.{}", file_name, file_extension);
            }
            _ => {}
        }
    }

    let res = sqlx::query_as!(
        DbProduct,
        "UPDATE products SET name = $1, description = $2, price = $3, available = $4, image = $5, category_id = $6 WHERE id = $7 RETURNING id, name, description, price, category_id, deleted_at, created_at, available, image",
        name, desc, price, avail, img, category_id, product_id
    )
    .fetch_one(&config.db_pool)
    .await?;

    Ok(encode_proto(&proto::Product::from(res)))
}

#[delete("/products/{id}")]
pub async fn delete_product(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let product_id = path.into_inner();
    sqlx::query("UPDATE products SET deleted_at = NOW() WHERE id = $1")
        .bind(product_id)
        .execute(&config.db_pool)
        .await?;

    Ok(encode_proto(&proto::Empty {}))
}

#[get("/products")]
pub async fn list_products(
    config: Data<AppConfiguration>,
    query: web::Query<ProductQuery>,
) -> Result<HttpResponse, AppError> {
    let mut sql = "SELECT id, name, description, price, category_id, deleted_at, created_at, available, image FROM products WHERE deleted_at IS NULL".to_string();
    let mut text_params: Vec<String> = vec![];
    let mut int_params: Vec<i64> = vec![];

    if let Some(ref s) = query.search {
        if !s.is_empty() {
            text_params.push(format!("%{}%", s));
            sql.push_str(&format!(
                " AND (name ILIKE ${} OR description ILIKE ${})",
                text_params.len(),
                text_params.len()
            ));
        }
    }
    if let Some(cat_id) = query.category_id {
        int_params.push(cat_id);
        sql.push_str(&format!(
            " AND category_id = ${}",
            text_params.len() + int_params.len()
        ));
    }

    sql.push_str(" ORDER BY name");

    let mut q = sqlx::query_as::<_, DbProduct>(&sql);
    for p in &text_params {
        q = q.bind(p);
    }
    for p in &int_params {
        q = q.bind(p);
    }
    let list = q.fetch_all(&config.db_pool).await?;

    let products: Vec<proto::Product> = list.into_iter().map(proto::Product::from).collect();
    Ok(encode_proto(&proto::ProductList { products }))
}

#[post("/orders")]
pub async fn create_orders(
    claims: Claims,
    config: Data<AppConfiguration>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    let req_list = decode_proto::<proto::OrderRequestList>(&body)?;
    let mut tx = config.db_pool.begin().await?;

    let user_row = sqlx::query("SELECT id FROM users WHERE email = $1")
        .bind(&claims.email)
        .fetch_optional(&mut *tx)
        .await?
        .ok_or_else(|| AppError::Unauthorized("User not found".into()))?;

    let user_id: i64 = user_row.get(0);

    let mut unique_p_ids: Vec<i64> = req_list.requests.iter().map(|i| i.product_id).collect();
    unique_p_ids.sort();
    unique_p_ids.dedup();

    let products = sqlx::query!(
        "SELECT id, price FROM products WHERE id = ANY($1) AND available = TRUE",
        &unique_p_ids
    )
    .fetch_all(&mut *tx)
    .await?;

    if products.len() != unique_p_ids.len() {
        return Err(AppError::BadRequest(
            "Some products are invalid or unavailable".into(),
        ));
    }

    let branch_id = req_list.branch_id;
    let delivery_lat = req_list.delivery_lat;
    let delivery_lng = req_list.delivery_lng;

    let order_id = sqlx::query(
        "INSERT INTO orders (user_id, status, total, branch_id, delivery_lat, delivery_lng) \
         VALUES ($1, 'pending', 0, $2, $3, $4) RETURNING id",
    )
    .bind(user_id)
    .bind(branch_id)
    .bind(delivery_lat)
    .bind(delivery_lng)
    .fetch_one(&mut *tx)
    .await?
    .get::<i64, _>("id");

    for item in req_list.requests {
        if let Some(p) = products.iter().find(|p| p.id == item.product_id) {
            sqlx::query!(
                r#"
                INSERT INTO order_items (order_id, product_id, quantity, price_at_time)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (order_id, product_id) 
                DO UPDATE SET quantity = order_items.quantity + EXCLUDED.quantity
                "#,
                order_id,
                p.id,
                item.quantity as i32,
                p.price
            )
            .execute(&mut *tx)
            .await?;
        }
    }

    sqlx::query!(
        r#"
        UPDATE orders 
        SET total = (
            SELECT SUM(quantity * price_at_time) 
            FROM order_items 
            WHERE order_id = $1
        )
        WHERE id = $1
        "#,
        order_id
    )
    .execute(&mut *tx)
    .await?;

    tx.commit().await?;

    Ok(encode_proto_status(
        &proto::CreateOrderResponse { id: order_id },
        actix_web::http::StatusCode::CREATED,
    ))
}

#[get("/orders")]
pub async fn order_history(
    claims: Claims,
    config: Data<AppConfiguration>,
    query: web::Query<OrderHistoryQuery>,
) -> Result<HttpResponse, AppError> {
    let limit = query.limit.unwrap_or(20).min(100);
    let last_id = query.last_id.unwrap_or(i64::MAX);

    let orders = if claims.role == "admin" {
        sqlx::query_as::<_, OrderHistoryRow>(
            r#"
            SELECT o.id, o.user_id, o.status, o.total, o.created_at, o.branch_id,
                   u.name as user_name, o.delivery_lat, o.delivery_lng
            FROM orders o
            JOIN users u ON o.user_id = u.id
            WHERE o.id < $1
            ORDER BY o.id DESC
            LIMIT $2
            "#,
        )
        .bind(last_id)
        .bind(limit)
        .fetch_all(&config.db_pool)
        .await?
    } else {
        sqlx::query_as::<_, OrderHistoryRow>(
            r#"
            SELECT o.id, o.user_id, o.status, o.total, o.created_at, o.branch_id,
                   u.name as user_name, o.delivery_lat, o.delivery_lng
            FROM orders o
            JOIN users u ON o.user_id = u.id
            WHERE u.email = $1
              AND o.id < $2
            ORDER BY o.id DESC
            LIMIT $3
            "#,
        )
        .bind(&claims.email)
        .bind(last_id)
        .bind(limit)
        .fetch_all(&config.db_pool)
        .await?
    };

    if orders.is_empty() {
        return Ok(encode_proto(&proto::OrderHistoryList { orders: vec![] }));
    }

    let order_ids: Vec<i64> = orders.iter().map(|o| o.id).collect();

    let items = sqlx::query_as::<_, OrderItemDb>(
        r#"
        SELECT oi.order_id, oi.id, oi.product_id, p.name as product_name, oi.quantity, oi.price_at_time
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = ANY($1)
        ORDER BY oi.id
        "#,
    )
    .bind(&order_ids)
    .fetch_all(&config.db_pool)
    .await?;

    use std::collections::HashMap;
    let mut items_by_order: HashMap<i64, Vec<OrderItemDb>> = HashMap::new();
    for item in items {
        items_by_order.entry(item.order_id).or_default().push(item);
    }

    let proto_orders: Vec<proto::OrderHistoryItem> = orders
        .into_iter()
        .map(|row| {
            let order_items = items_by_order.remove(&row.id).unwrap_or_default();
            let proto_items = order_items
                .into_iter()
                .map(|i| proto::OrderItem {
                    id: i.id,
                    product_id: i.product_id,
                    product_name: i.product_name,
                    quantity: i.quantity,
                    price_at_time: format!("{:.2}", i.price_at_time.round_dp(2)),
                })
                .collect();
            proto::OrderHistoryItem {
                id: row.id,
                user_id: row.user_id,
                status: db_status_to_proto(&row.status),
                total: format!("{:.2}", row.total.round_dp(2)),
                created_at: row.created_at.to_string(),
                items: proto_items,
                branch_id: row.branch_id,
                user_name: row.user_name,
                delivery_lat: row.delivery_lat,
                delivery_lng: row.delivery_lng,
            }
        })
        .collect();

    Ok(encode_proto(&proto::OrderHistoryList {
        orders: proto_orders,
    }))
}

#[post("/orders/{id}/cancel")]
pub async fn cancel_order(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
) -> Result<HttpResponse, AppError> {
    let order_id = path.into_inner();

    let result = sqlx::query(
        "UPDATE orders SET status = 'cancelled'::order_status WHERE id = $1 AND user_id = (SELECT id FROM users WHERE email = $2) AND status = 'pending'::order_status",
    )
    .bind(order_id)
    .bind(&claims.email)
    .execute(&config.db_pool)
    .await?;

    if result.rows_affected() == 0 {
        return Err(AppError::BadRequest(
            "Order not found or cannot be cancelled".into(),
        ));
    }

    Ok(encode_proto(&proto::Empty {}))
}

#[patch("/admin/orders/{id}/status")]
pub async fn update_order_status(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let order_id = path.into_inner();
    let req: UpdateOrderStatusBody =
        serde_json::from_slice(&body).map_err(|e| AppError::BadRequest(e.to_string()))?;

    let status_str = match req.status {
        OrderStatus::Pending => "pending",
        OrderStatus::Paid => "paid",
        OrderStatus::Confirmed => "confirmed",
        OrderStatus::Preparing => "preparing",
        OrderStatus::Delivered => "delivered",
        OrderStatus::Cancelled => "cancelled",
    };

    let result = sqlx::query("UPDATE orders SET status = $1::order_status WHERE id = $2")
        .bind(status_str)
        .bind(order_id)
        .execute(&config.db_pool)
        .await?;

    if result.rows_affected() == 0 {
        return Err(AppError::BadRequest("Order not found".into()));
    }

    Ok(encode_proto(&proto::Empty {}))
}

#[post("/orders/{id}/checkout")]
pub async fn checkout_order(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
) -> Result<HttpResponse, AppError> {
    let order_id = path.into_inner();

    let result = sqlx::query(
        "UPDATE orders SET status = 'paid'::order_status WHERE id = $1 AND user_id = (SELECT id FROM users WHERE email = $2) AND status = 'pending'::order_status",
    )
    .bind(order_id)
    .bind(&claims.email)
    .execute(&config.db_pool)
    .await?;

    if result.rows_affected() == 0 {
        return Err(AppError::BadRequest(
            "Order not found or already paid".into(),
        ));
    }

    Ok(encode_proto(&proto::Empty {}))
}

#[patch("/orders/{order_id}/items/{product_id}")]
pub async fn update_cart_item(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<(i64, i64)>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    let (order_id, product_id) = path.into_inner();
    let req: UpdateCartItemBody =
        serde_json::from_slice(&body).map_err(|e| AppError::BadRequest(e.to_string()))?;

    if req.quantity <= 0 {
        sqlx::query(
            "DELETE FROM order_items WHERE order_id = $1 AND product_id = $2 AND order_id = (SELECT id FROM orders WHERE id = $1 AND user_id = (SELECT id FROM users WHERE email = $3) AND status = 'pending'::order_status)",
        )
        .bind(order_id)
        .bind(product_id)
        .bind(&claims.email)
        .execute(&config.db_pool)
        .await?;
    } else {
        let result = sqlx::query(
            "UPDATE order_items SET quantity = $1 WHERE order_id = $2 AND product_id = $3 AND order_id = (SELECT id FROM orders WHERE id = $2 AND user_id = (SELECT id FROM users WHERE email = $4) AND status = 'pending'::order_status)",
        )
        .bind(req.quantity)
        .bind(order_id)
        .bind(product_id)
        .bind(&claims.email)
        .execute(&config.db_pool)
        .await?;

        if result.rows_affected() == 0 {
            return Err(AppError::BadRequest(
                "Item not found in pending order".into(),
            ));
        }
    }

    sqlx::query(
        "UPDATE orders SET total = (SELECT SUM(quantity * price_at_time) FROM order_items WHERE order_id = $1) WHERE id = $1",
    )
    .bind(order_id)
    .execute(&config.db_pool)
    .await?;

    Ok(encode_proto(&proto::Empty {}))
}

#[get("/profile")]
pub async fn get_profile(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    let row = sqlx::query("SELECT id, email, name, role, avatar FROM users WHERE email = $1")
        .bind(&claims.email)
        .fetch_optional(&config.db_pool)
        .await?
        .ok_or_else(|| AppError::Unauthorized("User not found".into()))?;

    let db_role: Role = row.get("role");
    let profile = proto::ProfileResponse {
        id: row.get("id"),
        email: row.get("email"),
        name: row.get("name"),
        role: db_role_to_proto(&db_role),
        avatar: row.get("avatar"),
    };

    Ok(encode_proto(&profile))
}

#[get("/customer")]
pub async fn get_customers(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let customers = sqlx::query_as::<_, DbCustomer>(
        "SELECT id, name, email, created_at FROM users WHERE role = 'customer' ORDER BY created_at DESC",
    )
    .fetch_all(&config.db_pool)
    .await?;

    let customers: Vec<proto::CustomerResponse> = customers
        .into_iter()
        .map(proto::CustomerResponse::from)
        .collect();
    Ok(encode_proto(&proto::CustomerList { customers }))
}

#[post("/profile/avatar")]
pub async fn upload_avatar(
    claims: Claims,
    config: Data<AppConfiguration>,
    mut payload: actix_multipart::Multipart,
) -> Result<HttpResponse, AppError> {
    let mut avatar_filename = String::new();

    while let Some(item) = payload.next().await {
        let mut field = item?;
        let cd = field
            .content_disposition()
            .and_then(|c| c.get_name().map(|s| s.to_string()));

        if cd.as_deref() == Some("image") {
            let file_extension = field
                .content_disposition()
                .and_then(|c| c.get_filename_ext().map(|s| s.to_string()))
                .unwrap_or("jpg".to_string());
            fs::create_dir_all("uploads/").await?;
            let file_name = Uuid::new_v4();
            let path = format!("uploads/{}.{}", file_name, file_extension);

            let mut f = File::create(&path).await?;

            while let Some(chunk) = field.next().await {
                f.write_all(&chunk?).await?;
            }
            avatar_filename = format!("{}.{}", file_name, file_extension);
        }
    }

    if avatar_filename.is_empty() {
        return Err(AppError::BadRequest("No image file provided".into()));
    }

    sqlx::query("UPDATE users SET avatar = $1 WHERE email = $2")
        .bind(&avatar_filename)
        .bind(&claims.email)
        .execute(&config.db_pool)
        .await?;

    Ok(encode_proto(&proto::AvatarResponse {
        avatar: avatar_filename,
    }))
}

#[get("/admin/revenue/monthly")]
pub async fn get_monthly_revenue(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let rows = sqlx::query_as::<_, DbMonthlyRevenue>(
        "SELECT year, month, order_count, revenue FROM monthly_revenue",
    )
    .fetch_all(&config.db_pool)
    .await?;

    let revenues: Vec<proto::MonthlyRevenue> =
        rows.into_iter().map(proto::MonthlyRevenue::from).collect();
    Ok(encode_proto(&proto::MonthlyRevenueList { revenues }))
}

#[get("/admin/revenue/yearly")]
pub async fn get_yearly_revenue(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let rows = sqlx::query_as::<_, DbYearlyRevenue>(
        "SELECT year, order_count, revenue FROM yearly_revenue",
    )
    .fetch_all(&config.db_pool)
    .await?;

    let revenues: Vec<proto::YearlyRevenue> =
        rows.into_iter().map(proto::YearlyRevenue::from).collect();
    Ok(encode_proto(&proto::YearlyRevenueList { revenues }))
}

#[get("/categories")]
pub async fn list_categories(
    config: Data<AppConfiguration>,
    query: web::Query<CatQuery>,
) -> Result<HttpResponse, AppError> {
    let mut sql = "SELECT id, name, description, created_at FROM categories".to_string();
    let mut params: Vec<String> = vec![];

    if let Some(ref s) = query.search {
        if !s.is_empty() {
            params.push(format!("%{}%", s));
            sql.push_str(&format!(
                " WHERE (name ILIKE ${} OR description ILIKE ${})",
                params.len(),
                params.len()
            ));
        }
    }

    sql.push_str(" ORDER BY name");

    let mut q = sqlx::query_as::<_, DbCategory>(&sql);
    for p in &params {
        q = q.bind(p);
    }
    let list = q.fetch_all(&config.db_pool).await?;

    let categories: Vec<proto::Category> = list.into_iter().map(proto::Category::from).collect();
    Ok(encode_proto(&proto::CategoryList { categories }))
}

#[post("/categories")]
pub async fn create_category(
    claims: Claims,
    config: Data<AppConfiguration>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let form = decode_proto::<proto::Category>(&body)?;
    if form.name.is_empty() {
        return Err(AppError::BadRequest("Category name is required".into()));
    }

    let res = sqlx::query_as::<_, DbCategory>(
        "INSERT INTO categories (name, description) VALUES ($1, $2) RETURNING id, name, description, created_at",
    )
    .bind(&form.name)
    .bind(&form.description)
    .fetch_one(&config.db_pool)
    .await
    .map_err(|e| AppError::Conflict(e.to_string()))?;

    Ok(encode_proto_status(
        &proto::Category::from(res),
        actix_web::http::StatusCode::CREATED,
    ))
}

#[put("/categories/{id}")]
pub async fn update_category(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let cat_id = path.into_inner();
    let form = decode_proto::<proto::Category>(&body)?;
    if form.name.is_empty() {
        return Err(AppError::BadRequest("Category name is required".into()));
    }

    let res = sqlx::query_as::<_, DbCategory>(
        "UPDATE categories SET name = $1, description = $2 WHERE id = $3 RETURNING id, name, description, created_at",
    )
    .bind(&form.name)
    .bind(&form.description)
    .bind(cat_id)
    .fetch_optional(&config.db_pool)
    .await?
    .ok_or_else(|| AppError::BadRequest("Category not found".into()))?;

    Ok(encode_proto(&proto::Category::from(res)))
}

#[delete("/categories/{id}")]
pub async fn delete_category(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let cat_id = path.into_inner();
    let mut tx = config.db_pool.begin().await?;
    sqlx::query("UPDATE products SET category_id = NULL WHERE category_id = $1")
        .bind(cat_id)
        .execute(&mut *tx)
        .await?;
    sqlx::query("DELETE FROM categories WHERE id = $1")
        .bind(cat_id)
        .execute(&mut *tx)
        .await?;
    tx.commit().await?;

    Ok(encode_proto(&proto::Empty {}))
}

#[get("/branches")]
pub async fn list_branches(config: Data<AppConfiguration>) -> Result<HttpResponse, AppError> {
    let list = sqlx::query_as::<_, DbBranch>(
        "SELECT id, name, address, lat, lng, created_at FROM branches ORDER BY name",
    )
    .fetch_all(&config.db_pool)
    .await?;

    let branches: Vec<proto::Branch> = list.into_iter().map(proto::Branch::from).collect();
    Ok(encode_proto(&proto::BranchList { branches }))
}

#[get("/branches/nearest")]
pub async fn get_nearest_branch(
    config: Data<AppConfiguration>,
    query: web::Query<NearestBranchQuery>,
) -> Result<HttpResponse, AppError> {
    let branch = sqlx::query_as::<_, DbBranch>(
        r#"
        SELECT id, name, address, lat, lng, created_at
        FROM branches
        ORDER BY (lat - $1) * (lat - $1) + (lng - $2) * (lng - $2)
        LIMIT 1
        "#,
    )
    .bind(query.lat)
    .bind(query.lng)
    .fetch_optional(&config.db_pool)
    .await?
    .ok_or_else(|| AppError::BadRequest("No branches found".into()))?;

    Ok(encode_proto(&proto::Branch::from(branch)))
}

#[post("/branches")]
pub async fn create_branch(
    claims: Claims,
    config: Data<AppConfiguration>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let form = decode_proto::<proto::Branch>(&body)?;
    if form.name.is_empty() || form.address.is_empty() {
        return Err(AppError::BadRequest("Name and address are required".into()));
    }

    let res = sqlx::query_as::<_, DbBranch>(
        "INSERT INTO branches (name, address, lat, lng) VALUES ($1, $2, $3, $4) RETURNING id, name, address, lat, lng, created_at",
    )
    .bind(&form.name)
    .bind(&form.address)
    .bind(form.lat)
    .bind(form.lng)
    .fetch_one(&config.db_pool)
    .await
    .map_err(|e| AppError::Conflict(e.to_string()))?;

    Ok(encode_proto_status(
        &proto::Branch::from(res),
        actix_web::http::StatusCode::CREATED,
    ))
}

#[put("/branches/{id}")]
pub async fn update_branch(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let branch_id = path.into_inner();
    let form = decode_proto::<proto::Branch>(&body)?;

    let res = sqlx::query_as::<_, DbBranch>(
        "UPDATE branches SET name = $1, address = $2, lat = $3, lng = $4 WHERE id = $5 RETURNING id, name, address, lat, lng, created_at",
    )
    .bind(&form.name)
    .bind(&form.address)
    .bind(form.lat)
    .bind(form.lng)
    .bind(branch_id)
    .fetch_optional(&config.db_pool)
    .await?
    .ok_or_else(|| AppError::BadRequest("Branch not found".into()))?;

    Ok(encode_proto(&proto::Branch::from(res)))
}

#[delete("/branches/{id}")]
pub async fn delete_branch(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let branch_id = path.into_inner();
    let mut tx = config.db_pool.begin().await?;

    sqlx::query("UPDATE orders SET branch_id = NULL WHERE branch_id = $1")
        .bind(branch_id)
        .execute(&mut *tx)
        .await?;

    sqlx::query("DELETE FROM branches WHERE id = $1")
        .bind(branch_id)
        .execute(&mut *tx)
        .await?;

    tx.commit().await?;

    Ok(encode_proto(&proto::Empty {}))
}

#[patch("/products/{id}/availability")]
pub async fn toggle_product_availability(
    claims: Claims,
    config: Data<AppConfiguration>,
    path: web::Path<i64>,
    body: web::Bytes,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let product_id = path.into_inner();
    let form = decode_proto::<proto::Product>(&body)?;

    let res = sqlx::query_as::<_, DbProduct>(
        "UPDATE products SET available = $1 WHERE id = $2 RETURNING id, name, description, price, category_id, deleted_at, created_at, available, image",
    )
    .bind(form.available)
    .bind(product_id)
    .fetch_optional(&config.db_pool)
    .await?
    .ok_or_else(|| AppError::BadRequest("Product not found".into()))?;

    Ok(encode_proto(&proto::Product::from(res)))
}
