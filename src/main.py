from flask import Flask, render_template
import os

app = Flask(__name__)

@app.route('/', defaults={'name': 'World'})
@app.route('/<string:name>')
def index(name):
    return render_template('index.html',
                           name=name, environment=os.getenv("ENVIRONMENT","staging"),
                           backgroundcolor=os.getenv("BG_COLOR", "pink"),
                           foregroundcolor=os.getenv("FG_COLOR", "green"))