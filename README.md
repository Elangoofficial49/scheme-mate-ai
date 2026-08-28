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
- **Database**: PostgreSQL with `pgvector` extension (Dual compatibility with SQLite for zero-dependency standalone execution)
- **Cache**: Redis
- **Security & DevSecOps**: Argon2id / bcrypt password hashing, short-lived JWT Access & Refresh Token rotation, RBAC (`USER`, `ADMIN`), Security headers middleware, Rate limiting, AI prompt injection guardrails, PII masking, Github Actions CI/CD.
- **Containerization**: Docker & Docker Compose

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
│   └── Dockerfile
├── data/
│   ├── seed_schemes.json       # 35+ verified central and state schemes
│   └── seed_rules.json         # Eligibility operators & weighting config
├── infrastructure/
│   ├── docker/init_pgvector.sql
│   ├── nginx/nginx.conf
│   └── monitoring/prometheus.yml
├── .github/workflows/devsecops.yml  # DevSecOps CI/CD pipeline
├── docker-compose.yml
├── .env.example
└── README.md
```

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

### Option B: Running with Docker Compose (PostgreSQL + pgvector + Redis + FastAPI)

```bash
# From project root directory
docker-compose up --build -d
```

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

