# fb-submitter
API for services built &amp; deployed on Form Builder to send the user data to
where it ultimately needs to go. Only PDFs-by-email supported at first, more to
come later


# Environment Variables

The following environment variables are either needed, or read if present:

* DATABASE_URL: used to connect to the database
* RAILS_ENV: 'development' or 'production'
* SERVICE_TOKEN_CACHE_ROOT_URL: protocol + hostname of the
  [service token cache](https://github.com/ministryofjustice/fb-service-token-cache)
