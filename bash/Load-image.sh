docker save goharbor/harbor-adminserver:v1.6.0  | gzip  > harbor-adminserver-dev.tar.gz
docker save goharbor/harbor-ui:v1.6.0  | gzip  > harbor-ui-dev.tar.gz
docker save goharbor/harbor-db:v1.6.0  | gzip > harbor-db-dev.tar.gz
docker save goharbor/harbor-jobservice:v1.6.0  | gzip > harbor-jobservice-dev.tar.gz
docker save goharbor/chartmuseum-photon:v0.7.1-v1.6.0  | gzip > chartmuseum-photon-v0.7.1-v1.6.0.tar.gz
docker save goharbor/redis-photon:v1.6.0    | gzip > redis-photon-v1.6.0.tar.gz
docker save goharbor/clair-photon:v2.0.5-v1.6.0        | gzip > clair-photon-v2.0.5-v1.6.0.tar.gz
docker save goharbor/registry-photon:v2.6.2-v1.6.0     | gzip >  registry-photon-v2.6.2-v1.6.0.tar.gz
docker save goharbor/nginx-photon:v1.6.0               | gzip >  nginx-photon-v1.6.0.tar.gz
docker save goharbor/harbor-log:v1.6.0                 | gzip >  harbor-log-v1.6.0.tar.gz
docker save goharbor/harbor-clarity-ui-builder:1.6.0   | gzip >  harbor-clarity-ui-builder-1.6.0.tar.gz