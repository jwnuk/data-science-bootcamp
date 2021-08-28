import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import stats as st

class DistanceFromHomePlots:
    def __init__ (self, df):
        self.df = df

    def plot_distance (self, d: int, gender: str, years_at_company: int):
        df = self.df

        job_dict = dict(df[(df['Gender'] == gender) & (df['YearsAtCompany'] == years_at_company)]['DistanceFromHome'].describe())   
        df1 = df[(df['Gender'] == gender) & (df['YearsAtCompany'] == years_at_company)]  
        distance_col = df1['DistanceFromHome']

    #     Jaki % pracownikow z podziałem na płeć ma dystans do pracy mniej/wiecej biorąc pod uwagę przepracowane lata w firmie.

        employees = job_dict['count']
        less = df1[(distance_col < d)]['DistanceFromHome'].count()
        more = df1[(distance_col > d)]['DistanceFromHome'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)

        variation = st.variation(df1['DistanceFromHome'])

    #     wykres jak wypadasz w kwartylu, w ktorym miesci sie dany dystans do pracy

        if variation > 0.15 and job_dict['count'] >= 24:

            if d <= job_dict['25%']:
                d_range = df1[(distance_col <= job_dict['25%'])]
                plot_title = 'Your distance from home compared to first quartile.'
            elif d <= job_dict['50%']:
                d_range = df1[(distance_col <= job_dict['50%']) & (distance_col > job_dict['25%'])]
                plot_title = 'Your distance from home compared to second quartile.'
            elif d <= job_dict['75%']:
                d_range = df1[(distance_col <= job_dict['75%']) & (distance_col > job_dict['50%'])]
                plot_title = 'Your distance from home compared to third quartile.'
            else:
                d_range = df1[(distance_col > job_dict['75%'])]
                plot_title = 'Your distance from home compared to fourth quartile.'

            plt.subplots(figsize=(6, 8))

            plt.subplot(211)
            sns.set_style('whitegrid')
            sns.histplot(data=d_range['DistanceFromHome'], bins=10, kde=True)
            plt.axvline(x=d, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

    #         wykres jak wypadasz na tle wszystkich odnośnie dystansu z domu do pracy

            plt.subplot(212)
            sns.set_style('whitegrid')
            gen_title = 'Your distance from home compared to all of the employees on your position at your level.'
            sns.histplot(data=distance_col, bins=10, kde=True)
            plt.axvline(x=d, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

    #     w przypadku zbyt malej ilosci danych, aby podzielic na kwartyle
    #     wykres jak wypadasz na tle swojej płci (z pominieciem years at company)

        else:
            print(f'Not enough employees in database to plot a comparison. Comparing now to all of the employees grouped by gender, {gender}.')

            gen_sal = df[(df['Gender'] == gender)]['DistanceFromHome']
            gen_title = 'Your distance from home compared by your gender.'

            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.histplot(data=gen_sal, bins=10, kde=True)
            plt.axvline(x=d, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)


        plt.show()
        print(f'{less_p}% {gender} working in company for {years_at_company} years has less distance from home, {more_p}% of them has higher distance from home than you.')