# Kanban

**Status:** Work In Progress

**Stack:** Ruby on Rails 7.2.3, Hotwire (Turbo/Stimulus), PostgreSQL, Docker.

This project is a Proof of Concept designed to simulate a high-concurrency production environment. Beyond a simple task manager, it serves as a testing ground for solving complex distributed systems challenges, focusing on data integrity, real-time synchronization, and database optimization.

## Engineering Highlights

### 1. Database Excellence
*   **Proactive N+1 Prevention:** Integrated the **Bullet** gem to identify and eliminate inefficient database queries in the `Board -> List -> Card` hierarchy. This ensures minimal overhead as the dataset grows.
*   **Scalable Search via Transactional Outbox Pattern (Planned):** To support high-performance card searching, I am implementing **ElasticSearch** integration. To ensure "at-least-once" delivery and data consistency between PostgreSQL and the search index, I am using the **Outbox Pattern** with **Sidekiq**. This architecture prevents data loss during partial system failures and keeps the primary transaction logs clean.
*   **Transaction Integrity (Planned):** Implementation of explicit **Repeatable Read** isolation levels for drag-and-drop operations to address potential race conditions in multi-user environments.

### 2. Real-Time UX (The Hotwire Stack)
*   **Turbo Streams:** Utilizes asynchronous communication via Turbo Streams to synchronize board state across clients in real-time without full page reloads.
*   **Stimulus JS Integration:** Lightweight JavaScript controllers handle complex client-side interactions (like Drag & Drop) while maintaining a clean, server-side-rendered architecture.

### 3. Authorization & Security
*   **Secure Authentication:** Integrated **Devise** for robust session management and user protection.
*   **Policy-Based Auth (Pundit):** Implementation of strict resource-level permissions distinguishing between **Admin** and **Member** roles. Authorization logic is decoupled from controllers using Pundit policies to ensure a secure "Zero Trust" data access model.

## Tech Stack

| Category | Technologies |
| :--- | :--- |
| **Backend** | Ruby on Rails 7.2.3, Ruby 3.4 |
| **Frontend** | Hotwire (Turbo, Stimulus), Tailwind CSS |
| **Database** | PostgreSQL, (Planned: ElasticSearch ingested with Outbox Pattern/CDC)  |
| **Engineering** | Pundit (Auth), Bullet (Perf), RSpec (Testing) |
| **Infra** | Docker, Docker Compose (Planned: Kubernetes, Kafka) |

## Roadmap

- [x] **Core Architecture:** Board and Card persistence logic.
- [x] **RBAC:** Policy-based authorization (Pundit) for Admin/Member roles.
- [x] **Real-time:** Asynchronous board state synchronization via Turbo Streams.
- [ ] **Business Logic (Current Focus):**
    - **WIP Limits:** Configurable card constraints per list to prevent bottlenecks.
    - **Resource Quotas:** Implementing board creation limits (e.g., 3 boards per user) to demonstrate unit economics management.
- [ ] **Scalable Search:** **ElasticSearch** integration via the **Transactional Outbox Pattern** to solve the "Dual Writes" problem and ensure eventual consistency.
- [ ] **Observability:** Immutable Audit Trail for every state transition (Who, When, How).
- [ ] **Cloud Readiness:** Full-stack containerization (Docker/K8s) and a distributed event bus (Kafka) for high-scale simulation.

## Setup and Installation

```bash
# Clone the repository
git clone https://github.com/olichwiruk/kanban.git

# Initialize infrastructure
docker-compose up -d

# Prepare the database
bin/rails db:prepare

# Start the development server
bin/dev
