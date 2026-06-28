use crate::error::AppError;
use crate::models::*;
use crate::proto;
use actix_web::HttpResponse;
use bytes::Bytes;
use prost::Message;

pub fn db_role_to_proto(r: &Role) -> i32 {
    match r {
        Role::Admin => proto::Role::Admin as i32,
        Role::Customer => proto::Role::Customer as i32,
        Role::Restaurant => proto::Role::Restaurant as i32,
    }
}

pub fn db_status_to_proto(s: &OrderStatus) -> i32 {
    match s {
        OrderStatus::Pending => proto::OrderStatus::Pending as i32,
        OrderStatus::Paid => proto::OrderStatus::Paid as i32,
        OrderStatus::Confirmed => proto::OrderStatus::Confirmed as i32,
        OrderStatus::Preparing => proto::OrderStatus::Preparing as i32,
        OrderStatus::Delivered => proto::OrderStatus::Delivered as i32,
        OrderStatus::Cancelled => proto::OrderStatus::Cancelled as i32,
    }
}

pub fn encode_proto<T: Message>(msg: &T) -> HttpResponse {
    let mut buf = Vec::new();
    msg.encode(&mut buf).expect("protobuf encoding failed");
    HttpResponse::Ok()
        .insert_header(("Content-Type", "application/x-protobuf"))
        .body(buf)
}

pub fn encode_proto_status<T: Message>(
    msg: &T,
    status: actix_web::http::StatusCode,
) -> HttpResponse {
    let mut buf = Vec::new();
    msg.encode(&mut buf).expect("protobuf encoding failed");
    HttpResponse::build(status)
        .insert_header(("Content-Type", "application/x-protobuf"))
        .body(buf)
}

pub fn decode_proto<T: Message + Default>(body: &Bytes) -> Result<T, AppError> {
    T::decode(body.as_ref()).map_err(|e| AppError::BadRequest(e.to_string()))
}

pub fn make_jwt(email: &str, role: &str, secret: &str) -> Result<String, AppError> {
    use chrono::{Duration, Utc};
    use jsonwebtoken::{EncodingKey, Header, encode};

    let exp = Utc::now()
        .checked_add_signed(Duration::hours(24))
        .ok_or_else(|| AppError::Internal("Time calculation error".into()))?
        .timestamp() as usize;

    let claims = Claims {
        email: email.to_string(),
        exp,
        role: role.to_string(),
    };

    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )
    .map_err(AppError::from)
}

pub fn login_response(user: &User, secret: &str) -> Result<proto::LoginResponse, AppError> {
    let token = make_jwt(&user.email, &user.role.to_string(), secret)?;
    Ok(proto::LoginResponse {
        token,
        id: user.id,
        name: user.name.clone(),
    })
}

impl From<DbBranch> for proto::Branch {
    fn from(b: DbBranch) -> Self {
        proto::Branch {
            id: b.id,
            name: b.name,
            address: b.address,
            lat: b.lat,
            lng: b.lng,
            created_at: b.created_at.to_string(),
        }
    }
}

// ── From impls for proto types ──

impl From<DbCategory> for proto::Category {
    fn from(c: DbCategory) -> Self {
        proto::Category {
            id: c.id,
            name: c.name,
            description: c.description,
            created_at: c.created_at.to_string(),
        }
    }
}

impl From<DbProduct> for proto::Product {
    fn from(p: DbProduct) -> Self {
        proto::Product {
            id: p.id,
            name: p.name,
            description: p.description,
            price: format!("{:.2}", p.price.round_dp(2)),
            category_id: p.category_id,
            deleted_at: p.deleted_at.map(|d| d.to_string()),
            created_at: p.created_at.to_string(),
            available: p.available,
            image: p.image,
        }
    }
}

impl From<DbCustomer> for proto::CustomerResponse {
    fn from(c: DbCustomer) -> Self {
        proto::CustomerResponse {
            id: c.id,
            name: c.name,
            email: c.email,
            created_at: c.created_at.to_string(),
        }
    }
}

impl From<DbMonthlyRevenue> for proto::MonthlyRevenue {
    fn from(r: DbMonthlyRevenue) -> Self {
        proto::MonthlyRevenue {
            year: r.year,
            month: r.month,
            order_count: r.order_count,
            revenue: format!("{:.2}", r.revenue.round_dp(2)),
        }
    }
}

impl From<DbYearlyRevenue> for proto::YearlyRevenue {
    fn from(r: DbYearlyRevenue) -> Self {
        proto::YearlyRevenue {
            year: r.year,
            order_count: r.order_count,
            revenue: format!("{:.2}", r.revenue.round_dp(2)),
        }
    }
}
