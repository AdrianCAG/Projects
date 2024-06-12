lst_of_variable = []

def insert(value):
    lst_of_variable.append(value)

def compute_average():
    if len(lst_of_variable) == 0:
        return 0
    amount_of_n = len(lst_of_variable)
    average = sum(lst_of_variable) // amount_of_n
    return average
