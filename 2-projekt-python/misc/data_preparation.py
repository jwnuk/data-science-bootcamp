"""
Module contents:
- import of data frame,
- data cleaning code,
- table of columns correlation coefficients between each other.

Defined variables:
- df_original - data frame (original)
- df - data frame (cleaned),
- df_corr - table containing correlation coefficients.
"""


import pandas as pd

df = pd.read_csv('..\..\WA_Fn-UseC_-HR-Employee-Attrition.csv')

df = df.drop(columns = 'EmployeeCount')
df = df.drop(columns = 'EmployeeNumber')
df = df.drop(columns = 'Over18')
df = df.drop(columns = 'StandardHours')

df['Attrition'].replace({'No': 0, 'Yes': 1}, inplace=True)
df['BusinessTravel'].replace({'Non-Travel': 0, 'Travel_Rarely': 1, 'Travel_Frequently': 2}, inplace=True)
df['Department'].replace({'Human Resources': 0, 'Research & Development': 1, 'Sales': 2}, inplace=True)
df['EducationField'].replace({'Human Resources': 0, 'Life Sciences': 1, 'Marketing': 2, 'Medical': 3, 'Technical Degree': 4, 'Other': 5}, inplace=True)
df['Gender'].replace({'Female': 0, 'Male': 1}, inplace=True)
df['JobRole'].replace({'Healthcare Representative': 0, 'Human Resources': 1, 'Laboratory Technician': 2, 'Manager': 3, 'Manufacturing Director': 4, 'Research Director': 5, 'Research Scientist': 6, 'Sales Executive': 7, 'Sales Representative': 8}, inplace=True)
df['MaritalStatus'].replace({'Divorced': 0, 'Married': 1, 'Single': 2}, inplace=True)
df['OverTime'].replace({'No': 0, 'Yes': 1}, inplace=True)

corr_table = df.corr()

def corr_color(val):
    if abs(val) > 0.8:
        color = 'red'
    elif abs(val) > 0.5:
        color = 'orange'
    elif abs(val) > 0.3:
        color = 'yellow'
    else:
        color = 'blue'
    return 'color: %s' % color

df_corr = corr_table.style.applymap(corr_color)

df_original = pd.read_csv('..\..\WA_Fn-UseC_-HR-Employee-Attrition.csv')

def print_values(data_frame, column_name: str):
    values = data_frame[column_name].value_counts()
    print(values, '\n')