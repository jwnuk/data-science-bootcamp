import numpy as np
import pandas as pd
import pickle

class ModelHandler:
    """
    Object allows to operate on given model and provides predictions for user input.
    """    

    def __init__(self, model, df):
        """
        Constructor of class ModelHandler.
        """

        self.model = model
        self.df = df
        

    def get_features(self):
        """
        Function returns a list of features (without one hot encoding).
        """

        columns_original = set()
    
        for column in self.df.columns:
            if column[:-2] in ['class']:
                continue
            columns_original.add(column[:-2])
    
        return list(columns_original)


    def copy_df_with_nan_values(self, columns_to_nan = set(), filler = -1):
        """
        Function returns a copy from dataset with n features filled with filler.
        The filler value is set to default as -1.
        """
        
        df_copy = self.df.copy()
        
        for column in df_copy.columns:
            if column[:-2] in columns_to_nan:
                df_copy[column] = np.NaN
        
        df_copy.fillna(filler, inplace=True)
        
        return df_copy

    def test_predictions(self, n=100, df=None):
        """
        Function gives results for predictions from n random samples from dataset.
        """

        if df is None:
            df = self.df

        sample = df.sample(n)

        X_sample = sample.drop(['class_e', 'class_p'], axis=1)
        y_sample = sample['class_p']

        score = self.model.score(X_sample, y_sample)

        print(f'Model score on {n} samples: {score}')

        return score
    
        
    def get_accuracy(self, missing_features: set, n_samples=2000) -> int:
        """
        Function returns accuracy on user input data.
        """

        test_df = self.copy_df_with_nan_values(columns_to_nan=missing_features)
        return self.test_predictions(n_samples, df=test_df)
    
        
    def predict_for_user_input (self, mushroom_data: dict):
        """
        Function that predicts if the mushroom is edible or not based on user input data.
        At first it takes shroom data and puts it in to a dictionary.
        Then fills the predefined dataframe row with:
        - ones for true values,
        - zeros for false values,
        - minus ones for missing data.
        """

        missing_features = set()

        local_df = pd.DataFrame(columns=self.df.columns)
        mushroom_dict = {}

        for column in list(local_df.columns):
            if 'class' in column:
                local_df.drop(column, axis=1, inplace=True)
                continue
            value = column[-1]
            feature = column[:-2]

            if feature in mushroom_data.keys():
                if mushroom_data[feature] == value:
                    mushroom_dict[column] = 1
                else:
                    mushroom_dict[column] = 0
            else:
                mushroom_dict[column] = -1
                missing_features.add(feature)

        local_df = local_df.append(mushroom_dict, ignore_index=True)

        result = int(self.model.predict(local_df))
        acc = self.get_accuracy(missing_features)
        
        output = {
            'accuracy': acc,
            'poisonous': result
        }

        return output



class TestModel(ModelHandler):
    """
    Object provides functions to validate model's accuracy with different.
    """

    def __init__(self,  model, df):
        """
        Constructor of class TestModel.
        """
        super().__init__(model, df)
    

    def test_for_empty_feature(self, n=100):
        """
        Function removes one feature at a time and tests model accuracy for n samples.
        """

        for col in self.get_features():
            print(f'Results for {col}')
            g = self.copy_df_with_nan_values(set([col]))
            self.test_predictions(n, g)
            print('\n')
    
    def get_random_features(self, n_randoms: int):
        """
        Function creates a set with randomly chosen features from dataset.
        """
        
        columns_original = self.get_features()
        
        random_columns = set()
        
        for i in range(n_randoms):
            random_column = columns_original[np.random.randint(0, len(columns_original))]
            random_columns.add(random_column)
            columns_original.remove(random_column)
        
        return random_columns

    def test_for_missing_m_features(self, m_features=1, n_samples=100):
        """
        Function removes m features from dataset and tests predictions for n samples.
        """

        random_features = self.get_random_features(m_features)
        print(f'Removed features: {random_features}')
        self.get_accuracy(random_features, n_samples)



def pickle_model(mh: ModelHandler, filename='model_pickled.pkl'):
    with open(filename, 'wb') as file:
        pickle.dump(mh, file)


def load_model(filename='model_pickled.pkl'):
    with open(filename, 'rb') as file:
        return pickle.load(file)