import string
import json

letters = list(string.ascii_lowercase)
counts = {l: 0 for l in letters}
total = 0

with open("small.txt") as f:
	lines = f.readlines()
	for line in lines:
		for c in line:
			if c in counts:
				counts[c] += 1
				total += 1

#print(counts)

probabilities = {}
for c in counts:
	probabilities[c] = counts[c] * 1.0 / total

print(probabilities)

with open("stats.json", 'w') as f:
	json.dump(probabilities, f)
