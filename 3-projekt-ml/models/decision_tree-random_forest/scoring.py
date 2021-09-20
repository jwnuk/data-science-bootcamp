import numpy as np
import pandas as pd

class ModelHandler:

    def __init__(self, model, df):
        self.model = model
        self.df = df
    
    
    def predict_for_user_input (self, mushroom_data: dict):
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


        local_df = local_df.append(mushroom_dict, ignore_index=True)
        return int(self.model.predict(local_df))
    
    def get_features(self):
        columns_original = set()
    
        for column in self.df.columns:
            if column[:-2] in ['class']:
                continue
            columns_original.add(column[:-2])
    
        return list(columns_original)

class TestModel(ModelHandler):

    def __init__(self,  model, df):
        super().__init__(model, df)

    def shroom_check(self, sample, prediction: int):
        """
        Function checks if prediction was consistent with the class value from original dataframe.
        """
        
        ix = sample.index[0]
        result = prediction == self.df.iloc[ix]['class_p']

        return result

    def test_predictions(self, n=100, df=None):
        """
        Function gives results for n iteration of prediction from random samples from dataset.
        """

# TO DO: replace shroom_check with model.score (preparation of y needed)

        self.get_features()

        if df is None:
            df = self.df

        correct_values = 0
        i = 0
        X = df.copy(deep=False)
        
        for col in X.columns:
            if 'class' in col:
                X.drop(col, axis=1, inplace=True)
        
        while i < n:
            sample = X.sample()
            prediction = int(self.model.predict(sample))
            check = self.shroom_check(sample, prediction)
        
            if check == True:
                correct_values += 1
            
            i += 1

        print(f'True predictions: {correct_values} ({100 * correct_values / n}%)')
        print(f'False predictions: {n - correct_values} ({100 - 100 * correct_values / n}%)')
    
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

    def test_for_empty_feature(self):

        for col in self.get_features():
            print(f'Results for {col}')
            g = self.copy_df_with_nan_values(set([col]))
            self.test_predictions(100, g)
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

    def test_for_missing_n_features(self, n: int):

        random_features = self.get_random_features(n)
        print(f'Removed features: {random_features}')
        test_df = self.copy_df_with_nan_values(random_features)
        self.test_predictions(df=test_df)