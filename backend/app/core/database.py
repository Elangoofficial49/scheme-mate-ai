import json
import os
from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

DATABASE_URL = settings.DATABASE_URL
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Handle sqlite specific arguments and ensure consistent canonical path
connect_args = {}
if DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}
    if ":///" in DATABASE_URL:
        db_raw = DATABASE_URL.split(":///", 1)[1]
        if not os.path.isabs(db_raw):
            backend_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            canonical_db = os.path.normpath(os.path.join(backend_dir, os.path.basename(db_raw)))
            DATABASE_URL = f"sqlite:///{canonical_db}"

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
    import app.models
    Base.metadata.create_all(bind=engine)
    try:
        from sqlalchemy import text
        with engine.connect() as conn:
            conn.execute(text("ALTER TABLE entrepreneur_profiles ADD COLUMN certificate_number VARCHAR"))
            conn.commit()
    except Exception:
        pass

    from app.models.scheme import Scheme
    from app.models.user import User
    from app.core.security import get_password_hash
    db = SessionLocal()
    try:
        # Seed default demo user if not exists
        ramesh_user = db.query(User).filter(User.email == "ramesh@example.com").first()
        if not ramesh_user:
            user = User(
                phone="9876543210",
                email="ramesh@example.com",
                hashed_password=get_password_hash("123456"),
                full_name="Ramesh Kumar",
                is_verified=True
            )
            db.add(user)
            try:
                db.commit()
            except Exception:
                db.rollback()

        # Sync existing registered users from MongoDB Atlas
        try:
            from app.core.mongodb import mongo_manager, init_mongodb
            if mongo_manager.sync_client is None:
                init_mongodb()
            if mongo_manager.sync_client is not None:
                sync_db = mongo_manager.sync_client[settings.MONGODB_DB_NAME]
                mongo_users = list(sync_db["users"].find({}))
                for m_user in mongo_users:
                    m_email = m_user.get("email")
                    if m_email and "hashed_password" in m_user:
                        existing = db.query(User).filter(User.email == m_email.lower()).first()
                        if not existing:
                            synced_u = User(
                                id=m_user.get("id", str(os.urandom(16).hex())),
                                phone=m_user.get("phone", "0000000000"),
                                email=m_email.lower(),
                                aadhaar_number=m_user.get("aadhaar_number"),
                                hashed_password=m_user["hashed_password"],
                                full_name=m_user.get("full_name", "Entrepreneur"),
                                is_active=bool(m_user.get("is_active", 1)),
                                is_verified=bool(m_user.get("is_verified", 1))
                            )
                            db.add(synced_u)
                db.commit()
        except Exception as sync_err:
            pass

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
