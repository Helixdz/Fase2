FROM prom/prometheus:v2.51.0

COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY rules/ /etc/prometheus/rules/

# Prometheus runs as nobody (uid 65534) by default
USER nobody

EXPOSE 9090

ENTRYPOINT ["/bin/prometheus"]
CMD [ \
  "--config.file=/etc/prometheus/prometheus.yml", \
  "--storage.tsdb.path=/prometheus", \
  "--web.console.libraries=/usr/share/prometheus/console_libraries", \
  "--web.console.templates=/usr/share/prometheus/consoles", \
  "--web.enable-lifecycle" \
]
