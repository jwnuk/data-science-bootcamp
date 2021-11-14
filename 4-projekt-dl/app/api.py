import os
from flask import Flask
from flask import render_template, request, send_from_directory
import numpy as np
import os
import sys
import prediction_for_app as pfa

sys.path.append('../..')

app = Flask(__name__, template_folder='./template')
UPLOAD_FOLDER =  "./public"
MODEL = pfa.DLModel('../../4-projekt-dl/model_tl.h5', '../../4-projekt-dl/weights/model_tl', (224, 224))

@app.route("/", methods=["GET", "POST"])
def index():
    return render_template("index.html")

@app.route('/upload', methods=['POST', 'GET'])
def upload():
    image_file = request.files["image"]
    image_location = os.path.join(
                UPLOAD_FOLDER,
                image_file.filename
                )
    image_file.save(image_location) # do not serve in production, unsecure ;)
    pred = MODEL.predict_for_user_input(image_location)
    return render_template("index.html", prediction = pred, image_loc = image_file.filename)
    
# serve uploads
@app.route('/public/<path:path>')
def send_js (path):
    return send_from_directory('public', path)

if __name__ == "__main__":
    app.run(debug=True)