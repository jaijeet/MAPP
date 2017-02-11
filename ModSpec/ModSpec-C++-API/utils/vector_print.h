#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>
#include "untyped.h"
#include <vector> // std::vector
// #include "boost_ublas_includes_typedefs.h"

using namespace std;

void print_vector_of_strings(const vector<string>& arg);
void print_vector_of_strings(const vector<string>& names, const vector<string>& arg);
void print_vector_of_doubles(const vector<double>& arg);
void print_vector_of_doubles(const vector<string>& names, const vector<double>& arg);
void print_vector_of_ints(const vector<int>& arg);
void print_vector_of_ints(const vector<string>& names, const vector<int>& arg);
void print_vector_of_untyped(const vector<untyped>& arg);
void print_vector_of_untyped(const vector<string>& names, const vector<untyped>& arg);
