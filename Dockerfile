FROM postgres:16

RUN apt update
RUN apt install -y postgresql-server-dev-15 make gcc wget libicu-dev

RUN wget https://ja.osdn.net/dl/pgbigm/pg_bigm-1.2-20200228.tar.gz
RUN tar zxf pg_bigm-1.2-20200228.tar.gz
RUN cd pg_bigm-1.2-20200228 && make USE_PGXS=1 && make USE_PGXS=1 install

RUN echo shared_preload_libraries='pg_bigm' >> /var/lib/postgresql/data/postgresql.conf

ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]

FROM postgres:16

RUN apt-get update && apt-get install -y --no-install-recommends make gcc wget libicu-dev postgresql-server-dev-16 \
  tempDir="$(mktemp -d)"; \
  cd "$tempDir"; \
  # Download and extract pg_bigm
  wget --no-check-certificate -O /$tempDir/v1.2-20240606.tar.gz "https://github.com/pgbigm/pg_bigm/archive/refs/tags/v1.2-20240606.tar.gz"; \
  tar xf /$tempDir/v1.2-20240606.tar.gz; \
  cd pg_bigm-1.2-20240606; \
  # Build and install pg_bigm
  make USE_PGXS=1; \
  make USE_PGXS=1 install; \
  # Configure PostgreSQL to preload pg_bigm
  echo "shared_preload_libraries = 'pg_bigm'" >> /var/lib/postgresql/data/postgresql.conf; \
  # Cleanup
  cd /; \
  rm -rf /tmp/pg_bigm-1.2-20240606; \
  apt-get remove -y build-essential; \
  apt-get autoremove -y; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*;

# Expose the PostgreSQL port
EXPOSE 5432