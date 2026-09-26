import time
from pathlib import Path
from sqlalchemy import text
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.core.config import settings
from app.core.database import init_db, engine
from app.core.mongodb import init_mongodb, close_mongodb, get_mongodb
from app.security.middleware import SecurityHeadersMiddleware, RateLimitMiddleware, global_exception_handler
from app.api.v1 import auth, profile, schemes, matching, documents, action_plan, sync, notifications, admin, financial_calculator, partner_locator, voice, assistant

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="AI-Driven Scheme Matching & Assistance System for Marginalized Entrepreneurs (SIH Solution)"
)

# 1. Security Headers & Rate Limiting Middleware
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(RateLimitMiddleware, max_requests=120, window_seconds=60)

# 2. CORS Middleware (Added last so it wraps and intercepts all requests first)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Global Exception Handler
app.add_exception_handler(Exception, global_exception_handler)

# 4. Include V1 Routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(profile.router, prefix=settings.API_V1_STR)
app.include_router(schemes.router, prefix=settings.API_V1_STR)
app.include_router(matching.router, prefix=settings.API_V1_STR)
app.include_router(documents.router, prefix=settings.API_V1_STR)
app.include_router(action_plan.router, prefix=settings.API_V1_STR)
app.include_router(sync.router, prefix=settings.API_V1_STR)  
app.include_router(notifications.router, prefix=settings.API_V1_STR)
app.include_router(admin.router, prefix=settings.API_V1_STR)
app.include_router(financial_calculator.router, prefix=settings.API_V1_STR)
app.include_router(partner_locator.router, prefix=settings.API_V1_STR)
app.include_router(voice.router, prefix=settings.API_V1_STR)
app.include_router(assistant.router, prefix=settings.API_V1_STR)

@app.on_event("startup")
def startup_event():
    init_db()
    init_mongodb()

@app.on_event("shutdown")
def shutdown_event():
    close_mongodb()

@app.get("/health")
def health_check():
    database_status = "connected"
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except Exception:
        database_status = "unavailable"

    mongo_status = "connected" if get_mongodb() is not None else "unavailable"
    return {
        "status": "healthy" if database_status == "connected" else "unhealthy",
        "timestamp": time.time(),
        "database": database_status,
        "mongodb": mongo_status
    }

@app.get("/ready")
def readiness_check():
    health = health_check()
    if health["database"] != "connected":
        return {"status": "not_ready", "checks": health}
    return {"status": "ready", "checks": health}

web_assets = Path(__file__).resolve().parent / "static"
if web_assets.is_dir():
    app.mount("/", StaticFiles(directory=web_assets, html=True), name="web")
else:
    @app.get("/")
    def root():
        return {
            "status": "online",
            "system": settings.PROJECT_NAME,
            "version": settings.VERSION,
            "docs_url": "/docs",
            "api_v1_base": settings.API_V1_STR
        }
