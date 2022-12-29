import csv
import statistics as stat
from pathlib import Path



with open(Path(__file__).parent / './dogs-data.csv', encoding='utf-8') as data_file:
    dog_data = csv.DictReader(data_file)
    dog_data = list(dog_data)

#print(dog_data[0])


"""
Excercise 1

Data about dogs and their owners has been loaded into the dog_data list. Each element of the list is a dictionary,
which has 4 keys 'OwnerAge', 'Gender', 'Breed', 'DogAge' denoting the owner's age (age range),
dog's gender, dog's breed, and dog's age.
An example list item:
{'OwnerAge': 60, 'Gender': 'M', 'Breed': 'Welsh Terrier', 'DogAge': 3}

a) write to the variable list breeds a list of all dog breeds contained in dog_data. Elements
     lists should be unique and sorted alphabetically (A-Z).

b) Find the most popular dog breed for each age range (key `OwnerAge`) i
     save the result as the_most_popular_breed dictionary, whose keys will be age ranges,
     and the value of the most popular breed of dog (for a given range).
    
c) The statistics library (https://docs.python.org/3/library/statistics.html#) allows
     calculation of basic statistical functions. Use the appropriate functions and calculate
     mean, mode and age variance of the dogs.

d) Write to the file `terriers.txt` the names of all Terriers with their number, which are in dog_data.
     Save the data in CSV format. Use the `csv` library (https://docs.python.org/3.8/library/csv.html).

"""


#A

temp_a = []

for dog in dog_data:
    temp_a.append(dog['Breed']) if dog['Breed'] not in temp_a else temp_a

temp_a.sort()
print(temp_a)


#B

age = []
temp_b = []
for dog in dog_data:
    temp_b.append(dog['OwnerAge']) if dog['OwnerAge'] not in temp_b else temp_b

temp_b.sort()

the_most_popular_breed = {}

for i in temp_b:
    list = []
    for dog in dog_data:
        if i == dog['OwnerAge']:
            list.append(dog['Breed'])
    the_most_popular_breed[i]= max(set(list), key = list.count)

print(the_most_popular_breed)



#C

temp_c = []
for dog in dog_data:
        temp_c.append(int(dog['DogAge']))


print(stat.mean(temp_c))
print(stat.mode(temp_c))
print(stat.variance(temp_c))



#D

temp_d = {}
for dog in dog_data:
    if 'Terrier' in dog['Breed']:
        if dog['Breed'] in temp_d.keys():
            temp_d[dog['Breed']] += 1
        else:
            temp_d[dog['Breed']] = 1


with open('terriers.txt', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['Breed', 'CNT'])
    for row in temp_d.items():
        writer.writerow(row)



