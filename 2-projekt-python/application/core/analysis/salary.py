import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
from scipy import stats as st

class SalaryPlots:
    def __init__ (self, df):
        self.df = df
        self.job_roles_dict = dict(df.JobRole.value_counts())
        self.job_levels_dict = dict(df.JobLevel.value_counts())
        self.job_roles = list(self.job_roles_dict.keys())
        self.job_levels = list(self.job_levels_dict.keys())
        
        for role in self.job_roles:
            self.vc = df[df['JobRole'] == role]['JobLevel'].value_counts()

    def plot_salary(self, s: int, job_role: str, job_lvl: int):
        df = self.df
        
        job_dict = dict(df[(df['JobRole'] == job_role) & (df['JobLevel'] == job_lvl)]['MonthlyIncome'].describe())
        df1 = df[(df['JobRole'] == job_role) & (df['JobLevel'] == job_lvl)]

        income_col = df1['MonthlyIncome']

    #     informacja o tym, jaki % pracownikow zarabia mniej/wiecej na danym stanowisku, z danym job level

        employees = job_dict['count']
        less = df1[(income_col < s)]['MonthlyIncome'].count()
        more = df1[(income_col > s)]['MonthlyIncome'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)

        variation = st.variation(df1['MonthlyIncome'])

    #     wykres jak wypadasz w kwartylu, w ktorym miesci sie dana pensja

        if variation > 0.15 and job_dict['count'] >= 24:

            if s <= job_dict['25%']:
                s_range = df1[(income_col <= job_dict['25%'])]
                plot_title = 'Your salary compared to first quartile.'
            elif s <= job_dict['50%']:
                s_range = df1[(income_col <= job_dict['50%']) & (income_col > job_dict['25%'])]
                plot_title = 'Your salary compared to second quartile.'
            elif s <= job_dict['75%']:
                s_range = df1[(income_col <= job_dict['75%']) & (income_col > job_dict['50%'])]
                plot_title = 'Your salary compared to third quartile.'
            else:
                s_range = df1[(income_col > job_dict['75%'])]
                plot_title = 'Your salary compared to fourth quartile.'

            plt.subplots(figsize=(6, 8))

            plt.subplot(211)
            sns.set_style('whitegrid')
            sns.histplot(data=s_range['MonthlyIncome'], bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

    #         wykres jak wypadasz na tle wszystkich na tym stanowisku, o takim job level

            plt.subplot(212)
            sns.set_style('whitegrid')
            gen_title = 'Your salary compared to all of the employees on your position at your level.'
            sns.histplot(data=income_col, bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

    #     w przypadku zbyt malej ilosci danych, aby podzielic na kwartyle
    #     wykres jak wypadasz na tle wszystkich na danym stanowisku (z pominieciem job level)

        else:
            print(f'Not enough employees in database to plot a comparison. Comparing now to all of the employees working as a {job_role}.')

            gen_sal = df[(df['JobRole'] == job_role)]['MonthlyIncome']
            gen_title = 'Your salary compared to all of the employees on your position.'

            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.histplot(data=gen_sal, bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)


        plt.show()
        print(f'{less_p}% people working as a {job_role} on job level {job_lvl} earns less than you, {more_p}% of them earns more.')

    def plot_salary_vs_age(self, s: int, job_role: str, age=None):
        df = self.df

    #     wykres jak wypada dana pensja w danym przedziale wiekowym

        df1 = df[df['JobRole'] == job_role]
        age_col = df1['Age']
        age_dict = dict(age_col.describe())
        q25 = age_dict['25%']
        q50 = age_dict['50%']
        q75 = age_dict['75%']

        if (age != None) & (isinstance(age, int)):

            if age < 18:
                print('Please enter valid age - at least 18 y.o.')
                return
            elif age <= q25:
                s_range = df1[age_col <= q25]
                plot_title = f'Your salary compared to employees up to {round(q25)} y.o.'
            elif age <= age_dict['50%']:
                s_range = df1[(age_col <= q50) & (age_col > q25)]
                plot_title = f'Your salary compared to employees between {round(q25)} and {round(q50)} y.o.'
            elif age <= age_dict['75%']:
                s_range = df1[(age_col <= q75) & (age_col > q50)]
                plot_title = f'Your salary compared to employees between {round(q50)} and {round(q75)} y.o.'
            else:
                s_range = df1[age_col > q75]
                plot_title = f'Your salary compared to employees over {round(q75)} y.o.'

    #         informacja o tym, jaki % pracownikow w danej grupie wiekowej zarabia mniej, a jaki % więcej

            income = s_range['MonthlyIncome']
            employees = income.count()
            less = s_range[income < s]['MonthlyIncome'].count()
            more = s_range[income > s]['MonthlyIncome'].count()
            less_p = round(100 * less / employees, 2)
            more_p = round(100 * more / employees, 2)

            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.histplot(data=s_range['MonthlyIncome'], bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            plt.show()
            print(f'{less_p}% people working as a {job_role} in your age group earns less than you, {more_p}% of them earns more.')

    #     jeśli nie podasz wieku ---> wykres zaleznosci pensji od wieku na danym stanowisku

        else:
            s_range = df1[['Age', 'MonthlyIncome']].groupby(by='Age').mean().reset_index()
            x = s_range['Age']
            y = s_range['MonthlyIncome']

            plt.figure(figsize=(6, 4))

            sns.set_style('whitegrid')
            plt.plot(x, y, marker='o')
            plt.axhline(y=s, color='r', linestyle='-', linewidth=2)
            plt.title(f'Salary depending on age. Job role: {job_role}.')
            plt.show()

    def plot_salary_vs_gender(self, s: int, job_role: str, gender=None):
        df = self.df
    #     wykres jak wypada podana pensja na tle pracownikow tej samej plci

        df1 = df[df['JobRole'] == job_role]
        gender_col = df1['Gender']

        if gender in ['Male', 'Female']:

            if gender == 'Male':
                s_range = df1[gender_col == 'Male']
                plot_title = f'Your salary compared to male employees working as a {job_role}.'
            else:
                s_range = df1[gender_col == 'Female']
                plot_title = f'Your salary compared to female employees working as a {job_role}.'

    #         informacja o tym, jaki % pracownikow o podanej plci zarabia mniej, a jaki % więcej

            income = s_range['MonthlyIncome']
            employees = income.count()
            less = s_range[income < s]['MonthlyIncome'].count()
            more = s_range[income > s]['MonthlyIncome'].count()
            less_p = round(100 * less / employees, 2)
            more_p = round(100 * more / employees, 2)

            axs = plt.subplots(figsize=(6, 8))

            ax1 = plt.subplot(211)
            sns.set_style('whitegrid')
            sns.histplot(data=s_range['MonthlyIncome'], bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            ax2 = plt.subplot(212)
            sns.set_style('whitegrid')
            sns.boxplot(data=df1, x='MonthlyIncome', y='Gender', orient='h', palette='seismic')
            sns.swarmplot(data=df1, x='MonthlyIncome', y='Gender', orient='h', color='dimgray')
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(f'Salary distribution depending on gender. Job role: {job_role}.')

            plt.show()
            print(f'{less_p}% {gender} employees working as a {job_role} less than you, {more_p}% of them earns more.')

    #     jeśli nie podasz plci ---> rozklad dla obu plci

        else:

            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.boxplot(data=df1, x='MonthlyIncome', y='Gender', orient='h', palette='seismic')
            sns.swarmplot(data=df1, x='MonthlyIncome', y='Gender', orient='h', color='dimgray')
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(f'Salary distribution depending on gender. Job role: {job_role}.')
            plt.show()