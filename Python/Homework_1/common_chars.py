#!/usr/bin/env python
# -*- coding: utf-8 -*-


"""
Write a function common_chars(string1, string2) that returns an alphabetically ordered list of common letters from string1 and string2.
Both strings will consist only of lowercase letters.
"""


def common_chars(string1, string2):

    list1 = list(string1.replace(" ","").lower())
    output = []
    for i in list1:
        if i in string2.lower() and i not in output:
            output.append(i)
    return sorted(output)


input1 = "this is a string"
input2 = "ala ma kota"
"""
output = ['a', 't']
"""






print(common_chars(input1, input2))