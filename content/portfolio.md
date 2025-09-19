---
title: "Портфолио"
date: 2024-10-01T00:00:00+00:00
type: page
---

# Мои проекты

## Проект 1: Этот сайт
- **Описание:** DevOps портфолио с Hugo и Docker.
- **Технологии:** Hugo, Docker, CI/CD.
- [Код на GitHub](https://github.com/yourusername/repo)  <!-- Замени на свой репо -->

## Проект 2: Другой
- Добавь свои реальные проекты здесь.

### Список с GitHub
<div id="repos"></div>
<script>
  fetch('https://api.github.com/users/zhenya/repos')  <!-- Замени zhenya на свой username -->
    .then(response => response.json())
    .then(data => {
      const reposDiv = document.getElementById('repos');
      reposDiv.innerHTML = '<ul>' + data.map(repo => `<li><a href="${repo.html_url}" target="_blank">${repo.name}</a></li>`).join('') + '</ul>';
    });
</script>