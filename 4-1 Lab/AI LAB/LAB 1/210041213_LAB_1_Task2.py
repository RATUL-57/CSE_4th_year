class FrequencyMap:
    def __init__(self, words):
        self.frequency = {}
        for i in words:
            if i in self.frequency:
                self.frequency[i] += 1
            else:
                self.frequency[i] = 1

    def most_common(self):
        return max(self.frequency, key=self.frequency.get)



words = []

print("Input words separating by Enter:")

while True:
    line = input()
    if line == "" :
        break

    words.append(line)

f = FrequencyMap(words)

print("The most common word in the dictionary is : " , f.most_common())