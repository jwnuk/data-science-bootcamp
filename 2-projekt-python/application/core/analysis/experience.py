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
        self.years_in_curr_role_dict = dict(df.YearsInCurrentRole.value_counts())
        self.departments_dict = dict(df.Department.value_counts())
        
        df.index = pd.cut(df.YearsInCurrentRole, bins=range(0,19,3))
        self.years_in_curr_role_dict = dict(df.index.value_counts())
        self.years_in_curr_role_list = self.years_in_curr_role_dict.keys()
        
        self.years_at_company_dict = dict(df.YearsAtCompany.value_counts())
        self.departments_dict = dict(df.Department.value_counts())
        self.departments = self.departments_dict.keys()
        df.index = pd.cut(df.YearsAtCompany, bins=range(0,48,8))
        self.years_at_comp_dict = dict(df.index.value_counts())
        self.years_at_comp_list = self.years_at_comp_dict.keys()
        
    def plot_satisfaction_years_in_curr_role_dep(self, js: int, rs: int, es:int, years_in_curr_role: int, department: int):
        df = self.df
        years_in_curr_role_list = self.years_in_curr_role_list
        for i in years_in_curr_role_list:
            if years_in_curr_role in i:
                years_in_curr_role_total = i

        dfc = df[(df['YearsInCurrentRole'].between( years_in_curr_role_total.left,  years_in_curr_role_total.right)) 
                 & (df['Department'] == department)]
        job_sat_col = dfc['JobSatisfaction'].mean()
        relationship_sat_col = dfc['RelationshipSatisfaction'].mean()
        environment_sat_col = dfc['EnvironmentSatisfaction'].mean()

        job_sat_you = js
        relationship_sat_you = rs
        environment_sat_you = es     

        if len(dfc) >2:
            plt.figure(figsize=(8, 6))   
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
            plt.title('Your satisfaction levels compared to average satisfaction levels of people having having the same'
                      ' experience in current role and working in the same department')
            plt.xticks(bar1+w/2, x)
            plt.legend()
            plt.show()
        else:
            print('Not enough data to show comparison')
            
    def plot_years_in_curr_role_position_salary_pos(self, s: int, years_in_curr_role: int, position: str):
        df = self.df
        years_in_curr_role_list = self.years_in_curr_role_list
        for i in years_in_curr_role_list:
            if years_in_curr_role in i:
                years_in_curr_role_total = i

        years_in_curr_role_dict = dict(df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                                          & (df['JobRole'] == position)]['MonthlyIncome'].describe())

        employees =  years_in_curr_role_dict['count']
        less = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                  & (df['JobRole'] == position) & (df['MonthlyIncome'] < s)]['MonthlyIncome'].count()
        more = df[(df['YearsInCurrentRole'] .between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                  & (df['JobRole'] == position) & (df['MonthlyIncome'] > s)]['MonthlyIncome'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)
        print(f'{less_p}% people having exeprience in current role in range of {i} years and working on the same position' 
              f'{position} earn less than you, {more_p}% of them have higher monthly income.')

        var = st.variation(df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                              & (df['JobRole'] == position)]['MonthlyIncome'])

        if var > 0.10 and  years_in_curr_role_dict['count'] >= 15:

            if s <=  years_in_curr_role_dict['25%']:
                salary = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] <= years_in_curr_role_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to first quartile.'
            elif s <=  years_in_curr_role_dict['50%']:
                salary = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] <= years_in_curr_role_dict['50%']) 
                            & (df['MonthlyIncome'] > years_in_curr_role_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to second quartile.'
            elif s <=  years_in_curr_role_dict['75%']:
                salary = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] <= years_in_curr_role_dict['75%']) 
                            & (df['MonthlyIncome'] > years_in_curr_role_dict['50%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to third quartile.'
            else:
                salary = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] > years_in_curr_role_dict['75%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to fourth quartile.'


            plt.subplots(figsize=(8, 10))

            plt.subplot(211)
            sns.histplot(data=salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            plt.subplot(212)
            exp_salary = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right)) 
                            & (df['JobRole'] == position)]['MonthlyIncome']
            gen_title = print('Your monthly income compared to all of the employees with experience in current role'
                              'in the same range and working in on the same position.')
            sns.histplot(data=exp_salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

        else:
            print(f'Not enough employees in database to plot a comparison. Comparing now to all of the employees having' 
                  f'experince in current orle in the same range of {i} years.')

            exp_salary = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, 
                                                              years_in_curr_role_total.right))]['MonthlyIncome']
            gen_title = f'Your salary compared to all of the employees with experience in current role in the same range of {i} years.'
            sns.histplot(data=exp_salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)
            
    # Poziomy staysfakcji dla pracowników o tym samym stażu na danym stanowisku - ot bym zostawiła
    def plot_satisfaction_years_in_curr_role_position(self, js: int, rs: int, es:int, years_in_curr_role: int, position: str):
        df = self.df
        years_in_curr_role_list = self.years_in_curr_role_list
        for i in years_in_curr_role_list:
            if years_in_curr_role in i:
                years_in_curr_role_total = i

        dfc = df[(df['YearsInCurrentRole'].between(years_in_curr_role_total.left, years_in_curr_role_total.right))
                 & (df['JobRole'] == position)]
        job_sat_col = dfc['JobSatisfaction'].mean()
        relationship_sat_col = dfc['RelationshipSatisfaction'].mean()
        environment_sat_col = dfc['EnvironmentSatisfaction'].mean()

        job_sat_you = js
        relationship_sat_you = rs
        environment_sat_you = es     

        if len(dfc) >2:
            plt.figure(figsize=(8, 6))   
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
            plt.title('Your satisfaction levels compared to average satisfaction levels of people having having'
                      ' the same experience in current role and working in the same department')
            plt.xticks(bar1+w/2, x)
            plt.legend()
            plt.show()
        else:
            print('Not enough data to show comparison')

    def plot_current_role_overtime_position(self, position: str, years_in_curr_role: int):
        df = self.df
        years_in_curr_role_list = self.years_in_curr_role_list
        for i in years_in_curr_role_list:
            if years_in_curr_role in i:
                years_in_curr_role_total = i

        df1 = df[(df['YearsInCurrentRole'].between( years_in_curr_role_total.left,  years_in_curr_role_total.right)) 
                 & (df['JobRole'] == position)]

        if df1['OverTime'].count() > 0 and len(df1['OverTime'].unique()) == 2:
            print("Showing OverTime statistics for people with experience on the same position within the same range of years")
            sns.displot(df1, x= 'YearsInCurrentRole', hue= 'OverTime', hue_order=[True, False])
        else:
            print("Not enough data with experience in the same range on the same position. Showing general data for people with experience in current role within the same range of years")
            sns.displot(x='YearsInCurrentRole', hue='OverTime', data=df[df['YearsInCurrentRole'] == years_in_curr_role], 
                        hue_order=[True, False])
                  
    def plot_years_at_comp_salary_pos(self, s: int, years_at_comp: int, position: str):
        years_at_comp_total = None # hotfix
        
        df = self.df
        years_at_comp_list = self.years_at_comp_list
        for i in years_at_comp_list:
            if years_at_comp in i:
                years_at_comp_total = i
        years_at_comp_dict = dict(df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                                     & (df['JobRole'] == position)]['MonthlyIncome'].describe())

        employees = years_at_comp_dict['count']
        less = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                  & (df['JobRole'] == position) 
                  & (df['MonthlyIncome'] < s)]['MonthlyIncome'].count()
        more = df[(df['YearsAtCompany'] .between(years_at_comp_total.left, years_at_comp_total.right)) 
                  & (df['JobRole'] == position) 
                  & (df['MonthlyIncome'] > s)]['MonthlyIncome'].count()
        less_p = round(100 * less / employees, 2)
        more_p = round(100 * more / employees, 2)
        print(f'{less_p}% people working in the company for the range of {i} years and working on the same position'
              f' {position} earn less than you, {more_p}% of them have higher monthly income.')

        var = st.variation(df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                              & (df['JobRole'] == position)]['MonthlyIncome'])

        if var > 0.10 and years_at_comp_dict['count'] >= 15:

            if s <= years_at_comp_dict['25%']:
                salary = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] <= years_at_comp_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to first quartile.'
            elif s <= years_at_comp_dict['50%']:
                salary = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] <= years_at_comp_dict['50%']) 
                            & (df['MonthlyIncome'] > years_at_comp_dict['25%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to second quartile.'
            elif s <= years_at_comp_dict['75%']:
                salary = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] <= years_at_comp_dict['75%']) 
                            & (df['MonthlyIncome'] > years_at_comp_dict['50%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to third quartile.'
            else:
                salary = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                            & (df['JobRole'] == position) 
                            & (df['MonthlyIncome'] > years_at_comp_dict['75%'])]['MonthlyIncome']
                plot_title = 'Your salary compared to fourth quartile.'


            plt.subplots(figsize=(8, 10))

            plt.subplot(211)
            sns.histplot(data=salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(plot_title)

            plt.subplot(212)
            exp_salary = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                            & (df['JobRole'] == position)]['MonthlyIncome']
            gen_title = print('Your monthly income compared to all of the employees working at the company for'
                              ' the same range of years and at the same position.')
            sns.histplot(data=exp_salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)

        else:
            print(f'Not enough employees in database to plot a comparison.'
                  f'Comparing now to all of the employees working in the company for the same range {i} years.')

            exp_salary = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right))]['MonthlyIncome']
            gen_title = 'Your salary compared to all of the employees with your experience.'
            sns.histplot(data=exp_salary, bins=4, cumulative=True, kde=True)
            plt.axvline(x=s, color='r', linestyle='-', linewidth=2)
            plt.title(gen_title)
                  
    def plot_years_at_comp_job_level_pos(self, JL: int, years_at_comp: int, position: str):
        years_at_comp_total = None # hotfix
        df = self.df
        years_at_comp_list = self.years_at_comp_list
        for i in years_at_comp_list:
            if years_at_comp in i:
                years_at_comp_total = i

        years_at_comp_dict = dict(df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                                     & (df['JobRole'] == position)]['JobLevel'].describe())


        employees = years_at_comp_dict['count']
        less = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                  & (df['JobRole'] == position) 
                  & (df['JobLevel'] < JL)]['JobLevel'].count()
        more = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                  & (df['JobRole'] == position) 
                  & (df['JobLevel'] > JL)]['JobLevel'].count()
        less_p = round(100 * less / employees,2)
        more_p = round(100 * more / employees,2)
        print(f'{less_p} % people having experience in their current role in range of {years_at_comp_total}'
              f' years and working as {position} are on higher job level, {more_p}% of them works on lower job level.')

        var = st.variation(df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                              & (df['JobRole'] == position)]['JobLevel'])

        if var > 0.1 and years_at_comp_dict['count'] >= 15:
            if JL <= years_at_comp_dict['25%']:
                job_lvl = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                             & (df['JobRole'] == position) 
                             & (df['JobLevel'] <= years_at_comp_dict['25%'])]['JobLevel']
                plot_title = 'Your job level compared to first quartile.'
            elif JL <= years_at_comp_dict['50%']:
                job_lvl = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                             & (df['JobRole'] == position) 
                             & (df['JobLevel'] <= years_at_comp_dict['50%']) 
                             & (df['JobLevel'] >years_at_comp_dict['25%'])]['JobLevel']
                plot_title = 'Your job level compared to second quartile.'
            elif JL <= years_at_comp_dict['75%']:
                job_lvl = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                             & (df['JobRole'] == position) 
                             & (df['JobLevel'] <=years_at_comp_dict['75%']) 
                             & (df['JobLevel'] > years_at_comp_dict['50%'])]['JobLevel']
                plot_title = 'Your job level compared to third quartile.'
            else:
                job_lvl = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                             & (df['JobRole'] == position) 
                             & (df['JobLevel'] > years_at_comp_dict['75%'])]['JobLevel']
                plot_title = 'Your job level compared to fourth quartile.'


            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.countplot(x='JobLevel', data=df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                                                & (df['JobRole'] == position)], palette='cool')
            plt.title(f'Job Level across employees working for {years_at_comp} years in company as {position}.')

        else:
            plt.figure(figsize=(6, 4))
            sns.set_style('whitegrid')
            sns.countplot(x='JobLevel', data=df[df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)], 
                          palette='cool')
            print(f'Sorry, we do not have enough data to plot job level statistics for your department.\n'
                 f'Now showing general statistics for employees working for {i} years in current role.')
        plt.show()

    def plot_satisfaction_years_at_comp_pos(self, js: int, rs: int, es:int, years_at_comp: int, position: str):
        years_at_comp_total = None # hotfix
        df = self.df
        years_at_comp_list = self.years_at_comp_list
        for i in years_at_comp_list:
            if years_at_comp in i:
                years_at_comp_total = i

        dfc = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                 & (df['JobRole'] == position)]
        job_sat_col = dfc['JobSatisfaction'].mean()
        relationship_sat_col = dfc['RelationshipSatisfaction'].mean()
        environment_sat_col = dfc['EnvironmentSatisfaction'].mean()

        job_sat_you = js
        relationship_sat_you = rs
        environment_sat_you = es     

        if len(dfc) >2:
            plt.figure(figsize=(8, 6))   
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
            plt.title('Your satisfaction levels compared to average satisfaction levels of people having having'
                      ' the same experience of working at the company and being hired on the same position')
            plt.xticks(bar1+w/2, x)
            plt.legend()
            plt.show()
        else:
            print('Not enough data to show comparison')

    def plot_years_at_comp_overtime_pos(self, position: str, years_at_comp: int):
        years_at_comp_total = None # hotfix
        df = self.df
        years_at_comp_list = self.years_at_comp_list
        for i in years_at_comp_list:
            if years_at_comp in i:
                years_at_comp_total = i

        df1 = df[(df['YearsAtCompany'].between(years_at_comp_total.left, years_at_comp_total.right)) 
                 & (df['JobRole'] == position)]

        if df1['OverTime'].count() > 0 and len(df1['OverTime'].unique()) == 2:
            print("Showing OverTime statistics for people with experience of work at company in same range and working at the same position")
            sns.displot(df1, x= 'YearsInCurrentRole', hue= 'OverTime', hue_order=[True, False])
        else:
            print("Not enough data for people with experience of work at company in same range and working on the same position. Showing general data for people with experience of work at company within the same range")
            sns.displot(x='YearsInCurrentRole', hue='OverTime', data=df[df['YearsInCurrentRole'] == years_in_curr_role], 
                        hue_order=[True, False])