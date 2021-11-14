import tensorflow as tf
import numpy as np
import PIL
from keras.models import load_model

class DLModel:
    def __init__(self, model_path, weights_path, dim: tuple):
        """
        Constructor of class DLModel.
        """

        self.model = load_model(model_path)
        self.model.load_weights(weights_path)
        self.dim = dim

    def preprocess_image(self, image_path):
        """
        Function takes path to file and prepares image for prediction in a way that model accepts it.
        """

        image = PIL.Image.open(str(image_path)).resize(self.dim)
        to_predict = np.array(image)
        return to_predict

    def predict_for_user_input(self, image_path):
        """
        Function predicts if the brain on the photo is a healthy one or with a tumor.
        """

        to_predict = self.preprocess_image(image_path)
        prediction = self.model.predict(to_predict[np.newaxis, ...])
        return 'Guz mózgu niewykryty' if prediction > 0 else 'Guz mózgu wykryty'

