# way to upload image (flask): endpoint
# save image
# function to make prediction on image
# show results
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
import warnings
import sys 

sys.path.append('../..')

#IMPORT WSSYSTKICH IMPORTÓW POTRZEBNYCH DO MODELU I PREDYKCJI
app = Flask(__name__)
UPLOAD_FOLDER =  "/C:/Users/jk/Desktop/data science - infoshare/projekt_SQL/jdszr4-edc/4-projekt-dl/app/static"
DEVICE = "cuda"
MODEL = load_model('model_tl.h5')

#PASTE MODEL HERE

#PASTE PREDICT FUNCTION
#def predict(image_path, model)

@app.route("/template", methods=["GET", "POST"])
def upload_predict():
    if request.method == "POST":
        image_file = request.files["image"]
        if image_file:
            image_location = os.path.join(
                UPLOAD_FOLDER,
                image_file.filename
            )
            image_file.save(image_location)
            pred = predict(image_location, MODEL)[0]
            return render_template("index.html", prediction=pred, image_loc = image_file.filename)
    return render_template("index.html", prediction=0, image_loc = None)

if __name__ == "__main__":
    app.run(debug=True)


