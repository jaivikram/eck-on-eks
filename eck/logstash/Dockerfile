ARG logstash_version
FROM docker.elastic.co/logstash/logstash:${logstash_version}
COPY templates /usr/share/logstash/config/templates/
RUN bin/logstash-plugin install logstash-input-kinesis