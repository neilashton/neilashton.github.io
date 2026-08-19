# Neil Ashton — personal website

This repository contains the source for [neilashton.co.uk](https://neilashton.co.uk/), Neil Ashton's public research and professional website.

## Site content

The site brings together:

- research in computational engineering, scientific machine learning, CFD, foundation models and agentic systems;
- publications, talks and a curriculum vitae;
- open engineering datasets and reproducibility resources; and
- episodes of [The Neil Ashton Podcast](https://neilashton.co.uk/podcasts/).

Most page content is in `_pages/`, publications are managed through the site's bibliography data, and podcast entries are in `_podcast_episodes/`.

## Local development

The site uses Jekyll and the Ruby dependencies recorded in `Gemfile.lock`. Ruby 3.2.2 matches the deployment workflow.

```bash
bundle install
bundle exec jekyll serve
```

The local preview is then available at <http://localhost:4000>. To run the production build used by deployment:

```bash
JEKYLL_ENV=production bundle exec jekyll build
```

## Deployment

GitHub Actions builds the site for pull requests. Changes merged to `master` are built and deployed to GitHub Pages by `.github/workflows/deploy.yml`.

## Contributions

Corrections to public information and fixes to the site are welcome through an issue or pull request. For research correspondence, use [contact@neilashton.co.uk](mailto:contact@neilashton.co.uk).

## Theme and licence

The site is based on the [al-folio](https://github.com/alshedivat/al-folio) Jekyll theme. Repository code is available under the [MIT License](LICENSE).
