{% from "vertx/map.jinja" import vertx with context %}
{% from "vertx/defaults.jinja" import config with context %}

{% set version = config('version', 'vertx') %}
{% set install_path = config('install_path', 'vertx') %}
{% set s3_bucket = config('s3_bucket', 'vertx') %}

include:
  - vertx.logging.logstash
  - vertx.logging.logback
  - vertx.logging.slf4j

vertx_install_path:
  file.directory:
    - name: {{ install_path }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
    - require_in:
      - module: untar-vertx

check_vertx:
  cmd.script:
    - stateful: True
    - template: jinja
    - source: salt://vertx/files/check_for_vertx.sh

deploy_vertx:
  module.wait:
    - name: s3.get
    - bucket: {{ s3_bucket }}
    - path: "packages/vertx/vert.x-{{ version }}.tar.gz"
    - local_file: "/tmp/vert.x-{{ version }}.tar.gz"
    - return_bin: True
    - watch:
      - cmd: check_vertx

untar-vertx:
  module.wait:
    - name: archive.tar
    - options: xzf
    - tarfile: "/tmp/vert.x-{{ version }}.tar.gz"
    - cwd: {{ install_path }}
    - watch:
      - module: deploy_vertx
    - require:
      - module: deploy_vertx

vertx-bin:
  file.symlink:
    - name: /usr/bin/vertx
    - target: {{ install_path }}/vert.x-{{ version }}/bin/vertx
    - require:
      - module: untar-vertx
