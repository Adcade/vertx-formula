{% from "vertx/defaults.jinja" import config with context %}
{% from "vertx/map.jinja" import vertx with context %}

{% set install = config('install', 'logstash_encoder') %}
{% set install_path = config('install_path', 'vertx') %}
{% set version = config('version', 'vertx') %}
{% set target_path = install_path ~ '/vert.x-' ~ version %}
{% set s3_bucket = config('s3_bucket', 'vertx') %}

{% set logstash_encoder_version = config('version', 'logstash_encoder') %}

{% if install == 'True' %}

check_for_logstash_encoder:
  cmd.run:
    - name: "[ -f {{ target_path }}/lib/logstash-logback-encoder-{{ logstash_encoder_version }}.jar ]; if [ $? == 1 ]; then echo -e '\nchanged=true'; fi"
    - stateful: True

install_logstash_encoder:
  module.wait:
    - name: s3.get
    - bucket: {{ s3_bucket }}
    - path: packages/logstash-logback-encoder/logstash-logback-encoder-{{ logstash_encoder_version }}.jar
    - local_file: {{ target_path }}/lib/logstash-logback-encoder-{{ logstash_encoder_version }}.jar
    - return_bin: True
    - watch:
      - cmd: check_for_logstash_encoder
    - require:
      - module: untar_vertx
      - file: vertx_install_path

{% endif %}
