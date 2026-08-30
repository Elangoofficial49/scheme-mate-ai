import os
import pytest

os.environ["DATABASE_URL"] = "sqlite:///./test_schememate.db"

from app.core.database import Base, engine, init_db

@pytest.fixture(autouse=True)
def reset_db():
    Base.metadata.drop_all(bind=engine)
    init_db()
    yield
