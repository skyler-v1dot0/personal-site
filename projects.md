---
layout: default
permalink: /projects/
---
<article class="page">
  <header class="page-header">
    <h1 class="page-title">projects</h1>
    <p class="page-description">Tools, research, and things I've built.</p>
  </header>

  <div class="projects-grid">
    {% for project in site.data.projects %}
    <div class="project-card">
      <div class="project-card-header">
        <span class="project-name">
          {% if project.url %}
            <a href="{{ project.url }}" target="_blank" rel="noopener">{{ project.name }}</a>
          {% else %}
            {{ project.name }}
          {% endif %}
        </span>
        <div class="project-links">
          {% if project.github %}
            <a href="{{ project.github }}" target="_blank" rel="noopener">github</a>
          {% endif %}
          {% if project.url and project.url != project.github %}
            <a href="{{ project.url }}" target="_blank" rel="noopener">site</a>
          {% endif %}
        </div>
      </div>
      <p class="project-description">{{ project.description }}</p>
      {% if project.tags %}
      <div class="project-tags">
        {% for tag in project.tags %}
          <span class="tag">{{ tag }}</span>
        {% endfor %}
      </div>
      {% endif %}
    </div>
    {% endfor %}
  </div>
</article>
