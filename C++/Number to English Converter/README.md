# Number to Text

This project is a simple C++ program that converts numbers into their English word equivalents. It's inspired by the common practice of writing checks, where the amount is presented both numerically and in words (e.g., 1729 becomes "one thousand seven hundred twenty-nine").

The program reads integers from the user and prints out the corresponding English words for the numbers entered. The user can enter any non-negative integer up to 999,999, and the program will display the number in words. The program will stop when the user enters a negative number.

## Features
- Converts numbers from 0 to 999,999 into their English text equivalent.
- Handles special cases such as:
    - Numbers between 10 and 19, like "eleven" and "thirteen."
    - Ranges like "twenty-one," "thirty-two," etc.
    - Large numbers up to "nine hundred ninety-nine thousand nine hundred ninety-nine."
- Ensures modularity by breaking the problem down into reusable functions.

## Example Usage
```text
Enter numbers in figures; use a negative value to stop.
Number: 0
zero
Number: 1
one
Number: 11
eleven
Number: 256
two hundred fifty-six
Number: 1729
one thousand seven hundred twenty-nine
Number: 2001
two thousand one
Number: 12345
twelve thousand three hundred forty-five
Number: 13000
thirteen thousand
Number: -1
```

## Key Concepts

### 1. Modularity and Decomposition
- The problem is broken down into smaller, manageable functions. For example:
    - `PrintOneDigit`: Prints numbers from 0-9.
    - `PrintTeen`: Handles special cases for numbers between 10 and 19.
    - `PrintTens`: Prints the tens place for numbers from 20-90.
    - `PrintTwoDigitNumber`: Combines tens and ones digits.
    - `PrintThreeDigitNumber`: Prints numbers in the hundreds place.
    - `PrintNumber`: Orchestrates the entire process, handling numbers up to 999,999.

### 2. Handling Special Cases
- Special cases like numbers between 11-19 that don’t follow the regular tens pattern are handled in the `PrintTeen` function.
- Numbers like "twenty-one" or "thirty-two" are handled by combining the tens and ones digits with a hyphen.

### 3. Avoiding String Manipulation
- The program focuses on outputting the numbers in English text directly to `cout`, avoiding the complexity of   string manipulation.

## Code Structure
```cpp
void PrintOneDigit(int d);           // Handles numbers 0-9
void PrintTeen(int n);               // Handles numbers 10-19
void PrintTens(int n);               // Handles multiples of 10 (20, 30, 40, ...)
void PrintTwoDigitNumber(int n);     // Prints any two-digit number
void PrintThreeDigitNumber(int n);   // Prints any three-digit number
void PrintNumber(int n);             // Master function for numbers up to 999,999
```

## Limitations
- The program can handle numbers only up to 999,999. If a number outside of this range is entered, the program does not handle it.
- The output is all in lowercase, as the problem is significantly more complex if capitalization is required.

## Future Improvements
- Support for larger numbers, beyond 999,999.
- Handling of edge cases, such as invalid inputs (non-integer values).
- Adding optional formatting, such as capitalizing the first letter of the output.

## License
This project is open-source and available under the [MIT License](LICENSE)

##
Enjoy converting numbers into English words! If you have any questions or suggestions, feel free to open an issue on GitHub.