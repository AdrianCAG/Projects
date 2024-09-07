//
//  main.cpp
//  NumberToText
//
//  Created by Adrian on 9/7/24.
//

#include <iostream>



using namespace std;


// Prints the name of a single-digit number (0-9)
void PrintOneDigit(int d) {
    switch (d) {
        case 0: cout << "zero"; break;
        case 1: cout << "one"; break;
        case 2: cout << "two"; break;
        case 3: cout << "three"; break;
        case 4: cout << "four"; break;
        case 5: cout << "five"; break;
        case 6: cout << "six"; break;
        case 7: cout << "seven"; break;
        case 8: cout << "eight"; break;
        case 9: cout << "nine"; break;
        default: cout << "Error"; break;
    }
}

// Prints the name of a "teen" number (10-19)
void PrintTeen(int n) {
    switch (n) {
        case 10: cout << "ten"; break;
        case 11: cout << "eleven"; break;
        case 12: cout << "twelve"; break;
        case 13: cout << "thirteen"; break;
        case 14: cout << "fourteen"; break;
        case 15: cout << "fifteen"; break;
        case 16: cout << "sixteen"; break;
        case 17: cout << "seventeen"; break;
        case 18: cout << "eighteen"; break;
        case 19: cout << "nineteen"; break;
        default: cout << "Error"; break;
    }
}

// Prints the name of tens for numbers (20, 30, 40, etc.)
void PrintTens(int n) {
    switch (n) {
        case 2: cout << "twenty"; break;
        case 3: cout << "thirty"; break;
        case 4: cout << "forty"; break;
        case 5: cout << "fifty"; break;
        case 6: cout << "sixty"; break;
        case 7: cout << "seventy"; break;
        case 8: cout << "eighty"; break;
        case 9: cout << "ninety"; break;
        default: cout << "Error"; break;
    }
}

// Prints the name of any two-digit number
void PrintTwoDigitNumber(int n) {
    if (n < 10) {
        PrintOneDigit(n); // Single-digit number
    } else if (n < 20) {
        PrintTeen(n); // Teen numbers (10-19)
    } else {
        PrintTens(n / 10); // Tens part (20, 30, etc.)
        if (n % 10 != 0) { // If there's a non-zero ones place
            cout << "-";
            PrintOneDigit(n % 10); // Print ones part
        }
    }
}

// Prints the name of any three-digit number
void PrintThreeDigitNumber(int n) {
    if (n >= 100) {
        PrintOneDigit(n / 100); // Print hundreds part
        cout << " hundred";
        if (n % 100 != 0) { // If there's a non-zero remainder
            cout << " ";
            PrintTwoDigitNumber(n % 100); // Print the two-digit remainder
        }
    } else {
        PrintTwoDigitNumber(n); // If it's less than 100, print as a two-digit number
    }
}

// Prints the name of any number (up to 9999)
void PrintNumber(int n) {
    if (n == 0) {
        PrintOneDigit(n); // Special case for 0
    } else {
        if (n >= 1000) {
            PrintThreeDigitNumber(n / 1000); // Print thousands part
            cout << " thousand";
            if (n % 1000 != 0) { // If there's a non-zero remainder
                cout << " ";
                PrintThreeDigitNumber(n % 1000); // Print the three-digit remainder
            }
        } else {
            PrintThreeDigitNumber(n); // If less than 1000, print as three-digit number
        }
    }
    cout << "\n";
}




int main() {
    cout << "Enter numbers in figures; use a negative value to stop." << endl;
    while (true) {
        cout << "Number: ";
        int number;
        cin >> number;

        if (number < 0) break; // End the loop on negative input
        PrintNumber(number); // Print the number in words
    }
    
    return 0;
}
