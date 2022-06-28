import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def _app():
    return 'Check /version !'

@app.route('/version')
def version():
    data = str("Version: "+ os.environ["version"])
    return data

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=8080)