mod proto {
    include!(concat!(env!("OUT_DIR"), "/freshmeal.rs"));
}

mod auth;
mod error;
mod handlers;
mod models;
mod utils;

use actix_files::Files;
use actix_web::web::Data;
use actix_web::{App, HttpServer};
use sqlx::postgres::PgPoolOptions;

use crate::handlers::*;
use crate::models::AppConfiguration;

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
            .service(update_product)
            .service(delete_product)
            .service(register)
            .service(login)
            .service(create_orders)
            .service(order_history)
            .service(cancel_order)
            .service(checkout_order)
            .service(update_cart_item)
            .service(update_order_status)
            .service(get_profile)
            .service(get_customers)
            .service(upload_avatar)
            .service(get_monthly_revenue)
            .service(get_yearly_revenue)
            .service(list_categories)
            .service(create_category)
            .service(update_category)
            .service(delete_category)
            .service(list_branches)
            .service(get_nearest_branch)
            .service(create_branch)
            .service(update_branch)
            .service(delete_branch)
            .service(toggle_product_availability)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
