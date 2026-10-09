from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.security.middleware import SecurityHeadersMiddleware


def test_content_security_policy_allows_flutter_wasm_without_general_eval():
    app = FastAPI()
    app.add_middleware(SecurityHeadersMiddleware)

    @app.get("/")
    def root():
        return {"status": "ok"}

    response = TestClient(app).get("/")

    assert response.status_code == 200
    policy = response.headers["content-security-policy"]
    assert "'wasm-unsafe-eval'" in policy
    assert "'unsafe-eval'" not in policy
