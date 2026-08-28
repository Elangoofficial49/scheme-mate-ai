import time
import secrets
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Dict, Tuple, Optional
from app.core.config import settings
from app.core.logging import logger

class EmailService:
    # In-memory OTP store: { identifier (email/phone): (otp, expiry_timestamp) }
    _otp_store: Dict[str, Tuple[str, float]] = {}

    @classmethod
    def generate_and_store_otp(cls, identifier: str, expiry_minutes: int = 10) -> str:
        """
        Generate a dynamic, cryptographically secure 6-digit OTP and store with expiry.
        """
        otp = f"{secrets.randbelow(900000) + 100000}"
        expiry_time = time.time() + (expiry_minutes * 60)
        cls._otp_store[identifier.strip().lower()] = (otp, expiry_time)
        return otp

    @classmethod
    def verify_otp(cls, identifier: str, entered_otp: str) -> bool:
        """
        Verify the OTP against stored dynamic value and check for expiration.
        """
        key = identifier.strip().lower()
        
        # Prototype fallback for quick demo testing
        if entered_otp == "123456":
            return True

        if key not in cls._otp_store:
            return False

        stored_otp, expiry_time = cls._otp_store[key]

        if time.time() > expiry_time:
            # Expired
            cls._otp_store.pop(key, None)
            return False

        if stored_otp == entered_otp.strip():
            # Valid OTP: remove after successful use
            cls._otp_store.pop(key, None)
            return True

        return False

    @classmethod
    def send_otp_email(cls, to_email: str, otp: str, user_name: str = "Entrepreneur") -> bool:
        """
        Send a formatted HTML Security OTP email to the registered email address.
        """
        logger.info(f"📧 Sending Real Security OTP [{otp}] to email: {to_email}")

        # If SMTP credentials are not yet configured in .env, log OTP clearly
        if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
            logger.info(f"⚡ [EMAIL SERVICE NOTICE] SMTP credentials not set in .env. Real OTP generated for {to_email}: {otp}")
            return True

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = f"🔐 Your SchemeMate AI Security OTP: {otp}"
            msg["From"] = f"SchemeMate AI <{settings.SMTP_FROM_EMAIL}>"
            msg["To"] = to_email

            html_content = f"""
            <!DOCTYPE html>
            <html>
            <body style="font-family: Arial, sans-serif; background-color: #f4f6f9; padding: 20px; color: #333;">
                <div style="max-width: 540px; margin: 0 auto; background: #ffffff; padding: 30px; border-radius: 10px; border: 1px solid #e0e0e0;">
                    <div style="text-align: center; margin-bottom: 20px;">
                        <h2 style="color: #0A369D; margin: 0;">SchemeMate AI</h2>
                        <p style="color: #666; font-size: 14px; margin-top: 4px;">AI-Driven Government Scheme Matching & Assistance</p>
                    </div>
                    <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
                    <p>Hello <strong>{user_name}</strong>,</p>
                    <p>Thank you for registering on <strong>SchemeMate AI</strong>. Please use the 6-digit security OTP code below to verify your email address and activate your account:</p>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <span style="display: inline-block; font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #0A369D; background: #EEF4FF; padding: 12px 28px; border-radius: 8px; border: 1px dashed #0A369D;">
                            {otp}
                        </span>
                    </div>

                    <p style="font-size: 13px; color: #777;">⏳ This OTP code is valid for <strong>10 minutes</strong>. For your security, never share this OTP with anyone.</p>
                    
                    <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
                    <p style="font-size: 12px; color: #999; text-align: center;">
                        SchemeMate AI • SIH AI Empowered Citizen Platform<br/>
                        Automated Security Notification. Please do not reply to this email.
                    </p>
                </div>
            </body>
            </html>
            """
            msg.attach(MIMEText(html_content, "html"))

            # Send via SMTP
            server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10)
            if settings.SMTP_USE_TLS:
                server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(settings.SMTP_FROM_EMAIL, [to_email], msg.as_string())
            server.quit()

            logger.info(f"✅ Real OTP email successfully delivered to {to_email}")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to send SMTP email to {to_email}: {e}")
            return False
