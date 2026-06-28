use actix_web::{HttpResponse, ResponseError};
use std::fmt;

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

impl From<jsonwebtoken::errors::Error> for AppError {
    fn from(e: jsonwebtoken::errors::Error) -> Self {
        AppError::Unauthorized(e.to_string())
    }
}

impl From<bcrypt::BcryptError> for AppError {
    fn from(e: bcrypt::BcryptError) -> Self {
        AppError::Internal(e.to_string())
    }
}

impl From<actix_multipart::MultipartError> for AppError {
    fn from(e: actix_multipart::MultipartError) -> Self {
        AppError::BadRequest(e.to_string())
    }
}

impl From<std::io::Error> for AppError {
    fn from(e: std::io::Error) -> Self {
        AppError::Internal(e.to_string())
    }
}
