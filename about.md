---
layout: page
title: about
permalink: /about/
---

<!-- Replace this section with your own bio -->

In the ancient times, there existed individuals with the necessary skills to build, fix, and architect whole digital systems. Their skills were considered magic. They were known as "greybeards". Long ago existed the fabled...System Administrator. I claim that fabled title. When there is a network issue caused by mismatch MTU, I will dig in the logs and find it. When a new critical exploit has been released allowing remote code execution, I will deploy patches. I will spend hours working on an automation to save 10 minutes for every run in the future. I will build cloud solutions meeting all of the "well-architected" framework tenants. I will do all of these things and more because in the end, no matter what new fangled title I am given, I am just a fella with a "can do, figure it out" attitude! 

---

## what I do

Think harder not smarter...or something close to that. 

- **Offensive security** —  red team ops, automated pentetation testing
- **Secure infrastructure** — cloud architecture, hardening, automation at scale
- **Security research** — vulnerability discovery, CVE research, business impact analysis
- **Software development** — security tooling, automation, backend systems

---

## skills

<div class="skills-section">
  <div class="skills-grid">
    <div class="skill-group">
      <h3>offensive</h3>
      <ul>
        <li>Red teaming</li>
        <li>Scripting</li>
        <li>Scanning</li>
      </ul>
    </div>
    <div class="skill-group">
      <h3>infrastructure</h3>
      <ul>
        <li>AWS / Azure</li>
        <li>Terraform / Ansible</li>
        <li>Docker / Podman</li>
        <li>CI/CD pipelines</li>
        <li>Proxmox / Virtualization</li>
      </ul>
    </div>
    <div class="skill-group">
      <h3>development</h3>
      <ul>
        <li>Python</li>
        <li>Powershell</li>
        <li>Bash / shell scripting</li>
        <li>Vibecoding</li>
      </ul>
    </div>
    <div class="skill-group">
      <h3>research</h3>
      <ul>
        <li>Reverse engineering</li>
        <li>Binary analysis</li>
        <li>Fuzzing</li>
        <li>Protocol research</li>
        <li>CVE development</li>
      </ul>
    </div>
  </div>
</div>

---

## certifications

<div class="cert-grid">
  {% for cert in site.data.certifications %}
    <a class="cert-card" href="{{ cert.url }}" target="_blank" rel="noopener">
      <img class="cert-card-logo" src="{{ cert.image | relative_url }}" alt="{{ cert.name }} logo" loading="lazy">
      <span class="cert-card-name">{{ cert.name }}</span>
      <span class="cert-card-issuer">{{ cert.issuer }}</span>
    </a>
  {% endfor %}
</div>
