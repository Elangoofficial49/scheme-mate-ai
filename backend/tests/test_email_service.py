from unittest.mock import Mock

import httpx

from app.core.config import settings
from app.services.email_service import EmailService


def test_send_otp_email_uses_resend_https_api(monkeypatch):
    monkeypatch.setattr(settings, "RESEND_API_KEY", "test-api-key")
    monkeypatch.setattr(
        settings, "RESEND_FROM_EMAIL", "SchemeMate AI <otp@example.com>"
    )
    response = Mock(is_success=True, status_code=200)
    post = Mock(return_value=response)
    monkeypatch.setattr("app.services.email_service.httpx.post", post)

    result = EmailService.send_otp_email(
        "user@example.com", "123456", user_name="<User>"
    )

    assert result == {"delivered": True}
    post.assert_called_once()
    args, kwargs = post.call_args
    assert args == ("https://api.resend.com/emails",)
    assert kwargs["headers"]["Authorization"] == "Bearer test-api-key"
    assert kwargs["json"]["from"] == "SchemeMate AI <otp@example.com>"
    assert kwargs["json"]["to"] == ["user@example.com"]
    assert kwargs["json"]["text"].find("123456") >= 0
    assert "&lt;User&gt;" in kwargs["json"]["html"]
    assert kwargs["timeout"] == 10.0


def test_send_otp_email_reports_missing_resend_configuration(monkeypatch):
    monkeypatch.setattr(settings, "RESEND_API_KEY", None)
    monkeypatch.setattr(
        settings, "RESEND_FROM_EMAIL", "SchemeMate AI <otp@example.com>"
    )

    result = EmailService.send_otp_email("user@example.com", "123456")

    assert result == {"delivered": False, "reason": "resend_not_configured"}


def test_send_otp_email_reports_resend_http_error(monkeypatch):
    monkeypatch.setattr(settings, "RESEND_API_KEY", "test-api-key")
    monkeypatch.setattr(settings, "RESEND_FROM_EMAIL", "otp@example.com")
    post = Mock(return_value=Mock(is_success=False, status_code=403))
    monkeypatch.setattr("app.services.email_service.httpx.post", post)

    result = EmailService.send_otp_email("user@example.com", "123456")

    assert result == {"delivered": False, "reason": "resend_http_403"}


def test_send_otp_email_reports_resend_connection_error(monkeypatch):
    monkeypatch.setattr(settings, "RESEND_API_KEY", "test-api-key")
    monkeypatch.setattr(settings, "RESEND_FROM_EMAIL", "otp@example.com")
    post = Mock(side_effect=httpx.ConnectError("network unavailable"))
    monkeypatch.setattr("app.services.email_service.httpx.post", post)

    result = EmailService.send_otp_email("user@example.com", "123456")

    assert result == {"delivered": False, "reason": "resend_request_failed"}
