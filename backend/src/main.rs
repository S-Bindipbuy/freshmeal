mod entities;
use actix_files::Files;
use actix_multipart::Multipart;
use actix_web::web::Data;
use actix_web::{App, HttpRequest, HttpResponse, HttpServer, Responder, get, post, web};
use bcrypt::{DEFAULT_COST, hash, verify};
use chrono::{Duration, Utc};
use entities::{orders, products, users};
use futures_util::StreamExt as _;
use jsonwebtoken::{DecodingKey, EncodingKey, Header, Validation, decode, encode};
use rust_decimal::Decimal;
use rust_decimal::prelude::FromPrimitive;
use sea_orm::{ActiveModelTrait, ColumnTrait, QueryFilter, Set};
use sea_orm::{Database, EntityTrait};
use serde::{Deserialize, Serialize};
use tokio::fs::{self, File};
use tokio::io::AsyncWriteExt;
use uuid::Uuid;

#[derive(Deserialize)]
pub struct OrderRequest {
    pub product_id: i32,
    pub quantity: i32,
}

#[post("/orders")]
async fn create_orders(
    req: HttpRequest,
    db: web::Data<sea_orm::DatabaseConnection>,
    form: web::Json<Vec<OrderRequest>>,
) -> impl Responder {
    match validate_token(
        req.headers()
            .get("Authorization")
            .and_then(|h| h.to_str().ok()),
    ) {
        Ok(claims) => {
            let user = users::Entity::find()
                .filter(users::Column::Email.eq(claims.sub.clone()))
                .one(db.get_ref())
                .await;

            if let Ok(Some(user)) = user {
                let mut created_orders = Vec::new();

                for item in form.iter() {
                    if let Ok(Some(product)) = products::Entity::find_by_id(item.product_id)
                        .one(db.get_ref())
                        .await
                    {
                        if !product.available {
                            return HttpResponse::BadRequest()
                                .body(format!("Product {} not available", product.id));
                        }

                        let total = product.price * Decimal::from(item.quantity);

                        let new_order = orders::ActiveModel {
                            user_id: Set(user.id),
                            product_id: Set(product.id),
                            quantity: Set(item.quantity),
                            total: Set(total),
                            status: Set("pending".to_string()),
                            ..Default::default()
                        };

                        match new_order.insert(db.get_ref()).await {
                            Ok(order) => created_orders.push(order),
                            Err(err) => {
                                return HttpResponse::InternalServerError()
                                    .body(format!("Insert failed: {}", err));
                            }
                        }
                    } else {
                        return HttpResponse::BadRequest()
                            .body(format!("Product {} not found", item.product_id));
                    }
                }

                HttpResponse::Created().json(created_orders)
            } else {
                HttpResponse::Unauthorized().body("User not found")
            }
        }
        Err(resp) => resp,
    }
}

#[get("/orders")]
async fn order_history(
    req: HttpRequest,
    db: web::Data<sea_orm::DatabaseConnection>,
) -> impl Responder {
    match validate_token(
        req.headers()
            .get("Authorization")
            .and_then(|h| h.to_str().ok()),
    ) {
        Ok(claims) => {
            let user = users::Entity::find()
                .filter(users::Column::Email.eq(&claims.sub))
                .one(db.get_ref())
                .await;
            if let Ok(Some(user)) = user {
                let orders_list: Vec<orders::Model> = orders::Entity::find()
                    .filter(orders::Column::UserId.eq(user.id))
                    .all(db.get_ref())
                    .await
                    .unwrap_or_default();
                HttpResponse::Ok().json(orders_list)
            } else {
                HttpResponse::Unauthorized().body("User not found")
            }
        }
        Err(resp) => resp,
    }
}

#[derive(Deserialize)]
struct LoginRequest {
    email: String,
    password: String,
}

#[derive(Deserialize, Serialize)]
struct LoginResponse {
    token: String,
    id: i32,
    email: String,
    name: String,
    role: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String,
    exp: usize,
    role: String,
}

fn validate_token(auth_header: Option<&str>) -> Result<Claims, HttpResponse> {
    if let Some(header) = auth_header {
        if header.starts_with("Bearer ") {
            let token = &header[7..];
            let secret = dotenvy::var("JWT_SECRET").unwrap_or_else(|_| "mysecret".into());
            let validation = Validation::default();
            match decode::<Claims>(
                token,
                &DecodingKey::from_secret(secret.as_ref()),
                &validation,
            ) {
                Ok(data) => return Ok(data.claims),
                Err(_) => return Err(HttpResponse::Unauthorized().body("Invalid token")),
            }
        }
    }
    Err(HttpResponse::Unauthorized().body("Missing token"))
}

#[post("/login")]
async fn login(
    db: Data<sea_orm::DatabaseConnection>,
    form: web::Json<LoginRequest>,
) -> impl Responder {
    let user = users::Entity::find()
        .filter(users::Column::Email.eq(&form.email))
        .one(db.get_ref())
        .await;

    match user {
        Ok(Some(model)) => {
            if verify(&form.password, &model.password_hash).unwrap_or(false) {
                let expiration = Utc::now()
                    .checked_add_signed(Duration::hours(24))
                    .expect("valid timestamp")
                    .timestamp() as usize;

                let claims = Claims {
                    sub: model.email.clone(),
                    exp: expiration,
                    role: model.role.clone(),
                };

                let secret = dotenvy::var("JWT_SECRET").unwrap_or_else(|_| "mysecret".into());
                let token = encode(
                    &Header::default(),
                    &claims,
                    &EncodingKey::from_secret(secret.as_ref()),
                )
                .unwrap();

                let response = LoginResponse {
                    token,
                    id: model.id,
                    email: model.email,
                    name: model.name,
                    role: model.role,
                };
                HttpResponse::Ok().json(response)
            } else {
                HttpResponse::Unauthorized().body("Invalid credentials")
            }
        }
        Ok(_) => HttpResponse::Unauthorized().body("Invalid credentials"),
        Err(err) => HttpResponse::InternalServerError().body(format!("Query failed: {}", err)),
    }
}

#[post("/products")]
async fn insert_product(
    db: web::Data<sea_orm::DatabaseConnection>,
    mut payload: Multipart,
) -> impl Responder {
    let mut name = String::new();
    let mut description = String::new();
    let mut price = 0.0;
    let mut available = false;
    let mut image: Option<String> = None;
    while let Some(item) = payload.next().await {
        if let Ok(mut field) = item {
            if let Some(field_name) = field.content_disposition().unwrap().get_name() {
                if field_name == "name" {
                    if let Some(Ok(bytes)) = field.next().await {
                        name = String::from_utf8(bytes.to_vec()).unwrap();
                    }
                } else if field_name == "description" {
                    if let Some(Ok(bytes)) = field.next().await {
                        description = String::from_utf8(bytes.to_vec()).unwrap();
                    }
                } else if field_name == "price" {
                    if let Some(Ok(bytes)) = field.next().await {
                        price = String::from_utf8(bytes.to_vec()).unwrap().parse().unwrap();
                    }
                } else if field_name == "available" {
                    if let Some(Ok(bytes)) = field.next().await {
                        available = String::from_utf8(bytes.to_vec()).unwrap() == "true";
                    }
                } else if field_name == "image" {
                    match fs::create_dir("uploads/").await {
                        Ok(_) => println!("Created"),
                        Err(ref e) if e.kind() == std::io::ErrorKind::AlreadyExists => {}
                        Err(e) => return Err(e),
                    };
                    let filename = format!("uploads/{}.jpg", Uuid::new_v4());
                    let mut f = File::create(&filename).await.unwrap();
                    while let Some(Ok(chunk)) = field.next().await {
                        f.write_all(&chunk).await.unwrap();
                    }
                    image = Some(filename);
                }
            }
        }
    }
    let image = match image {
        Some(path) => path,
        None => return Ok(HttpResponse::BadRequest().body("Field image is missing")),
    };
    let new = products::ActiveModel {
        name: Set(name),
        description: Set(Some(description)),
        price: Set(sea_orm::prelude::Decimal::from_f64(price).unwrap()),
        available: Set(available),
        image: Set(image),
        ..Default::default()
    };
    match new.insert(db.get_ref()).await {
        Ok(model) => Ok(HttpResponse::Created().json(model)),
        Err(err) => Ok(HttpResponse::InternalServerError().body(format!("Insert failed: {}", err))),
    }
}

#[get("/products")]
async fn list_products(db: Data<sea_orm::DatabaseConnection>) -> impl Responder {
    let products_list: Vec<products::Model> = products::Entity::find()
        .all(db.get_ref())
        .await
        .expect("Query failed");

    HttpResponse::Ok().json(products_list)
}

#[derive(Deserialize)]
struct RegisterRequest {
    role: String,
    email: String,
    name: String,
    password: String,
}

#[post("/register")]
async fn register(
    db: Data<sea_orm::DatabaseConnection>,
    form: web::Json<RegisterRequest>,
) -> impl Responder {
    let hashed = hash(&form.password, DEFAULT_COST).unwrap();

    let user = users::ActiveModel {
        email: Set(form.email.clone()),
        name: Set(form.name.clone()),
        password_hash: Set(hashed),
        role: Set(form.role.clone()),
        ..Default::default()
    };

    match user.insert(db.get_ref()).await {
        Ok(model) => {
            let secret = dotenvy::var("JWT_SECRET").unwrap_or_else(|_| "mysecret".into());
            let expiration = Utc::now()
                .checked_add_signed(Duration::hours(24))
                .expect("valid timestamp")
                .timestamp() as usize;

            let claims = Claims {
                sub: model.email.clone(),
                exp: expiration,
                role: model.role.clone(),
            };

            let token = encode(
                &Header::default(),
                &claims,
                &EncodingKey::from_secret(secret.as_ref()),
            )
            .unwrap();

            let response = LoginResponse {
                token,
                id: model.id,
                email: model.email,
                name: model.name,
                role: model.role,
            };
            HttpResponse::Created().json(response)
        }
        Err(message) => HttpResponse::InternalServerError().body(message.to_string()),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let database_url = dotenvy::var("database_url").unwrap();
    let db = Database::connect(database_url)
        .await
        .expect("Failed to connect to Postgres");

    HttpServer::new(move || {
        App::new()
            .app_data(Data::new(db.clone()))
            .service(Files::new("/images", "./uploads"))
            .service(list_products)
            .service(insert_product)
            .service(register)
            .service(login)
            .service(create_orders)
            .service(order_history)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
