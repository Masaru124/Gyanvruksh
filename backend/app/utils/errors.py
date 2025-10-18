"""
Standardized error response handling for the EduConnect API
"""
from fastapi import HTTPException, status
from typing import Optional, Dict, Any
import json


class APIError(Exception):
    """Base API error class"""

    def __init__(
        self,
        message: str,
        error_code: str,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        details: Optional[Dict[str, Any]] = None
    ):
        self.message = message
        self.error_code = error_code
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)


class ValidationError(APIError):
    """Validation error for invalid input data"""

    def __init__(self, message: str = "Invalid input data", details: Optional[Dict[str, Any]] = None):
        super().__init__(
            message=message,
            error_code="VALIDATION_ERROR",
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            details=details
        )


class AuthenticationError(APIError):
    """Authentication error for invalid credentials or missing auth"""

    def __init__(self, message: str = "Authentication failed"):
        super().__init__(
            message=message,
            error_code="AUTHENTICATION_ERROR",
            status_code=status.HTTP_401_UNAUTHORIZED
        )


class AuthorizationError(APIError):
    """Authorization error for insufficient permissions"""

    def __init__(self, message: str = "Insufficient permissions"):
        super().__init__(
            message=message,
            error_code="AUTHORIZATION_ERROR",
            status_code=status.HTTP_403_FORBIDDEN
        )


class NotFoundError(APIError):
    """Resource not found error"""

    def __init__(self, resource: str = "Resource"):
        super().__init__(
            message=f"{resource} not found",
            error_code="NOT_FOUND",
            status_code=status.HTTP_404_NOT_FOUND
        )


class ConflictError(APIError):
    """Conflict error for duplicate resources or constraint violations"""

    def __init__(self, message: str = "Resource conflict"):
        super().__init__(
            message=message,
            error_code="CONFLICT",
            status_code=status.HTTP_409_CONFLICT
        )


class RateLimitError(APIError):
    """Rate limiting error"""

    def __init__(self, message: str = "Rate limit exceeded"):
        super().__init__(
            message=message,
            error_code="RATE_LIMIT_EXCEEDED",
            status_code=status.HTTP_429_TOO_MANY_REQUESTS
        )


def create_error_response(error: APIError) -> Dict[str, Any]:
    """Create standardized error response"""
    response = {
        "success": False,
        "error": {
            "message": error.message,
            "code": error.error_code,
            "type": error.__class__.__name__
        }
    }

    if error.details:
        response["error"]["details"] = error.details

    return response


def handle_api_error(error: APIError) -> HTTPException:
    """Convert APIError to HTTPException"""
    return HTTPException(
        status_code=error.status_code,
        detail=create_error_response(error)
    )


# Convenience functions for common error patterns
def validation_error(message: str = "Invalid input data", details: Optional[Dict[str, Any]] = None) -> HTTPException:
    """Create validation error"""
    error = ValidationError(message, details)
    return handle_api_error(error)


def auth_error(message: str = "Authentication failed") -> HTTPException:
    """Create authentication error"""
    error = AuthenticationError(message)
    return handle_api_error(error)


def authz_error(message: str = "Insufficient permissions") -> HTTPException:
    """Create authorization error"""
    error = AuthorizationError(message)
    return handle_api_error(error)


def not_found_error(resource: str = "Resource") -> HTTPException:
    """Create not found error"""
    error = NotFoundError(resource)
    return handle_api_error(error)


def conflict_error(message: str = "Resource conflict") -> HTTPException:
    """Create conflict error"""
    error = ConflictError(message)
    return handle_api_error(error)


def rate_limit_error(message: str = "Rate limit exceeded") -> HTTPException:
    """Create rate limit error"""
    error = RateLimitError(message)
    return handle_api_error(error)


# Custom exception handler for FastAPI
def custom_http_exception_handler(request, exc: HTTPException):
    """Custom HTTP exception handler that standardizes error responses"""
    from fastapi.responses import JSONResponse

    if isinstance(exc.detail, dict) and "error" in exc.detail:
        # Already in standardized format
        return JSONResponse(
            status_code=exc.status_code,
            content=exc.detail
        )

    # Convert to standardized format
    error_response = {
        "success": False,
        "error": {
            "message": exc.detail if isinstance(exc.detail, str) else "An error occurred",
            "code": f"HTTP_{exc.status_code}",
            "type": "HTTPException"
        }
    }

    return JSONResponse(
        status_code=exc.status_code,
        content=error_response
    )
