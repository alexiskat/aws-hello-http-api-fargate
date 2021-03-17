
#!/usr/bin/env python3

from flask import Flask, render_template
import boto3, requests, os, sys, json

app = Flask(__name__)
metadata_uri = "http://169.254.170.2/v2/metadata"

def get_cluster_arn():
    r = requests.get(metadata_uri)
    return r.json()['Cluster']

def get_region():
    my_session = boto3.session.Session()
    my_region = my_session.region_name
    return my_region

@app.route('/', methods = ['GET', 'POST'])
def index():
    return render_template('index.html')

@app.route('/systeminfo')
def where_am_i():
    my_region = get_region()
    cluster_arn = get_cluster_arn()
    return render_template('systeminfo.html', region=my_region,
            cluster_arn=cluster_arn)

@app.route('/health')
def health_check():
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'} 

if __name__ == '__main__':
    app.run(debug=True, port = 5000, host='0.0.0.0')