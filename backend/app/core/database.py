import json
import os
from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

DATABASE_URL = settings.DATABASE_URL
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Handle sqlite specific arguments
connect_args = {}
if DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(DATABASE_URL, connect_args=connect_args, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db() -> Generator:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    Base.metadata.create_all(bind=engine)
    from app.models.scheme import Scheme
    from app.models.user import User
    from app.core.security import get_password_hash
    db = SessionLocal()
    try:
        # Seed default demo user if not exists
        demo_user = db.query(User).filter(User.phone == "9876543210").first()
        if not demo_user:
            user = User(
                phone="9876543210",
                email="demo@schememate.ai",
                hashed_password=get_password_hash("123456"),
                full_name="Demo Entrepreneur",
                is_verified=True
            )
            db.add(user)
            db.commit()

        # Seed data if schemes table empty
        count = db.query(Scheme).count()
        if count == 0:
            seed_path = os.path.join(os.path.dirname(__file__), "../../data/seed_schemes.json")
            if os.path.exists(seed_path):
                with open(seed_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    for item in data:
                        scheme = Scheme(
                            id=item["id"],
                            scheme_name=item["scheme_name"],
                            ministry=item["ministry"],
                            department=item.get("department", ""),
                            description=item.get("description", ""),
                            scheme_type=item.get("scheme_type", ""),
                            target_beneficiary=item.get("target_beneficiary", ""),
                            benefits=item.get("benefits", ""),
                            application_method=item.get("application_method", ""),
                            official_application_url=item.get("official_application_url", ""),
                            official_source_url=item.get("official_source_url", ""),
                            state=item.get("state", "All India"),
                            status=item.get("status", "Active"),
                            version=item.get("version", 1),
                            last_verified=item.get("last_verified", "2026-08-01"),
                            eligibility_rules=json.dumps(item.get("eligibility_rules", {})),
                            required_documents=json.dumps(item.get("required_documents", []))
                        )
                        db.add(scheme)
                    db.commit()
    except Exception as e:
        print(f"Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()
