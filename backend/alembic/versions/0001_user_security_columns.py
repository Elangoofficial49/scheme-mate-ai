"""Add security fields required by OTP protection.

Revision ID: 0001_user_security_columns
Revises:
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect

revision = "0001_user_security_columns"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    inspector = inspect(op.get_bind())
    columns = {column["name"] for column in inspector.get_columns("users")}
    if "otp_attempts" not in columns:
        op.add_column("users", sa.Column("otp_attempts", sa.Integer(), nullable=False, server_default="0"))


def downgrade():
    inspector = inspect(op.get_bind())
    columns = {column["name"] for column in inspector.get_columns("users")}
    if "otp_attempts" in columns:
        op.drop_column("users", "otp_attempts")
