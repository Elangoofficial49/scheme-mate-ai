from unittest.mock import Mock

import httpx

from app.core.config import settings
from app.services.email_service import EmailService


def test_send_otp_email_uses_brevo_https_api(monkeypatch):
    monkeypatch.setattr(settings, "BREVO_API_KEY", "test-api-key")
    monkeypatch.setattr(
        settings, "BREVO_SENDER_EMAIL", "otp@example.com"
    )
    response = Mock(is_success=True, status_code=201)
    post = Mock(return_value=response)
    monkeypatch.setattr("app.services.email_service.httpx.post", post)

    result = EmailService.send_otp_email(
        "user@example.com", "123456", user_name="<User>"
    )

    assert result == {"delivered": True}
    post.assert_called_once()
    args, kwargs = post.call_args
    assert args == ("https://api.brevo.com/v3/smtp/email",)
    assert kwargs["headers"]["api-key"] == "test-api-key"
    assert kwargs["json"]["sender"] == {
        "name": "SchemeMate AI",
        "email": "otp@example.com",
    }
    assert kwargs["json"]["to"] == [{"email": "user@example.com"}]
    assert "123456" in kwargs["json"]["textContent"]
    assert "&lt;User&gt;" in kwargs["json"]["htmlContent"]
    assert kwargs["timeout"] == 10.0


def test_send_otp_email_reports_missing_brevo_configuration(monkeypatch):
    monkeypatch.setattr(settings, "BREVO_API_KEY", None)
    monkeypatch.setattr(
        settings, "BREVO_SENDER_EMAIL", "otp@example.com"
    )

    result = EmailService.send_otp_email("user@example.com", "123456")

    assert result == {"delivered": False, "reason": "brevo_not_configured"}


def test_send_otp_email_reports_brevo_http_error(monkeypatch):
    monkeypatch.setattr(settings, "BREVO_API_KEY", "test-api-key")
    monkeypatch.setattr(settings, "BREVO_SENDER_EMAIL", "otp@example.com")
    post = Mock(return_value=Mock(is_success=False, status_code=403))
    monkeypatch.setattr("app.services.email_service.httpx.post", post)

    result = EmailService.send_otp_email("user@example.com", "123456")

    assert result == {"delivered": False, "reason": "brevo_http_403"}


def test_send_otp_email_reports_brevo_connection_error(monkeypatch):
    monkeypatch.setattr(settings, "BREVO_API_KEY", "test-api-key")
    monkeypatch.setattr(settings, "BREVO_SENDER_EMAIL", "otp@example.com")
    post = Mock(side_effect=httpx.ConnectError("network unavailable"))
    monkeypatch.setattr("app.services.email_service.httpx.post", post)

    result = EmailService.send_otp_email("user@example.com", "123456")

    assert result == {"delivered": False, "reason": "brevo_request_failed"}
