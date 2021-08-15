import numpy as np
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
from scipy import stats as st

class EducationPlots:
    def __init__ (self, df):
        self.df = df
        
    def plot_eductaion_salary (self, s: int, education_field, eductaion_level):
        df = self.df

        edu_dict = dict(df[(df['EducationField'] == education_field) 
                           & (df['Education'] == eductaion_level)]['MonthlyIncome'].describe())

        employees = edu_dict['count']
        less = df[(df['EducationField'] == education_field) & (df['Education'] == eductaion_level) 
                  & (df['MonthlyIncome'] < s)]['MonthlyIncome'].count()
        more = df[(df['EducationField'] == education_field) & (df['Education'] == eductaion_level)
                  & (df['MonthlyIncome'] > s)]['MonthlyIncome'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)
        print(f'{less_p}% people having eductaion in {education_field} on level {eductaion_level} earns less than you,'
              f' {more_p}% of them earns more.')

        var = st.variation(df[(df['EducationField'] == education_field) 
                              & (df['Education'] == eductaion_level)]['MonthlyIncome'])

        if var > 0.15 and edu_dict['count'] >= 15:

            if s <= edu_dict['25%']:
                salary = df[(df['EducationField'] == education_field) 
                            & (df['Education'] == eductaion_level) 
                            & (df['MonthlyIncome'] <= edu_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to first quartile.'

            elif s <= edu_dict['50%']:
                salary = df[(df['EducationField'] == education_field) 
                            & (df['Education'] == eductaion_level) 
                            & (df['MonthlyIncome'] <= edu_dict['50%']) 
                            & (df['MonthlyIncome'] > edu_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to second quartile.'

            elif s <= edu_dict['75%']:
                salary = df[(df['EducationField'] == education_field) 
                            & (df['Education'] == eductaion_level)
                            & (df['MonthlyIncome'] <= edu_dict['75%']) 
                            & (df['MonthlyIncome'] > edu_dict['50%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to third quartile.'
            else:
                salary = df[(df['EducationField'] == education_field) 
                            & (df['Education'] == eductaion_level)
                            & (df['MonthlyIncome'] > edu_dict['75%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to fourth quartile.'

            plt.subplots(figsize=(8, 12))

            plt.subplot(211)
            sns.histplot(data=salary, bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            plt.subplot(212)
            gen_sal = df[(df['EducationField'] == education_field) & (df['Education'] == eductaion_level)]['MonthlyIncome']
            gen_title = 'Your salary compared to all of the employees with the same level of eductaion in the same eduction field.'
            sns.histplot(data=gen_sal, bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

        else:
            print(f'Not enough employees in database to plot a comparison. Comparing now to all of the employees'
                  f' having education in {education_field}.')

            gen_sal = df[(df['EducationField'] == education_field)]['MonthlyIncome']
            gen_title = 'Your salary compared to all of the employees with your eductaion.'
            sns.histplot(data=gen_sal, bins=10, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)
            
    def plot_eductaion_job_level(self, s: int, education_field, eductaion_level):
        df = self.df

        edu_dict = dict(df[(df['EducationField'] == education_field)
                           & (df['Education'] == eductaion_level)]['JobLevel'].describe())

        employees = edu_dict['count']
        less = df[(df['EducationField'] == education_field)
                  & (df['Education'] == eductaion_level) 
                  & (df['JobLevel'] < s)]['JobLevel'].count()
        more = df[(df['EducationField'] == education_field) 
                  & (df['Education'] == eductaion_level) 
                  & (df['JobLevel'] > s)]['JobLevel'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)
        print(f'{less_p}% people having eductaion in {education_field} on level {eductaion_level} are hired on lower job level,'
              f' {more_p}% of them is hired on higer job level.')

        var = st.variation(df[(df['EducationField'] == education_field) 
                              & (df['Education'] == eductaion_level)]['JobLevel'])

        if var > 0.10 and edu_dict['count'] >= 15:

            if s <= edu_dict['25%']:
                job_lvl = df[(df['EducationField'] == education_field) 
                             & (df['Education'] == eductaion_level)  
                             & (df['JobLevel'] <= edu_dict['25%'])]['JobLevel']
                plot_title = 'Your job level compared to first quartile.'
            elif s <= edu_dict['50%']:
                job_lvl = df[(df['EducationField'] == education_field) 
                             & (df['Education'] == eductaion_level) 
                             & (df['JobLevel'] <= edu_dict['50%']) 
                             & (df['JobLevel'] > edu_dict['25%'])]['JobLevel']
                plot_title = 'Your job level compared to second quartile.'
            elif s <= edu_dict['75%']:
                job_lvl = df[(df['EducationField'] == education_field) 
                             & (df['Education'] == eductaion_level) 
                             & (df['JobLevel'] <= edu_dict['75%']) 
                             & (df['JobLevel'] > edu_dict['50%'])]['JobLevel']
                plot_title = 'Your job level compared to third quartile.'
            else:
                job_lvl = df[(df['EducationField'] == education_field) 
                             & (df['Education'] == eductaion_level)
                             & (df['JobLevel'] > edu_dict['75%'])]['JobLevel']
                plot_title = 'Your job level compared to fourth quartile.'


            plt.subplots(figsize=(8, 10))

            plt.subplot(211)
            sns.histplot(data=job_lvl, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            plt.subplot(212)
            gen_job_lvl = df[(df['EducationField'] == education_field) 
                             & (df['Education'] == eductaion_level)]['JobLevel']
            gen_title = 'Your job level compared to all of the employees with the same level of eductaion in the same eduction field.'
            sns.histplot(data=gen_job_lvl, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

        else:
            print(f'Not enough employees in database to plot a comparison. Comparing now to all of the employees '
                  f'having education in {education_field}.')

            gen_job_lvl = df[(df['EducationField'] == education_field)]['JobLevel']
            gen_title = 'Your job level compared to all of the employees with your eductaion.'
            sns.histplot(data=gen_job_lvl, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)
            
    def plot_attrition (self, education_field, eductaion_level):
        df = self.df

        df1 = df[(df['EducationField'] == education_field) & (df['Education'] == education_field)]

        if df1['Attrition'].count() > 0 and len(df1['Attrition'].unique()) == 2:
            sns.histplot(df1, x="Attrition", hue="cut", multiple="stack", palette="light:m_r", edgecolor=".3", 
                         linewidth=.5, log_scale=True)
            ax.xaxis.set_major_formatter(mpl.ticker.ScalarFormatter())
            ax.set_xticks([500, 1000, 2000, 5000, 10000])
            
    def plot_education_attrition (self, education_field: str, eductaion_level: int):
        df = self.df

        df1 = df[(df['EducationField'] == education_field) & (df['Education'] == eductaion_level)]

        if df1['Attrition'].count() > 0 and len(df1['Attrition'].unique()) == 2:
            print("Showing Attrition statistic for people with the same eductaion level on the same education field")
            sns.displot(df1, x= 'EducationField', hue= 'Attrition', hue_order=[True, False])
        else:
            print("Not enough data for your education level in indicated education field. Shoiwng general data for your field")
            sns.displot(x='Education', hue='Attrition', data=df[df['EducationField'] == education_field], 
                        hue_order=[True, False])
            
    def plot_education_overtme(self, education_field: str, education_level: int):
        df = self.df

        df1 = df[(df['EducationField'] == education_field) & (df['Education'] == education_level)]

        if df1['OverTime'].count() > 0 and len(df1['OverTime'].unique()) == 2:
            print("Showing how many people with the same eductaion level on the same education field work over time")
            sns.displot(df1, x= 'EducationField', hue= 'OverTime', hue_order=[True, False])
        else:
            print("Not enough data for your education level in indicated education field. Shoiwng general data for your field")
            sns.displot(x='Education', hue='OverTime', data=df[df['EducationField'] == education_field], 
                        hue_order=[True, False])
            
    def plot_satisfaction_education(self, js: int, rs: int, es:int, education_field: str, education_level: int):
        df = self.df
    #     wykres jak wypada podana pensja na tle pracownikow tej samej plci
        df1 = df[(df['EducationField']==education_field) & (df['Education'] == education_level)]
        job_sat_col = df1['JobSatisfaction'].mean()
        relationship_sat_col = df1['RelationshipSatisfaction'].mean()
        environment_sat_col = df1['EnvironmentSatisfaction'].mean()

        job_sat_you = js
        relationship_sat_you = rs
        environment_sat_you = es     

        if len(df1) >2: 
            w=0.2
            x = ['job satisfaction', 'relationship satisfaction', 'environment satisafction']
            you = [job_sat_you, relationship_sat_you, environment_sat_you]
            others = [job_sat_col, relationship_sat_col, environment_sat_col]

            bar1 = np.arange(len(x))
            bar2 = [i+w for i in bar1]


            plt.bar(bar1, you, w, label= 'you')
            plt.bar(bar2, others, w, label='others')

            # Add some text for labels, title and custom x-axis tick labels, etc.
            plt.ylabel('Satsifaction Level')
            plt.xlabel('Satisfaction')
            plt.title('Your satisafction levels compared to satisfaction levels of people with the same level' 
                      ' of education in the same education field')
            plt.xticks(bar1+w/2, x)
            plt.legend()
            plt.show()
        else:
            print('Not enough data to show comparison')