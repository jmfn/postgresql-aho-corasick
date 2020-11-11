FROM postgres:9.3

RUN apt-get update && apt-get install -y postgresql-plpython3-9.3

RUN apt-get install -y postgresql-server-dev-9.3 gcc wget libgeos-dev libxml2-dev libproj-dev proj-data proj-bin libgdal-dev make
RUN cd /tmp \
    && echo 'CREATE EXTENSION plpython3u;' > /docker-entrypoint-initdb.d/plpython3u.sql 

RUN apt-get install -y python3-pip \
  && pip3 install pyahocorasick

RUN echo $PYTHONPATH