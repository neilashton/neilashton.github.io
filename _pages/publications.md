---
layout: page
permalink: /publications/
title: Publications
description: Peer-reviewed papers, conference proceedings, open datasets, and preprints by Neil Ashton across computational fluid dynamics, machine learning, and high-performance computing.
nav: true
nav_order: 2
publication_search: true
---

<div class="page-intro measure">
  <p>My research spans high-fidelity CFD, machine learning for engineering, open datasets, turbulence modelling, and scalable computing. Search the publication record or use a topic filter.</p>
</div>

<section class="publication-tools" aria-label="Filter publications">
  <label for="publication-search">Search publications</label>
  <div class="search-field">
    <i class="fa-solid fa-magnifying-glass" aria-hidden="true"></i>
    <input id="publication-search" type="search" placeholder="Title, author, venue, or year" autocomplete="off">
  </div>
  <div class="filter-chips" role="group" aria-label="Filter by topic">
    <button type="button" class="filter-chip is-active" data-publication-filter="all" aria-pressed="true">All</button>
    <button type="button" class="filter-chip" data-publication-filter="machine learning" aria-pressed="false">AI &amp; ML</button>
    <button type="button" class="filter-chip" data-publication-filter="aerodynamic" aria-pressed="false">Aerodynamics</button>
    <button type="button" class="filter-chip" data-publication-filter="high-performance|hpc|scaling" aria-pressed="false">HPC</button>
    <button type="button" class="filter-chip" data-publication-filter="dataset|drivaer|windsor|ahmed|hilift" aria-pressed="false">Datasets</button>
  </div>
  <p id="publication-results" class="results-count" aria-live="polite"></p>
  <p id="publication-empty" class="empty-results" hidden>No publications match those filters. Try a broader search.</p>
</section>

<div class="publications" data-publications>
  {% bibliography %}
</div>

<section class="scholarly-outputs" aria-labelledby="thesis-heading">
  <div class="scholarly-output-group">
    <h2 id="thesis-heading">Thesis</h2>
    <article class="scholarly-output">
      <p class="scholarly-output-type">PhD thesis · 2013</p>
      <h3>
        <a href="https://research.manchester.ac.uk/portal/en/theses/development-implementation-and-testing-of-an-alternative-ddes-formulation-based-on-elliptic-relaxation%28cfd86ae9-c48e-4f89-84b7-fa6aac6dd3e4%29.html">
          Development, Implementation and Testing of an Alternative DDES Formulation Based on Elliptic Relaxation
        </a>
      </h3>
      <p>University of Manchester</p>
    </article>
  </div>

  <div class="scholarly-output-group">
    <h2>Research artifacts &amp; technical reports</h2>
    <div class="scholarly-output-list">
      <article class="scholarly-output">
        <p class="scholarly-output-type">Dataset · 2026</p>
        <h3><a href="https://doi.org/10.57967/hf/7644">WindsorML dataset</a></h3>
        <p>Open high-fidelity automotive-aerodynamics data · DOI 10.57967/hf/7644</p>
      </article>
      <article class="scholarly-output">
        <p class="scholarly-output-type">Dataset · 2025</p>
        <h3><a href="https://doi.org/10.57967/hf/5002">AhmedML dataset</a></h3>
        <p>Open high-fidelity bluff-body aerodynamics data · DOI 10.57967/hf/5002</p>
      </article>
      <article class="scholarly-output">
        <p class="scholarly-output-type">Technical report · 2018</p>
        <h3>
          <a href="https://www.archer.ac.uk/community/eCSE/eCSE07-15/ecse07-15-optimizing-8.pdf">
            Optimizing the I/O Performance of OpenFOAM for Massively Parallel High-Fidelity CFD Simulations
          </a>
        </h3>
        <p>ARCHER eCSE07-15</p>
      </article>
    </div>
  </div>
</section>
