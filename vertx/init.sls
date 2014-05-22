{% from "vertx/map.jinja" import vertx with context %}

vertx-dependencies:
  pkg.installed:
    - names:
      - wget
      - tar

check_vertx:
  cmd.run:
    - name: echo "Installing Vertx"
    - unless: "which vertx"

deploy_vertx:
  module.wait:
    - name: s3.get
    - bucket: {{ vertx.bucket }}
    - path: "packages/vertx/vert.x-{{ vertx.version }}.final.tar.gz"
    - local_file: "/tmp/vert.x-{{ vertx.version }}.final.tar.gz"
    - return_bin: True
    - required_in:
      - cmd: untar-vertx
    - watch:
      - cmd: check_vertx

untar-vertx:
  cmd.wait:
    - name: tar xzvf "/tmp/vert.x-{{ vertx.version }}.final.tar.gz" -C {{ vertx.install_path }}
    - required_in:
      - file: vertx-bin
    - watch:
      - module: deploy_vertx

vertx-bin:
  file.symlink:
    - name: {{ vertx.bin_path }}vertx
    - target: {{ vertx.install_path }}/vert.x-{{ vertx.version }}.final/bin/vertx
    - watch: 
      - cmd: untar-vertx
