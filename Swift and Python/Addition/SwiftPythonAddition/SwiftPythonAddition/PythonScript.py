import random


def generate_question():
    value_one = random.randint(10, 20)
    value_two = random.randint(10, 20)
    return value_one, value_two

def check_answer(value_one, value_two, user_input):
    result = value_one + value_two
    is_correct = (result == user_input)
    return is_correct, result

