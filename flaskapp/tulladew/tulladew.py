from flask import Flask, render_template, request
from logging import getLogger
import http.client

app = Flask(__name__)

@app.route('/')
def IMDSv2():
    """
    Access AWS Instance Metadata Service v2. 
    Renders a Flask HTTP response based on a jinja2 template, containing incoming request and IMDSv2 query data.
    """

    # Build http client 
    conn = http.client.HTTPConnection("169.254.169.254")

    # Define request headers, set token ttl
    headers = {
        'X-aws-ec2-metadata-token-ttl-seconds': '60',
    }

    # First request to get the token
    conn.request("PUT", "/latest/api/token", headers=headers)
    res = conn.getresponse()
    data = res.read()
    token = data.decode("utf-8")

    # Define headers, use received token
    headers = {
        'X-aws-ec2-metadata-token': token,
    }

    # Get instance details from service and put in dictionary
    urls = ['instance-id', 'instance-life-cycle', 'instance-type', 'local-hostname', 'local-ipv4', 'public-hostname', 'public-ipv4', 'security-groups']
    data = {}
    for url in urls:
        conn.request("GET", "/latest/meta-data/%s" % url, headers=headers)
        res = conn.getresponse()
        data[url] = res.read().decode("utf-8")
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