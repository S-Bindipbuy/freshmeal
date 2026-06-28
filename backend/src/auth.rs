use actix_web::dev::Payload;
use actix_web::web::Data;
use actix_web::{FromRequest, HttpRequest, error};
use jsonwebtoken::{DecodingKey, Validation, decode};
use std::future::{Ready, ready};

use crate::models::{AppConfiguration, Claims};

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
                let result = decode::<Claims>(
                    token,
                    &DecodingKey::from_secret(config.jwt_secret.as_bytes()),
                    &Validation::default(),
                );
                return match result {
                    Ok(data) => ready(Ok(data.claims)),
                    Err(_) => ready(Err(error::ErrorUnauthorized("Invalid token"))),
                };
            }
        }
        ready(Err(error::ErrorUnauthorized("Missing token")))
    }
}
