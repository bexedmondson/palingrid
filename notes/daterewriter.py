import json

data = []

file_path = 'historical_scores.json'

with open(file_path, 'r') as file:
    data = json.load(file)

for d in data:
    if '/' in d["date"]:
        splits = d["date"].split('/')
        reversed = splits[2] + "-" + splits[1] + "-" + splits[0]
        d["date"] = reversed

print(data)

with open(file_path, 'w') as file:
    json.dump(data, file, indent=4)