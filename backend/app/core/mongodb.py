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

def sync_save_to_mongodb(collection_name: str, data: dict, query_filter: Optional[dict] = None):
    """
    Synchronously save or update a document in MongoDB Atlas automatically.
    """
    try:
        if mongo_manager.sync_client is None:
            init_mongodb()
        
        if mongo_manager.sync_client is not None:
            db_name = os.getenv("MONGODB_DB_NAME", settings.MONGODB_DB_NAME)
            db = mongo_manager.sync_client[db_name]
            coll = db[collection_name]
            
            clean_data = {k: v for k, v in data.items() if not k.startswith('_sa_')}
            if query_filter:
                coll.update_one(query_filter, {"$set": clean_data}, upsert=True)
            else:
                coll.insert_one(clean_data)
            logger.info(f"✅ Automatically synced document to MongoDB Atlas [{collection_name}]")
    except Exception as e:
        logger.warning(f"⚠ Automatic MongoDB sync notice: {e}")

async def async_save_to_mongodb(collection_name: str, data: dict, query_filter: Optional[dict] = None):
    """
    Asynchronously save or update a document in MongoDB Atlas automatically.
    """
    try:
        if mongo_manager.db is not None:
            coll = mongo_manager.db[collection_name]
            clean_data = {k: v for k, v in data.items() if not k.startswith('_sa_')}
            if query_filter:
                await coll.update_one(query_filter, {"$set": clean_data}, upsert=True)
            else:
                await coll.insert_one(clean_data)
            logger.info(f"✅ Automatically synced async document to MongoDB Atlas [{collection_name}]")
    except Exception as e:
        logger.warning(f"⚠ Automatic async MongoDB sync notice: {e}")

def close_mongodb():
    """Close MongoDB connections cleanly on application shutdown."""
    if mongo_manager.client:
        mongo_manager.client.close()
    if mongo_manager.sync_client:
        mongo_manager.sync_client.close()
    logger.info("MongoDB connection closed.")

