FROM grafana/grafana:10.4.0

# Grafana runs as non-root user 'grafana' (uid 472)
USER root

# Copy custom dashboards and datasource provisioning
COPY provisioning/ /etc/grafana/provisioning/
COPY dashboards/ /var/lib/grafana/dashboards/

# Fix permissions
RUN chown -R grafana:grafana /etc/grafana/provisioning /var/lib/grafana/dashboards

USER grafana

# Environment variables (can be overridden via Helm values / K8s secrets)
ENV GF_SECURITY_ADMIN_USER=admin \
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning \
    GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/gameserver-overview.json

EXPOSE 3000
