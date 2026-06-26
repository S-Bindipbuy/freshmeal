use actix_files::Files;
use actix_multipart::{Multipart, MultipartError};
use actix_web::dev::Payload;
use actix_web::web::Data;
use actix_web::{
    App, FromRequest, HttpRequest, HttpResponse, HttpServer, ResponseError, error, get, post, web,
};
use bcrypt::{BcryptError, DEFAULT_COST, hash, verify};
use chrono::{Duration, NaiveDateTime, Utc};
use futures_util::StreamExt;
use jsonwebtoken::{
    DecodingKey, EncodingKey, Header, Validation, decode, encode, errors::Error as JwtError,
};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::postgres::PgPoolOptions;
use sqlx::{FromRow, Pool, Postgres, Row};
use std::fmt;
use std::future::{Ready, ready};
use tokio::fs::{self, File};
use tokio::io::AsyncWriteExt;
use uuid::Uuid;

#[derive(Debug)]
pub enum AppError {
    Internal(String),
    BadRequest(String),
    Unauthorized(String),
    Forbidden(String),
    Conflict(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::Internal(s) => write!(f, "Internal error: {}", s),
            AppError::BadRequest(s) => write!(f, "Bad request: {}", s),
            AppError::Unauthorized(s) => write!(f, "Unauthorized: {}", s),
            AppError::Forbidden(s) => write!(f, "Forbidden: {}", s),
            AppError::Conflict(s) => write!(f, "Conflict: {}", s),
        }
    }
}

impl ResponseError for AppError {
    fn error_response(&self) -> HttpResponse {
        match self {
            AppError::Internal(s) => HttpResponse::InternalServerError().body(s.clone()),
            AppError::BadRequest(s) => HttpResponse::BadRequest().body(s.clone()),
            AppError::Unauthorized(s) => HttpResponse::Unauthorized().body(s.clone()),
            AppError::Forbidden(s) => HttpResponse::Forbidden().body(s.clone()),
            AppError::Conflict(s) => HttpResponse::Conflict().body(s.clone()),
        }
    }
}

impl From<sqlx::Error> for AppError {
    fn from(e: sqlx::Error) -> Self {
        AppError::Internal(e.to_string())
    }
}

impl From<JwtError> for AppError {
    fn from(e: JwtError) -> Self {
        AppError::Unauthorized(e.to_string())
    }
}

impl From<BcryptError> for AppError {
    fn from(e: BcryptError) -> Self {
        AppError::Internal(e.to_string())
    }
}

impl From<MultipartError> for AppError {
    fn from(e: MultipartError) -> Self {
        AppError::BadRequest(e.to_string())
    }
}

impl From<std::io::Error> for AppError {
    fn from(e: std::io::Error) -> Self {
        AppError::Internal(e.to_string())
    }
}

#[derive(Deserialize)]
pub struct OrderPagination {
    pub last_id: Option<i64>,
    pub limit: Option<i64>,
}

#[derive(Serialize)]
pub struct OrderHistoryResponse {
    pub id: i64,
    pub user_id: i64,
    pub status: OrderStatus,
    pub total: Decimal,
    pub created_at: NaiveDateTime,
    pub items: serde_json::Value,
}

#[derive(Debug, sqlx::Type, Serialize, Deserialize)]
#[sqlx(type_name = "order_status", rename_all = "lowercase")]
pub enum OrderStatus {
    Pending,
    Paid,
    Confirmed,
    Preparing,
    Delivered,
    Cancelled,
}

#[derive(Clone)]
struct AppConfiguration {
    db_pool: Pool<Postgres>,
    jwt_secret: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub email: String,
    pub exp: usize,
    pub role: String,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: i64,
    pub email: String,
    pub name: String,
    pub password_hash: String,
    pub role: String,
    pub avatar: Option<String>,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct Product {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    pub price: Decimal,
    pub deleted_at: Option<NaiveDateTime>,
    pub created_at: NaiveDateTime,
    pub available: bool,
    pub image: String,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct Order {
    pub id: i64,
    pub user_id: i64,
    pub status: OrderStatus,
    pub total: Decimal,
    pub created_at: NaiveDateTime,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct OrderItem {
    pub id: i64,
    pub order_id: i64,
    pub product_id: i64,
    pub quantity: i64,
    pub created_at: NaiveDateTime,
}

#[derive(Deserialize)]
struct RegisterRequest {
    email: String,
    name: String,
    password: String,
}

#[derive(Deserialize)]
struct LoginRequest {
    email: String,
    password: String,
}

#[derive(Serialize)]
struct LoginResponse {
    token: String,
    id: i64,
    name: String,
}

#[derive(Deserialize)]
pub struct OrderRequest {
    pub product_id: i64,
    pub quantity: i64,
}

impl FromRequest for Claims {
    type Error = actix_web::Error;
    type Future = Ready<Result<Self, Self::Error>>;

    fn from_request(req: &HttpRequest, _: &mut Payload) -> Self::Future {
        let config = match req.app_data::<Data<AppConfiguration>>() {
            Some(c) => c,
            None => {
                return ready(Err(error::ErrorInternalServerError(
                    "Configuration missing",
                )));
            }
        };
        let auth_header = req
            .headers()
            .get("Authorization")
            .and_then(|h| h.to_str().ok());

        if let Some(header) = auth_header {
            if header.starts_with("Bearer ") {
                let token = &header[7..];
                return match decode::<Claims>(
                    token,
                    &DecodingKey::from_secret(config.jwt_secret.as_bytes()),
                    &Validation::default(),
                ) {
                    Ok(data) => ready(Ok(data.claims)),
                    Err(_) => ready(Err(error::ErrorUnauthorized("Invalid token"))),
                };
            }
        }
        ready(Err(error::ErrorUnauthorized("Missing token")))
    }
}

#[post("/register")]
async fn register(
    config: Data<AppConfiguration>,
    form: web::Json<RegisterRequest>,
) -> Result<HttpResponse, AppError> {
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
            let exp = Utc::now()
                .checked_add_signed(Duration::hours(24))
                .ok_or_else(|| AppError::Internal("Time calculation error".into()))?
                .timestamp() as usize;

            let claims = Claims {
                email: u.email.clone(),
                exp,
                role: u.role.clone(),
            };

            let token = encode(
                &Header::default(),
                &claims,
                &EncodingKey::from_secret(config.jwt_secret.as_bytes()),
            )?;

            Ok(HttpResponse::Created().json(LoginResponse {
                token,
                id: u.id,
                name: u.name,
            }))
        }
        Err(e) => Err(AppError::Conflict(e.to_string())),
    }
}

#[post("/login")]
async fn login(
    config: Data<AppConfiguration>,
    form: web::Json<LoginRequest>,
) -> Result<HttpResponse, AppError> {
    let user = sqlx::query_as::<_, User>(
        "SELECT id, email, name, password_hash, role, avatar FROM users WHERE email = $1",
    )
    .bind(&form.email)
    .fetch_optional(&config.db_pool)
    .await?;

    if let Some(u) = user {
        if verify(&form.password, &u.password_hash)? {
            let exp = Utc::now()
                .checked_add_signed(Duration::hours(24))
                .ok_or_else(|| AppError::Internal("Time calculation error".into()))?
                .timestamp() as usize;

            let claims = Claims {
                email: u.email.clone(),
                exp,
                role: u.role.clone(),
            };

            let token = encode(
                &Header::default(),
                &claims,
                &EncodingKey::from_secret(config.jwt_secret.as_bytes()),
            )?;

            return Ok(HttpResponse::Ok().json(LoginResponse {
                token,
                id: u.id,
                name: u.name,
            }));
        }
    }

    Err(AppError::Unauthorized("Invalid credentials".into()))
}

#[post("/products")]
async fn insert_product(
    claims: Claims,
    config: Data<AppConfiguration>,
    mut payload: Multipart,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let mut name = String::new();
    let mut desc = String::new();
    let mut price = Decimal::ZERO;
    let mut avail = false;
    let mut img = String::new();

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
                    desc = String::from_utf8(chunk?.to_vec())
                        .map_err(|_| AppError::BadRequest("Invalid description UTF-8".into()))?;
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
            Some("image") => {
                let _ = fs::create_dir_all("uploads/").await;
                let file_name = Uuid::new_v4();
                let path = format!("uploads/{}.jpg", file_name);
                let mut f = File::create(&path).await?;

                while let Some(chunk) = field.next().await {
                    f.write_all(&chunk?).await?;
                }

                img = file_name.to_string();
            }
            _ => {}
        }
    }
    let res = sqlx::query_as!(
        Product,
        "INSERT INTO products (name, description, price, available, image) VALUES ($1, $2, $3, $4, $5) RETURNING *",
        name, desc, price, avail, img
    ).fetch_one(&config.db_pool).await?;

    Ok(HttpResponse::Created().json(res))
}

#[get("/products")]
async fn list_products(config: Data<AppConfiguration>) -> Result<HttpResponse, AppError> {
    let list = sqlx::query_as!(Product, "SELECT * FROM products")
        .fetch_all(&config.db_pool)
        .await?;
    Ok(HttpResponse::Ok().json(list))
}

#[post("/orders")]
async fn create_orders(
    claims: Claims,
    config: Data<AppConfiguration>,
    form: web::Json<Vec<OrderRequest>>,
) -> Result<HttpResponse, AppError> {
    let mut tx = config.db_pool.begin().await?;

    let user_row = sqlx::query("SELECT id FROM users WHERE email = $1")
        .bind(&claims.email)
        .fetch_optional(&mut *tx)
        .await?
        .ok_or_else(|| AppError::Unauthorized("User not found".into()))?;

    let user_id: i64 = user_row.get(0);

    let mut unique_p_ids: Vec<i64> = form.iter().map(|i| i.product_id).collect();
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

    let order_id = match sqlx::query!(
        "SELECT id FROM orders WHERE user_id = $1 AND status = 'pending'::order_status ORDER BY created_at DESC LIMIT 1",
        user_id
    )
    .fetch_optional(&mut *tx)
    .await? {
        Some(o) => o.id,
        None => {
            sqlx::query!(
                "INSERT INTO orders (user_id, status, total) VALUES ($1, 'pending', 0) RETURNING id",
                user_id
            )
            .fetch_one(&mut *tx)
            .await?
            .id
        }
    };

    for item in form.into_inner() {
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

    Ok(HttpResponse::Created().finish())
}

#[get("/orders")]
async fn order_history(
    claims: Claims,
    config: Data<AppConfiguration>,
    query: web::Query<OrderPagination>,
) -> Result<HttpResponse, AppError> {
    let limit = query.limit.unwrap_or(20).min(100);
    let last_id = query.last_id.unwrap_or(i64::MAX);

    let list = sqlx::query_as!(
        OrderHistoryResponse,
        r#"
        SELECT
            o.id,
            o.user_id,
            o.status as "status: OrderStatus",
            o.total,
            o.created_at,
            COALESCE(
                (SELECT jsonb_agg(item_data)
                 FROM (
                    SELECT
                        oi.id,
                        oi.product_id,
                        p.name as product_name,
                        oi.quantity,
                        oi.price_at_time
                    FROM order_items oi
                    JOIN products p ON oi.product_id = p.id
                    WHERE oi.order_id = o.id
                 ) item_data
                ), '[]'::jsonb
            ) as "items!"
        FROM orders o
        JOIN users u ON o.user_id = u.id
        WHERE u.email = $1
          AND o.id < $2
        ORDER BY o.id DESC
        LIMIT $3
        "#,
        claims.email,
        last_id,
        limit
    )
    .fetch_all(&config.db_pool)
    .await?;

    Ok(HttpResponse::Ok().json(list))
}

#[derive(Serialize, FromRow)]
pub struct MonthlyRevenue {
    pub year: i32,
    pub month: i32,
    pub order_count: i64,
    pub revenue: Decimal,
}

#[derive(Serialize, FromRow)]
pub struct YearlyRevenue {
    pub year: i32,
    pub order_count: i64,
    pub revenue: Decimal,
}

#[derive(Serialize)]
pub struct ProfileResponse {
    pub id: i64,
    pub email: String,
    pub name: String,
    pub role: String,
    pub avatar: Option<String>,
}

#[get("/profile")]
async fn get_profile(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    let row = sqlx::query("SELECT id, email, name, role, avatar FROM users WHERE email = $1")
        .bind(&claims.email)
        .fetch_optional(&config.db_pool)
        .await?
        .ok_or_else(|| AppError::Unauthorized("User not found".into()))?;

    Ok(HttpResponse::Ok().json(ProfileResponse {
        id: row.get(0),
        email: row.get(1),
        name: row.get(2),
        role: row.get(3),
        avatar: row.get(4),
    }))
}

#[get("/admin/revenue/monthly")]
async fn get_monthly_revenue(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let rows = sqlx::query_as::<_, MonthlyRevenue>(
        "SELECT year, month, order_count, revenue FROM monthly_revenue",
    )
    .fetch_all(&config.db_pool)
    .await?;

    Ok(HttpResponse::Ok().json(rows))
}

#[get("/admin/revenue/yearly")]
async fn get_yearly_revenue(
    claims: Claims,
    config: Data<AppConfiguration>,
) -> Result<HttpResponse, AppError> {
    if claims.role != "admin" {
        return Err(AppError::Forbidden("Admin access required".into()));
    }

    let rows =
        sqlx::query_as::<_, YearlyRevenue>("SELECT year, order_count, revenue FROM yearly_revenue")
            .fetch_all(&config.db_pool)
            .await?;

    Ok(HttpResponse::Ok().json(rows))
}

#[post("/profile/avatar")]
async fn upload_avatar(
    claims: Claims,
    config: Data<AppConfiguration>,
    mut payload: Multipart,
) -> Result<HttpResponse, AppError> {
    let mut avatar_filename = String::new();

    while let Some(item) = payload.next().await {
        let mut field = item?;
        let cd = field
            .content_disposition()
            .and_then(|c| c.get_name().map(|s| s.to_string()));

        if cd.as_deref() == Some("image") {
            fs::create_dir_all("uploads/").await?;
            let file_name = Uuid::new_v4();
            let path = format!("uploads/{}", file_name);

            let mut f = File::create(&path).await?;

            while let Some(chunk) = field.next().await {
                f.write_all(&chunk?).await?;
            }
            avatar_filename = file_name.to_string();
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

    Ok(HttpResponse::Ok().json(serde_json::json!({
        "avatar": avatar_filename
    })))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL error");
    let jwt_secret = std::env::var("JWT_SECRET").expect("JWT_SECRET error");

    let pool = PgPoolOptions::new()
        .connect(&database_url)
        .await
        .expect("DB connection error");

    let config = AppConfiguration {
        db_pool: pool,
        jwt_secret,
    };

    HttpServer::new(move || {
        App::new()
            .app_data(Data::new(config.clone()))
            .service(Files::new("/images", "./uploads"))
            .service(list_products)
            .service(insert_product)
            .service(register)
            .service(login)
            .service(create_orders)
            .service(order_history)
            .service(get_profile)
            .service(upload_avatar)
            .service(get_monthly_revenue)
            .service(get_yearly_revenue)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
