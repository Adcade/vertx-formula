{% from "vertx/defaults.jinja" import config with context %}
{% from "vertx/map.jinja" import vertx with context %}

{% set install = config('install', 'slf4j') %}
