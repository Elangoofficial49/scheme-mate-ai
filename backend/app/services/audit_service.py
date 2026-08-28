from sqlalchemy.orm import Session
from app.models.audit import AuditLog, SecurityEvent
from app.core.logging import logger

class AuditService:
    """
    Audit logging and Security Monitoring service.
    """

    @staticmethod
    def log_action(db: Session, action: str, user_id: str = None, resource: str = None, details: str = None, ip_address: str = None):
        try:
            audit = AuditLog(
                user_id=user_id,
                action=action,
                resource=resource,
                details=details,
                ip_address=ip_address
            )
            db.add(audit)
            db.commit()
            logger.info(f"AUDIT_LOG [{action}] User:{user_id} Res:{resource}")
        except Exception as e:
            logger.error(f"Failed to record audit log: {e}")

    @staticmethod
    def log_security_event(db: Session, event_type: str, severity: str = "MEDIUM", description: str = "", user_id: str = None, ip_address: str = None):
        try:
            sec_event = SecurityEvent(
                event_type=event_type,
                severity=severity,
                description=description,
                user_id=user_id,
                ip_address=ip_address
            )
            db.add(sec_event)
            db.commit()
            logger.warning(f"SECURITY_EVENT [{event_type}] Severity:{severity} Desc:{description}")
        except Exception as e:
            logger.error(f"Failed to record security event: {e}")
