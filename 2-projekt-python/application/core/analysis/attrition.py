import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
from scipy import stats as st

class AttritionPlots:
    def __init__ (self, df):
        self.df = df
            
    def plot_attrition(self, job_role: str, job_level: int):
        df = self.df
        #     funkcja rysujaca wykres opisujacy liczbe pracownikow odchodzacych z firmy

        df1 = df[(df['JobRole'] == job_role) & (df['JobLevel'] == job_level)];
        if df1['Attrition'].count() > 0 and len(df1['Attrition'].unique()) == 2:

    #         jesli jest wystarczajaca ilosc danych (dla danego job role istnieja pracownicy o danym job level
    #         oraz jesli dla danego job level sa pracownicy z Attrition=True oraz Attrition=False)

            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.countplot(x='Attrition', data=df1, palette='cool')
            plt.title(f'Attrition across employees working as a {job_role} on level {job_level}.')

        else:

    #         jesli nie ma wystarczajaco danych funkcja rysuje ogolne zestawienie dla danego job role

            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.countplot(x='JobLevel', hue='Attrition', data=df[df['JobRole'] == job_role], palette='cool')
            print(f'Sorry, we do not have enough data to plot attrition statistics for your job level.\nNow showing general statistics for employees working as a {job_role}.')
        plt.show()

    def attrition_rankings(self, job_role: str):
        df = self.df
        df1 = df[(df['JobRole'] == job_role) & (df['Attrition'] == True)]

    #     filtrowanie pojedynczych rekordow
        df1 = df1.groupby('JobLevel').filter(lambda x: x.shape[0] > 4)

        plt.figure(figsize=(6, 2))
        sns.set_style('whitegrid')
        sns.boxplot(x='Age', y='JobLevel', data=df1, orient='h', palette='cool')
        plt.title('Employee attrition, age distribution')

        plt.figure(figsize=(6, 2))
        sns.set_style('whitegrid')
        sns.boxplot(x='MonthlyIncome', y='JobLevel', data=df1, orient='h', palette='cool')
        plt.title('Employee attrition, salary distribution')

        plt.show()