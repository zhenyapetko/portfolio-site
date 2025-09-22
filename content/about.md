---
title: "О Проекте"
date: 2024-10-01T00:00:00+00:00
type: page
---

# DevOps Документация этого Проекта

## Введение
Этот сайт — результат курса по DevOps. Я построил полноценный сервис с использованием конвейера разработки.

## Архитектура

+------------+ +-------------+ +----------------+
| Local Dev | --> | Docker Build | --> | AWS Deploy |
+------------+ +-------------+ +----------------+
(Hugo + Docker) (Nginx + Site) (EC2 + CD)


## Технический стек
- **Frontend/Static:** Hugo
- **Контейнеризация:** Docker, Docker Compose
- **IaC:** Terraform, Ansible
- **CI/CD:** GitHub Actions
- **Мониторинг:** Prometheus + Grafana
- **Облако:** AWS EC2 + ELastic IP
