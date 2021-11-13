import tensorflow as tf
import numpy as np
import PIL
from keras.models import load_model

class DLModel:
    def __init__(self, model_path, weights_path):
        """
        Constructor of class DLModel.
        """

        self.model = load_model(model_path)
        self.model.load_weights(weights_path)

    def preprocess_image(self, image_path):
        image = PIL.Image.open(str(image_path)).resize((224, 224))
        to_predict = np.array(image)
        return to_predict

    def predict_for_user_input(self, image_path):
        to_predict = self.preprocess_image(image_path)
        prediction = self.model.predict(to_predict[np.newaxis, ...])
        return 'Healthy' if prediction > 0 else 'Brain tumor'

