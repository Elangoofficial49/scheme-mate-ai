# SchemeMate AI

### AI-Driven Scheme Matching and Assistance System for Marginalized Entrepreneurs
**Smart India Hackathon (SIH) Solution**

---

## 📌 Project Overview

**SchemeMate AI** is a production-quality, secure, modular AI-powered mobile-first application designed to help marginalized, micro, and rural entrepreneurs discover government schemes, evaluate hard eligibility conditions deterministically, identify missing requirements, process documents using OCR, and access official application channels with explainable AI guidance.

---

## 📐 Architecture Principle: Hybrid AI System

```text
Entrepreneur Situation / Prompt / Speech / Voice Input
                       │
                       ▼
         Structured Profile Extraction
                       │
                       ▼
    Deterministic Eligibility Rule Engine  ◄── (Hard Authority, No LLM Hallucinations)
                       │
                       ▼
          Eligible Candidate Schemes
                       │
                       ▼
  AI Semantic Embedding & Ranking Engine  ◄── (30% Eligibility, 20% Business, 15% Finance, 15% Location, 10% Goal, 10% Relevance)
                       │
                       ▼
          Explainable AI (XAI) Output      ◄── ("Why you match" vs "Why not eligible")
                       │
                       ▼
       OCR Document Verification & Checklist
                       │
                       ▼
      Personalized Step-by-Step Action Plan
                       │
                       ▼
     Verified Official Government Portal URL
```

---

## 🛠️ Technology Stack

- **Mobile Frontend**: Flutter (Dart) — Android / Web / Cross-Platform with Multilingual i18n (`en`, `ta`, `hi`), Voice Mic simulator, high-contrast accessible UI, and local SharedPreferences offline caching.
- **Backend API**: Python 3.12 + FastAPI (Modular Monolith)
- **Database**: PostgreSQL configured through `DATABASE_URL`, with SQLite fallback for local development
- **Security & DevSecOps**: Argon2id / bcrypt password hashing, short-lived JWT Access & Refresh Token rotation, RBAC (`USER`, `ADMIN`), Security headers middleware, Rate limiting, AI prompt injection guardrails, PII masking, Github Actions CI/CD.
- **Deployment**: Render native Python web service and externally configured PostgreSQL

---

## 📁 Repository Structure

```text
scheme-mate-ai/
├── mobile/
│   └── flutter_app/            # Flutter Mobile Application
│       ├── pubspec.yaml
│       ├── assets/i18n/        # Translation JSONs (en.json, ta.json, hi.json)
│       └── lib/                # Flutter source code (models, providers, screens, theme, network)
├── backend/                    # FastAPI Backend Application
│   ├── app/
│   │   ├── main.py             # FastAPI entrypoint
│   │   ├── core/               # Configuration, security, database, logging
│   │   ├── models/             # ORM models (user, profile, scheme, match, document, audit)
│   │   ├── services/           # Rule engine, matching, RAG, OCR, audit, sync
│   │   ├── ai/                 # AI abstraction & security guardrails
│   │   ├── security/           # RBAC, Rate limiting, Security headers
│   │   └── api/v1/             # REST endpoints (auth, profile, schemes, matching, documents, admin)
│   ├── tests/                  # Pytest unit & integration test suite
│   ├── requirements.txt
│   ├── alembic.ini
│   └── alembic/                # Database migrations
├── data/
│   ├── seed_schemes.json       # 35+ verified central and state schemes
│   └── seed_rules.json         # Eligibility operators & weighting config
├── infrastructure/
│   └── monitoring/prometheus.yml
├── .github/workflows/devsecops.yml  # DevSecOps CI/CD pipeline
├── render.yaml
├── apt.txt
├── .python-version
├── scripts/render-build.sh
└── README.md
```

---

## Deploying to Render

The root-level `render.yaml` defines a native Render Blueprint for the FastAPI
backend. In Render, create or update the Blueprint from this GitHub repository
and deploy the `main` branch.

- `scheme-mate-app` installs the Python and OCR system dependencies, builds the
  Flutter web app, runs Alembic migrations, and serves both the API and web app
  from one origin.
- The backend uses the PostgreSQL database configured by `DATABASE_URL`.
  Supply the database connection string when syncing the Blueprint, or set it
  in the web service's Render environment. Use the provider's internal URL when
  the database and web service share a private network; otherwise use its
  externally accessible URL. Keep the value in Render's environment settings,
  not in source control.
- Render generates both JWT secrets automatically.
- GitHub Actions validates Python and Flutter code before Render auto-deploys.

The web service uses a Render plan and persistent disk for uploaded documents.
Review current plan and storage costs in Render before creating the service.

AI is configured to use the local provider and MongoDB is disabled by default.
To enable an external AI provider, set its API key and update `AI_PROVIDER` in
the backend service environment. OTP email delivery uses the Brevo HTTPS API.
In the Render Dashboard, set `BREVO_API_KEY` to a Brevo API key and
`BREVO_SENDER_EMAIL` to a sender address added and verified in Brevo. Brevo
requires sender-address verification; domain authentication may improve
deliverability, but is not the same as verifying the sender email. Never put
the API key in source control. Remove old `SMTP_*` and `RESEND_*` variables
from Render, then redeploy the web service.

After deployment, open the `scheme-mate-app` URL. The API health endpoint is
available at `/health`, and API documentation is available at `/docs`.

---

## 🚀 Running the Application Locally

### Option A: Running FastAPI Backend via Python Virtual Environment

```bash
# 1. Navigate to backend directory
cd scheme-mate-ai/backend

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run FastAPI application
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Open Swagger API Documentation: `http://localhost:8000/docs`
- Health check endpoint: `http://localhost:8000/health`

---

## 🧪 Running Automated Tests

Run the comprehensive pytest suite covering rule eligibility, hybrid matching, Argon2id auth, AI guardrails, OCR parsing, and REST endpoints:

```bash
cd scheme-mate-ai/backend
pytest -v
```

---

## 📱 Running the Flutter Mobile App

```bash
cd scheme-mate-ai/mobile/flutter_app
flutter pub get
flutter run
```

---

## 🔐 Key Security & Trust Highlights

1. **Deterministic Rule Engine**: Hard eligibility conditions (age bounds, income limits, state domicile, community category) are strictly evaluated by code logic.
2. **AI Guardrails**: Inputs are sanitized against prompt injections, PII (Aadhaar, PAN) is masked, and AI outputs are checked to prevent fake approval claims or invalid URLs.
3. **OCR Safety**: OCR extracted fields are presented in a verification modal requiring explicit user confirmation before updating profiles.
4. **Audit Log & Security Monitoring**: Sensitive operations (login, admin edits, scheme publishing, file uploads) emit structured immutable audit logs.
