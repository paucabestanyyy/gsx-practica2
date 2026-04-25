# Week 9 - Multi-Container Orchestration (Docker Compose)
**Autors:** Pau Cabestany i Eric Hernandez

## Architecture Diagram

```text
       [Internet / Host]
              │ (Port 80)
              ▼
   ┌────────────────────┐
   │    Nginx (Proxy)   │◄───(Volum: nginx_logs)
   └─────────┬──────────┘
             │ (frontend_net)
             ▼
   ┌────────────────────┐
   │   Backend Python   │
   └─────────┬──────────┘
             │ (backend_net)
             ▼
   ┌────────────────────┐
   │  Redis (Database)  │◄───(Volum: redis_data)
   └────────────────────┘
