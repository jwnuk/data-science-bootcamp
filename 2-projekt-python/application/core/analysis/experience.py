import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import stats as st

# note; kod trochę spaghetti, trudno czytać, więc zakładam, że działa :) 
class ExperiencePlots:
    def __init__ (self, df):
        self.df = df
        self.total_working_years_dict = dict(self.df.TotalWorkingYears.value_counts())
        self.departments_dict = dict(self.df.Department.value_counts())
        self.departments = self.departments_dict.keys()
        
        self.df.index = pd.cut(self.df.TotalWorkingYears, bins=range(0, 48, 8))
        self.total_working_years_dict1 = dict(self.df.index.value_counts())
        self.total_working_years_list = self.total_working_years_dict1.keys()

    def plot_total_working_years_salary_dep (self, s: int, total_working_years: int, department: str):
        df = self.df
        
        for i in self.total_working_years_list:
            if total_working_years in i:
                total_working_years_total = i
        total_years_dict = dict(df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department)]['MonthlyIncome'].describe())

        employees = total_years_dict['count']
        less = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & (df['MonthlyIncome'] < s)]['MonthlyIncome'].count()
        more = df[(df['TotalWorkingYears'] .between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & (df['MonthlyIncome'] > s)]['MonthlyIncome'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)
        print(f'{less_p}% people having total experience in range of {i} years and working in department {department} earn less than you, {more_p}% of them have higher monthly income.')

        var = st.variation(df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department)]['MonthlyIncome'])

        if var > 0.10 and total_years_dict['count'] >= 15:

            if s <= total_years_dict['25%']:
                salary = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['MonthlyIncome'] <= total_years_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to first quartile.'
            elif s <= total_years_dict['50%']:
                salary = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['MonthlyIncome'] <= total_years_dict['50%']) & (df['MonthlyIncome'] > total_years_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to second quartile.'
            elif s <= total_years_dict['75%']:
                salary = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['MonthlyIncome'] <= total_years_dict['75%']) & (df['MonthlyIncome'] > total_years_dict['50%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to third quartile.'
            else:
                salary = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['MonthlyIncome'] > total_years_dict['75%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to fourth quartile.'


            plt.subplots(figsize=(8, 10))

            plt.subplot(211)
            sns.histplot(data=salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            plt.subplot(212)
            exp_salary = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department)]['MonthlyIncome']
            gen_title = print('Your monthly income compared to all of the employees with total experience in the same range of total working years and working in your department.')
            sns.histplot(data=exp_salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

        else:
            print(f'Not enough employees in database to plot a comparison. Comparing now to all of the employees having experince in the same range {i} of total working years.')

            exp_salary = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right))]['MonthlyIncome']
            gen_title = 'Your salary compared to all of the employees with your experience.'
            sns.histplot(data=exp_salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)
            
    def plot_total_working_years_job_level_dep (self, JL: int, total_working_years: int, department: int):
        df = self.df
        
        for i in self.total_working_years_list:
            if total_working_years in i:
                total_working_years_total = i

        total_years_dict = dict(df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department)]['JobLevel'].describe())

        employees = total_years_dict['count']
        less = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & (df['JobLevel'] < JL)]['JobLevel'].count()
        more = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & (df['JobLevel'] > JL)]['JobLevel'].count()
        less_p = round(100 * less / employees,2)
        more_p = round(100 * more / employees,2)
        print(f'{less_p} % people having total experience in range of {total_working_years_total} years and working in department {department} are on higher job level, {more_p}% of them works on lower job level.')

        var = st.variation(df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department)]['JobLevel'])

        if var > 0.1 and total_years_dict['count'] >= 15:
            if JL <= total_years_dict['25%']:
                job_lvl = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['JobLevel'] <= total_years_dict['25%'])]['JobLevel']
                plot_title = 'Your job level compared to first quartile.'
            elif JL <= total_years_dict['50%']:
                job_lvl = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['JobLevel'] <= total_years_dict['50%']) & (df['JobLevel'] > total_years_dict['25%'])]['JobLevel']
                plot_title = 'Your job level compared to second quartile.'
            elif JL <= total_years_dict['75%']:
                job_lvl = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['JobLevel'] <= total_years_dict['75%']) & (df['JobLevel'] > total_years_dict['50%'])]['JobLevel']
                plot_title = 'Your job level compared to third quartile.'
            else:
                job_lvl = df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department) & 
                            (df['JobLevel'] > total_years_dict['75%'])]['JobLevel']
                plot_title = 'Your job level compared to fourth quartile.'


            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.countplot(x='JobLevel', data=df[(df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)) & (df['Department'] == department)], palette='cool')
            plt.title(f'Job Level across employees working for {total_working_years} years in department {department}.')

        else:
            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.countplot(x='JobLevel', data=df[df['TotalWorkingYears'].between(total_working_years_total.left, total_working_years_total.right)], palette='cool')
            print(f'Sorry, we do not have enough data to plot job level statistics for your department.\nNow showing general statistics for employees working for {i} years.')
        plt.show()