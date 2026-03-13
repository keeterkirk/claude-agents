# Home Profile: Horse Racing Handicapping Platform

## Platform Overview

Full-stack horse racing handicapping and wagering application. Users can view
race analysis, receive ML-powered predictions, evaluate horses, and construct
optimized betting strategies for thoroughbred racing.

## Stack

- **Backend**: Ruby on Rails 8, PostgreSQL (source of truth), MongoDB (CQRS read store)
- **Frontend/Mobile**: React Native (Expo)
- **Systems/Services**: Go (gRPC, high-throughput odds pipelines)
- **Python Services**: FastAPI + Uvicorn for ML/data processing
- **Cloud**: GCP (Cloud Run, GKE, Cloud SQL, Pub/Sub)
- **CI/CD**: GitHub Actions, Linear for ticket management
- **Messaging**: NATS JetStream for event streaming
- **ML**: Vertex AI Pipelines, LightGBM/XGBoost/CatBoost, ONNX for cross-platform inference
- **Containers**: Docker multi-stage builds with CUDA/Ollama support
- **Load Testing**: k6

## Conventions

- Actor-based service objects using `Sunny::Actor` gem (with `play_actors` for composition)
- Rails 8 defaults: Solid Queue (jobs), Solid Cache (caching), Solid Cable (WebSocket)
- CQRS pattern: PostgreSQL writes → domain events → async projections → MongoDB reads
- NATS JetStream for inter-service messaging with hierarchical subjects
- ONNX model export for cross-platform deployment (Ruby backend + React Native mobile)
- RSpec with factory_bot (deep composable traits)
- Jest + React Native Testing Library for RN
- Table-driven tests in Go
- pytest with composable conftest fixtures for Python
- Polars for data processing (not pandas)
- GCP infrastructure managed via Terraform
- Docker compose stacks include: PG + MongoDB + Redis + NATS + Ollama + MLflow

## Domain Agents Available

In addition to the shared agents, this profile provides:
handicapping, betting-strategy, horse-assessment, scraping, ml-planning,
ml-orchestration, ml-pipeline, mongodb, cqrs, nats, gcp, k6, payments
