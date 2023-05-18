#!/bin/bash
# Install and Setup Docker
yum update -y
yum install -y docker
usermod -a -G docker ec2-user
systemctl enable docker
systemctl start docker

# Create app artifacts
mkdir -p /tmp/tulladew/templates
echo "
<!DOCTYPE html>
<html>
<head>
    <title>Tulladew</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background-color: #121212;
        }
        .content {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
            background-color: #002400;
            border-radius: 4px;
            box-shadow: 0px 2px 4px -1px rgba(0,0,0,0.2),
                        0px 4px 5px 0px rgba(0,0,0,0.14), 
                        0px 1px 10px 0px rgba(0,0,0,0.12);
        }
        h1, pre {
            color: #008c00;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="content">
        <h1>Welcome!</h1>
        {% for key, value in data.items() %}
            <pre>{{ key }}: {{ value }}</pre>
        {% endfor %}
        <img src="https://media.tenor.com/CHc0B6gKHqUAAAAi/deadserver.gif">
    </div>
</body>
</html>
" > /tmp/tulladew/templates/index.html

# Create app py
echo "
from flask import Flask, render_template, request
from logging import getLogger
import http.client

app = Flask(__name__)

@app.route('/')
def IMDSv2():
    # Build http client 
    conn = http.client.HTTPConnection('169.254.169.254')

    # Define request headers, set token ttl
    headers = {
        'X-aws-ec2-metadata-token-ttl-seconds': '60',
    }

    # First request to get the token
    conn.request('PUT', '/latest/api/token', headers=headers)
    res = conn.getresponse()
    data = res.read()
    token = data.decode('utf-8')

    # Define headers, use received token
    headers = {
        'X-aws-ec2-metadata-token': token,
    }

    # Get instance details from service and put in dictionary
    urls = ['instance-id', 'instance-life-cycle', 'instance-type', 'local-hostname', 'local-ipv4', 'public-hostname', 'public-ipv4', 'security-groups']
    data = {}
    for url in urls:
        conn.request('GET', '/latest/meta-data/%s' % url, headers=headers)
        res = conn.getresponse()
        data[url] = res.read().decode('utf-8')
    conn.close()

    # Add info from incoming request
    data['request-user-agent'] = request.user_agent
    data['request-remote-ip'] = request.remote_addr

    # Return rendered template with data
    return render_template('index.html', data=data)

if __name__ != '__main__':
    # Set Gunicorn as log handler
    gunicornLogger = getLogger('gunicorn.error')
    app.logger.handlers = gunicornLogger.handlers
    app.logger.setLevel(gunicornLogger.level)
" > /tmp/tulladew/tulladew.py

# Create Dockerfile
echo '
# Ref: https://github.com/GoogleContainerTools/distroless/blob/main/examples/python3-requirements/Dockerfile
# Start multi-stage build from debian 11
FROM debian:11-slim AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip setuptools wheel
# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
RUN /venv/bin/pip install flask jinja2 gunicorn
# Copy the virtualenv into a distroless image
FROM gcr.io/distroless/python3-debian11
COPY --from=build-venv /venv /venv
COPY tulladew /tulladew
WORKDIR /tulladew
# Expose on port 5000
EXPOSE 5000
# Container entrypoint is Gunicorn
ENTRYPOINT ["/venv/bin/gunicorn", "-b", "0.0.0.0:5000", "tulladew:app"]' > /tmp/Dockerfile

# Build Docker image
docker build /tmp -t tulladew:v1.0

# Create Systemd service
echo "
[Unit]
Description=Tulladew Docker Container
Requires=docker.service
After=docker.service
[Service]
Type=simple
ExecStart=/usr/bin/docker run -d -p 80:5000 tulladew:v1.0
ExecStop=/usr/bin/docker stop tulladew
Restart=always
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/docker-tulladew.service

# Install, enable, and start servide
chmod 644 /etc/systemd/system/docker-tulladew.service
systemctl daemon-reload
systemctl enable docker-tulladew
systemctl start docker-tulladew