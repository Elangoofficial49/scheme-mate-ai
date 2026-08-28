import os
from typing import Optional
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from pymongo import MongoClient
from app.core.config import settings
from app.core.logging import logger

class MongoDBManager:
    client: Optional[AsyncIOMotorClient] = None
    db: Optional[AsyncIOMotorDatabase] = None
    sync_client: Optional[MongoClient] = None

mongo_manager = MongoDBManager()

def init_mongodb():
    """
    Initialize MongoDB connection using MONGODB_URL from environment / config.
    Supports both local MongoDB (mongodb://localhost:27017) and MongoDB Atlas (mongodb+srv://...)
    """
    mongo_url = os.getenv("MONGODB_URL", settings.MONGODB_URL)
    db_name = os.getenv("MONGODB_DB_NAME", settings.MONGODB_DB_NAME)

    if not mongo_url:
        logger.info("No MONGODB_URL configured. MongoDB integration is skipped.")
        return

    try:
        # 1. Initialize Async Motor client for FastAPI routes
        mongo_manager.client = AsyncIOMotorClient(
            mongo_url,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
        )
        mongo_manager.db = mongo_manager.client[db_name]

        # 2. Initialize Sync PyMongo client for background tasks/scripts
        mongo_manager.sync_client = MongoClient(
            mongo_url,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
        )

        # 3. Ping the database to verify active connection
        mongo_manager.sync_client.admin.command('ping')
        logger.info(f"✅ Successfully connected to MongoDB database: '{db_name}'")
    except Exception as e:
        logger.warning(f"⚠ MongoDB connection notice: {e}. Running in graceful fallback mode.")

def get_mongodb() -> Optional[AsyncIOMotorDatabase]:
    """Dependency / helper to get async MongoDB database instance."""
    return mongo_manager.db

def get_mongo_collection(collection_name: str):
    """Helper to get a specific MongoDB collection."""
    if mongo_manager.db is not None:
        return mongo_manager.db[collection_name]
    return None

def close_mongodb():
    """Close MongoDB connections cleanly on application shutdown."""
    if mongo_manager.client:
        mongo_manager.client.close()
    if mongo_manager.sync_client:
        mongo_manager.sync_client.close()
    logger.info("MongoDB connection closed.")
