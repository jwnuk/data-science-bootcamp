import json
from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin

import sys 
sys.path.append('../..')

import scoring as sc

app = Flask(__name__)
cors = CORS(app)

app.config['CORS_HEADERS'] = 'Content-Type'

model = sc.load_model('../../models/logistic-regression/logistic-regression.pkl')

@app.route('/api/config', methods=['GET'])
@cross_origin()
def config():
  data = open('config.json')
  output = jsonify(json.load(data)) 
  data.close()
  return output

@app.route('/api/predict',methods=['POST'])
@cross_origin()
def results():
    data = request.get_json(force=True)
    prediction = model.predict_for_user_input(data)
    return jsonify(prediction)

if __name__ == "__main__":
    app.run(debug=False)