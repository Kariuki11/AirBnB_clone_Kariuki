#!/usr/bin/python3
"""Script that starts flask web application
Your web application should be listening on 0.0.0.0, port 5000
"""

from flask import Flask

app = Flask("__name__")


@app.route('/', strict_slashes=False)
def hello():
    """Return a given string"""
    return ("Hello HBNB!")


if __name__ == "__main__":
    """Start the flask application"""
    app.run(host="0.0.0.0", port=5000, debug=None)