---
layout: page
permalink: /cv/
title: Curriculum vitae
nav_title: CV
description: Curriculum vitae of Neil Ashton, computational engineering researcher and technical leader in scientific machine learning, high-fidelity simulation, foundation models, agentic AI, and high-performance computing.
nav: true
nav_order: 3
---

{% assign current_role = site.current_position.role %}
{% assign current_organisation = site.current_position.organisation %}
{% assign current_organisation_url = site.current_position.organisation_url %}

<div class="cv-intro-grid">
  <div class="cv-intro measure-wide">
    <p class="cv-current-position">
      <strong>{{ current_role | escape }}</strong>
      <span aria-hidden="true">·</span>
      <a href="{{ current_organisation_url }}">{{ current_organisation | escape }}</a>
    </p>
    <p class="cv-summary">{{ site.data.cv.summary }}</p>
    <nav class="cv-actions academic-links" aria-label="Curriculum vitae links">
      <a href="{{ '/assets/pdf/neil-ashton-cv.pdf' | relative_url }}">Download PDF</a>
      <a href="{{ '/publications/' | relative_url }}">Full publication record</a>
      <a href="{{ '/talks/' | relative_url }}">Talks archive</a>
    </nav>
    <p class="cv-updated">Updated {{ site.data.cv.updated }}</p>
  </div>
  <figure class="cv-headshot">
    <img
      src="{{ '/assets/img/prof_pic.jpg' | relative_url }}"
      alt="Portrait of Neil Ashton"
      width="267"
      height="357"
      loading="eager"
      fetchpriority="high"
      decoding="async"
    >
  </figure>
</div>

<section class="cv-section" aria-labelledby="experience-title">
  <h2 id="experience-title">Experience</h2>
  <ol class="cv-timeline">
    {% for item in site.data.cv.experience %}
      <li class="cv-entry">
        <p class="cv-period">{{ item.period }}</p>
        <div class="cv-entry-main">
          <h3>
            {% if item.current %}
              {{ current_role }}
            {% else %}
              {{ item.role }}
            {% endif %}
          </h3>
          <p class="cv-organisation">
            {% if item.current %}
              <a href="{{ current_organisation_url }}">{{ current_organisation }}</a>
            {% elsif item.organisation_url %}
              <a href="{{ item.organisation_url }}">{{ item.organisation }}</a>
            {% else %}
              {{ item.organisation }}
            {% endif %}
            {% if item.location %}<span>{{ item.location }}</span>{% endif %}
          </p>
          {% if item.highlights %}
            <ul class="cv-highlights">
              {% for highlight in item.highlights %}
                <li>{{ highlight }}</li>
              {% endfor %}
            </ul>
          {% endif %}
        </div>
      </li>
    {% endfor %}
  </ol>
</section>

<section class="cv-section" aria-labelledby="leadership-title">
  <h2 id="leadership-title">Research leadership and public scholarship</h2>
  <div class="cv-leadership">
    {% for item in site.data.cv.research_leadership %}
      <article>
        <h3>
          {% if item.url contains '://' %}
            <a href="{{ item.url }}">{{ item.title }}</a>
          {% else %}
            <a href="{{ item.url | relative_url }}">{{ item.title }}</a>
          {% endif %}
        </h3>
        <p class="cv-role">{{ item.role }}</p>
        <p>{{ item.description }}</p>
      </article>
    {% endfor %}
  </div>
</section>

<section class="cv-section cv-two-column" aria-labelledby="education-title">
  <div>
    <h2 id="education-title">Education</h2>
    <div class="cv-education">
      {% for item in site.data.cv.education %}
        <article>
          <p class="cv-period">{{ item.period }}</p>
          <h3>
            {% if item.url %}<a href="{{ item.url }}">{% endif -%}
            {{- item.degree -}}
            {%- if item.url %}</a>{% endif %}
          </h3>
          <p class="cv-organisation">{{ item.institution }}</p>
          {% if item.detail %}<p>{{ item.detail }}</p>{% endif %}
        </article>
      {% endfor %}
    </div>
  </div>
  <div>
    <h2 id="standing-title">Professional standing</h2>
    <ul class="cv-standing" aria-labelledby="standing-title">
      {% for item in site.data.cv.professional_standing %}
        <li>
          <span>{{ item.title }}</span>
          <span>{{ item.period }}</span>
        </li>
      {% endfor %}
    </ul>
  </div>
</section>

<section class="cv-section" aria-labelledby="selected-publications-title">
  <div class="section-heading compact">
    <h2 id="selected-publications-title">Selected publications</h2>
    <a class="text-link" href="{{ '/publications/' | relative_url }}">Full publication record</a>
  </div>
  <ol class="cv-publications">
    {% for item in site.data.cv.publications %}
      <li>
        <p class="cv-publication-year">{{ item.year }}</p>
        <p>
          {{ item.authors }}{% unless item.authors contains 'et al.' %}.{% endunless %}
          <a href="{{ item.url }}">{{ item.title }}</a>.
          <em>{{ item.venue }}</em>.
        </p>
      </li>
    {% endfor %}
  </ol>
</section>

<section class="cv-section" aria-labelledby="selected-talks-title">
  <div class="section-heading compact">
    <h2 id="selected-talks-title">Selected invited talks</h2>
    <a class="text-link" href="{{ '/talks/' | relative_url }}">Talks archive</a>
  </div>
  <ul class="cv-talks">
    {% for item in site.data.cv.talks %}
      <li>
        <p class="cv-period">{{ item.date }}</p>
        <div>
          <p class="cv-talk-type">{{ item.type }}</p>
          <h3>
            {% if item.url %}<a href="{{ item.url }}">{% endif -%}
            {{- item.host -}}
            {%- if item.url %}</a>{% endif %}
          </h3>
          <p>{{ item.title }}</p>
        </div>
      </li>
    {% endfor %}
  </ul>
</section>

<section class="cv-section cv-contact" aria-labelledby="cv-contact-title">
  <h2 id="cv-contact-title">Contact and profiles</h2>
  <p>
    <a href="mailto:{{ site.email | encode_email }}">{{ site.email }}</a>
    <span aria-hidden="true">·</span>
    <a href="https://scholar.google.com/citations?user={{ site.scholar_userid }}">Google Scholar</a>
    <span aria-hidden="true">·</span>
    <a href="https://orcid.org/{{ site.orcid_id }}">ORCID</a>
    <span aria-hidden="true">·</span>
    <a href="https://www.linkedin.com/in/{{ site.linkedin_username }}">LinkedIn</a>
  </p>
</section>
