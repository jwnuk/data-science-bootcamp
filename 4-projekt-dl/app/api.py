import os
from flask import Flask
from flask import render_template, request
import numpy as np
import pathlib
import PIL
import os
import tensorflow as tf
import tensorflow_datasets as tfds
import matplotlib.pyplot as plt
import seaborn as sns
from tensorflow import keras
from tensorflow.keras import models
import sys
import prediction_for_app as pfa

sys.path.append('../..')

path_parent =os.path.dirname(os.getcwd())
model_path = os.path.join(path_parent, 'C://Users//jk//Desktop//data science - infoshare//projekt_SQL//jdszr4-edc//4-projekt-dl//transfer_learning//model_tl.h5')
model_init  = pfa.DLModel(model_path, '../../weights/model_tl', (224, 224))

app = Flask(__name__, template_folder='./template')
UPLOAD_FOLDER =  ".../.../app/static"
MODEL = models.load_model(model_init)

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
    image_file.save(image_location)
    return redirect('/predict')

@app.route('/predict', methods = ['GET','POST'])
def predict():
    image_file = request.files["image"]
    image_location = os.path.join(
                UPLOAD_FOLDER,
                image_file.filename
                )
    image.save(image_location)
    pred = model.predict(image_location, MODEL)[0]
    return render_template("index.html", prediction =pred, image_loc = image_file.filename)
    
if __name__ == "__main__":
    app.run(debug=True)