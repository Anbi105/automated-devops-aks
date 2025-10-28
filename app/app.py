# app/app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    # This message verifies the successful deployment to AKS
    return '<h1>Hello DevOps Project! Running on Azure Kubernetes Service (AKS).</h1>'

if __name__ == '__main__':
    # Flask runs on port 5000 by default
    app.run(debug=True, host='0.0.0.0', port=5000)