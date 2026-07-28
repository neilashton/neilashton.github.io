---
layout: page
permalink: /work/
title: Research
nav_title: Research
description: Neil Ashton's research in AI for computational engineering, foundation models for physical systems, agentic simulation workflows, scientific datasets, model evaluation, and computational fluid dynamics.
nav: true
nav_order: 1
---

<div class="page-intro measure-wide">
  <p>My research develops AI methods for modelling, reasoning about, and designing complex physical systems. It connects high-fidelity simulation and scientific data with foundation models and agentic engineering workflows that remain verifiable, traceable, and accountable to human engineering judgement.</p>
</div>

<section class="work-section" aria-labelledby="projects-title">
  <h2 id="projects-title">Current research</h2>
  <div class="research-project-list">
    <article>
      <p class="research-type">Research programme</p>
      <h3>Agentic computational engineering</h3>
      <p>AI systems that formulate engineering tasks; select and orchestrate numerical, analysis, and optimisation tools; verify results for physical consistency; preserve provenance and traceability; handle uncertainty and recover from failures; and retain human oversight for consequential decisions.</p>
      <a href="https://www.nas.nasa.gov/pubs/ams/2026/04-09-26.html">NASA Ames talk</a>
    </article>
    <article>
      <p class="research-type">Open scientific data</p>
      <h3><a href="https://caemldatasets.org/">CAE ML Datasets</a></h3>
      <p>I lead and collaborate on large-scale, high-fidelity CFD datasets for reproducible machine-learning research. AhmedML, WindsorML, DrivAerML, and HiLiftAeroML cover automotive and aerospace configurations of increasing geometric and physical complexity.</p>
      <a href="https://caemldatasets.org/">Project website</a>
    </article>
    <article>
      <p class="research-type">Perspective paper</p>
      <h3><a href="https://arxiv.org/abs/2511.20455">Fluid Intelligence</a></h3>
      <p>An analysis of scaling laws, data-generation cost, and the technical requirements for foundation models in computational fluid dynamics.</p>
      <a href="https://arxiv.org/abs/2511.20455">Paper</a>
    </article>
  </div>
  {% include workshop_leadership.liquid %}
</section>

<section class="work-section" aria-labelledby="datasets-title">
  <h2 id="datasets-title">Open engineering datasets</h2>
  <div class="dataset-list">
    <article>
      <h3><a href="https://arxiv.org/abs/2407.20801">AhmedML</a></h3>
      <p>Scale-resolving CFD for 500 geometric variants of the Ahmed body.</p>
    </article>
    <article>
      <h3><a href="https://proceedings.neurips.cc/paper_files/paper/2024/hash/42a59a5f35b1b3c3fd648397c88a7164-Abstract-Datasets_and_Benchmarks_Track.html">WindsorML</a></h3>
      <p>GPU-native wall-modelled large-eddy simulations for 355 Windsor-body variants.</p>
    </article>
    <article>
      <h3><a href="https://arxiv.org/abs/2408.11969">DrivAerML</a></h3>
      <p>Surface and volume flow data for 500 realistic road-car variants.</p>
    </article>
    <article>
      <h3><a href="https://arxiv.org/abs/2605.19565">HiLiftAeroML</a></h3>
      <p>High-fidelity simulations across geometry variants and angles of attack for high-lift aircraft aerodynamics.</p>
    </article>
  </div>
</section>

<section class="work-section" aria-labelledby="themes-title">
  <h2 id="themes-title">Research questions</h2>
  <div class="research-themes">
    <article>
      <h3>Physical-system representations</h3>
      <p>How can models learn from high-fidelity simulations and generalise across geometries, operating conditions, and engineering tasks?</p>
    </article>
    <article>
      <h3>Tool-using engineering agents</h3>
      <p>How can agents select and orchestrate simulation, analysis, and optimisation tools while verifying physical consistency, preserving provenance, recovering from failures, representing uncertainty, and retaining appropriate human control?</p>
    </article>
    <article>
      <h3>Trustworthy evaluation</h3>
      <p>Which datasets and benchmarks demonstrate physical fidelity, engineering utility, computational efficiency, and out-of-distribution performance?</p>
    </article>
  </div>
</section>

<section class="work-section academic-contact" aria-labelledby="collaboration-title">
  <h2 id="collaboration-title">Research correspondence</h2>
  <p>I welcome correspondence from researchers working on related problems in industry and academia.</p>
  <p><a href="mailto:{{ site.email | encode_email }}">{{ site.email }}</a></p>
</section>
