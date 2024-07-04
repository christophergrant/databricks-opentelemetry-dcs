# Use the specified Databricks runtime as a parent image
FROM databricksruntime/standard-test:14.3-LTS

# Set the working directory
WORKDIR /usr/src/app

# Install wget and pip packages
RUN apt-get update && apt-get install -y wget supervisor && \
  pip install opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-logging opentelemetry-exporter-otlp

# Download and install Go
RUN wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz && \
  rm -rf /usr/local/go && \
  tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH=$PATH:/usr/local/go/bin
RUN /usr/local/go/bin/go env -w GOPATH=/go
ENV PATH=$PATH:/go/bin

# Install the OpenTelemetry Collector builder
RUN /usr/local/go/bin/go install go.opentelemetry.io/collector/cmd/builder@latest

# Create the /opentelemetry directory
RUN mkdir -p /opentelemetry

# Copy the configuration files into the container
COPY include/otelcol-build.yaml /opentelemetry/otelcol-build.yaml
COPY include/otelcol.yaml /opentelemetry/otelcol.yaml

# Build the OpenTelemetry Collector
RUN /go/bin/builder --config=/opentelemetry/otelcol-build.yaml

RUN mkdir -p /etc/supervisor/conf.d

COPY include/otelcol-supervisord.conf /etc/supervisor/conf.d/otelcol-supervisord.conf

COPY include/init.sh /opentelemetry/init.sh


# Expose port
EXPOSE 4317

