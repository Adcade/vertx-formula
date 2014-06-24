{% from "vertx/defaults.jinja" import config with context %}
{% from "vertx/map.jinja" import vertx with context %}

{% set install = config('install', 'logback') %}
{% set install_path = config('install_path', 'vertx') %}
{% set version = config('version', 'vertx') %}
{% set target_path = install_path ~ '/vert.x-' ~ version %}
{% set s3_bucket = config('s3_bucket', 'vertx') %}

{% set logback_version = config('version', 'logback') %}

{% if install == 'True' %}

check_for_logback_core:
  cmd.run:
    - name: "[ -f {{ target_path }}/lib/logback-core-{{ logback_version }}.jar ]; if [ $? == 1 ]; then echo -e '\nchanged=true'; fi"
    - stateful: True

check_for_logback_classic:
  cmd.run:
    - name: "[ -f {{ target_path }}/lib/logback-classic-{{ logback_version }}.jar ]; if [ $? == 1 ]; then echo -e '\nchanged=true'; fi"
    - stateful: True

check_for_logback_access:
  cmd.run:
    - name: "[ -f {{ target_path }}/lib/logback-access-{{ logback_version }}.jar ]; if [ $? == 1 ]; then echo -e '\nchanged=true'; fi"
    - stateful: True

install_logback:
  module.wait:
    - name: s3.get
    - bucket: {{ s3_bucket }}
    - path: "packages/logback/logback-{{ logback_version }}.tar.gz"
    - local_file: "/tmp/logback-{{ logback_version }}.tar.gz"
    - return_bin: True
    - watch:
      - cmd: check_for_logback_core
      - cmd: check_for_logback_classic
      - cmd: check_for_logback_access
    - require:
      - module: untar-vertx
      - file: vertx_install_path

untar-logback:
  module.wait:
    - name: archive.tar
    - options: xzf
    - tarfile: /tmp/logback-{{ logback_version }}.tar.gz
    - cwd: /tmp
    - watch:
      - module: install_logback
    - require:
      - module: install_logback

deploy_logback_core:
  file.copy:
    - name: {{ target_path }}/lib/logback-core-{{ logback_version }}.jar
    - source: /tmp/logback-{{ logback_version }}/logback-core-{{ logback_version }}.jar
    - require:
      - module: untar-logback

deploy_logback_classic:
  file.copy:
    - name: {{ target_path }}/lib/logback-classic-{{ logback_version }}.jar
    - source: /tmp/logback-{{ logback_version }}/logback-classic-{{ logback_version }}.jar
    - require:
      - module: untar-logback

deploy_logback_access:
  file.copy:
    - name: {{ target_path }}/lib/logback-access-{{ logback_version }}.jar
    - source: /tmp/logback-{{ logback_version }}/logback-access-{{ logback_version }}.jar
    - require:
      - module: untar-logback

{% endif %}
