use chrono::NaiveDateTime;
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, Type};

#[derive(Deserialize)]
pub struct OrderHistoryQuery {
    pub last_id: Option<i64>,
    pub limit: Option<i64>,
}

#[derive(Debug, Type, Serialize, Deserialize)]
#[sqlx(type_name = "order_status", rename_all = "lowercase")]
pub enum OrderStatus {
    Pending,
    Paid,
    Confirmed,
    Preparing,
    Delivered,
    Cancelled,
}

#[derive(Debug, Type, Serialize, Deserialize, Clone)]
#[sqlx(type_name = "role", rename_all = "lowercase")]
pub enum Role {
    Admin,
    Customer,
    Restaurant,
}

impl std::fmt::Display for Role {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Role::Admin => write!(f, "admin"),
            Role::Customer => write!(f, "customer"),
            Role::Restaurant => write!(f, "restaurant"),
        }
    }
}

#[derive(Clone)]
pub struct AppConfiguration {
    pub db_pool: sqlx::Pool<sqlx::Postgres>,
    pub jwt_secret: String,
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
    pub role: Role,
    pub avatar: Option<String>,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct DbProduct {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    pub price: Decimal,
    pub category_id: Option<i64>,
    pub deleted_at: Option<NaiveDateTime>,
    pub created_at: NaiveDateTime,
    pub available: bool,
    pub image: String,
}

#[derive(Serialize, FromRow)]
pub struct DbCategory {
    pub id: i64,
    pub name: String,
    pub description: Option<String>,
    pub created_at: NaiveDateTime,
}

#[derive(FromRow)]
pub struct OrderItemDb {
    pub order_id: i64,
    pub id: i64,
    pub product_id: i64,
    pub product_name: String,
    pub quantity: i32,
    pub price_at_time: Decimal,
}

#[derive(FromRow)]
pub struct OrderHistoryRow {
    pub id: i64,
    pub user_id: i64,
    pub status: OrderStatus,
    pub total: Decimal,
    pub created_at: NaiveDateTime,
    pub branch_id: Option<i64>,
    pub user_name: String,
}

#[derive(Serialize, FromRow)]
pub struct DbCustomer {
    pub id: i64,
    pub name: String,
    pub email: String,
    pub created_at: NaiveDateTime,
}

#[derive(FromRow)]
pub struct DbMonthlyRevenue {
    pub year: i32,
    pub month: i32,
    pub order_count: i64,
    pub revenue: Decimal,
}

#[derive(FromRow)]
pub struct DbYearlyRevenue {
    pub year: i32,
    pub order_count: i64,
    pub revenue: Decimal,
}

#[derive(Serialize, Deserialize, FromRow)]
pub struct DbBranch {
    pub id: i64,
    pub name: String,
    pub address: String,
    pub lat: f64,
    pub lng: f64,
    pub created_at: chrono::NaiveDateTime,
}

#[derive(Deserialize)]
pub struct NearestBranchQuery {
    pub lat: f64,
    pub lng: f64,
}

#[derive(Deserialize)]
pub struct ProductQuery {
    pub search: Option<String>,
    pub category_id: Option<i64>,
}

#[derive(Deserialize)]
pub struct CatQuery {
    pub search: Option<String>,
}

#[derive(Deserialize)]
pub struct UpdateCartItemBody {
    pub quantity: i32,
}

#[derive(Deserialize)]
pub struct UpdateOrderStatusBody {
    pub status: OrderStatus,
}
