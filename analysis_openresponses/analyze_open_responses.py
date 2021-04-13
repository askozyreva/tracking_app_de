import matplotlib.pyplot as plt
import numpy as np 
import pandas as pd
from graph_tool.all import *
import pickle
import collections

###################reasons TO download########################
"""
#pre-processing of open responses
#load responses
lines = open("free_text.txt", "r", encoding='utf-16').readlines()
#stopword to not be ignore (as they differentiate between)
other_sw = ['kein', 'keine', 'nicht', 'keinen', 'keins', 'nichts']
#read line by line
text = []
print(len(lines))
for comment in lines:
	comment = comment.replace("\n", "")
	text_tokens = word_tokenize(comment)
	#filter out stopwords, apart from the list above
	tokens_without_sw = []
	for word in text_tokens:
		if word.lower() in stopwords.words('german') and word.lower() not in other_sw:
			continue
		else:
			tokens_without_sw.append(word)
	text.append(' '.join(tokens_without_sw))


#define the ngram range to be used
c_vec = CountVectorizer(ngram_range=(1,1))
"""
# load c_vec
with open('c_vec_open_responses_pro.pkl', 'rb') as file:
    c_vec = pickle.load(file)
# load ngrams
with open('ngrams_open_responses_pro.pkl', 'rb') as file:
    ngrams = pickle.load(file)
# count frequency of ngrams
count_values = ngrams.toarray().sum(axis=0)
# list of ngrams
vocab = c_vec.vocabulary_

#initialize graph
G = Graph(directed=False)
edge_list = []
weight_list = []
weight = G.new_edge_property("int")
# find duplicates + calculate overlap
del_els = []
for k, i in vocab.items():
	for h, j in vocab.items():
		if sorted(k.split()) == sorted(h.split()) and i != j and j not in del_els:
		#if set(k.split()).issubset(set(h.split())) and i != j and j not in del_els:
			count_values[j] += count_values[i]
			del_els.append(i)
inverted_dict = dict(map(reversed, vocab.items()))
for row in ngrams.toarray():
		entries = np.where(row > 0)[0]
		for el1 in entries:
			for el2 in entries:
				k_multiset = collections.Counter(inverted_dict[el1].split())
				h_multiset = collections.Counter(inverted_dict[el2].split())
				overlap = list((k_multiset & h_multiset).elements())
				if el1 != el2 and len(overlap) == 0:
					edge_list.append([str(inverted_dict[el1]), str(inverted_dict[el2]), int(1)])

#sorted list of counts
df_ngram = pd.DataFrame(sorted([(count_values[i],k) for k,i in vocab.items() if i not in del_els], reverse=True)
            ).rename(columns={0: 'frequency', 1:'gram'})

#populate graph
node_id = G.add_edge_list(edge_list, hashed=True, eprops=[weight])
G.vertex_properties['node_id'] = node_id
label = G.new_vertex_property("string")
for v in G.vertices():
	label[v] = G.vp.node_id[v]
activity = G.new_vertex_property("int")
G.vertex_properties['activity'] = activity
G.vertex_properties['label'] = label
G.edge_properties['weight'] = weight
G.list_properties()

#add frequency as vertex property
for v in G.vertices():
        try:
                G.vp.activity[v] = int(df_ngram.loc[df_ngram['gram'] == G.vp.node_id[v], 'frequency'].iloc[0])
        except IndexError:
                continue

G.vertex_properties['activity'] = activity
G.save('reasons_netw_pro_1.graphml')

#plot the 20 most common reasons
D = df_ngram[:20]
plt.bar(range(len(D)), list(D['frequency']), align='center', color="#4cbc7c")
plt.xticks(range(len(D)), list(D['gram']), rotation=45, ha='right')
plt.ylabel('count')
plt.show()

###################reasons to NOT download########################
"""
#load responses
lines = open("free_tetx_con.txt", "r", encoding='utf-16').readlines()
#stopword to not be ignore (as they differentiate between)
other_sw = ['kein', 'keine', 'nicht', 'keinen', 'keins', 'nichts']
#read line by line
text = []
print(len(lines))
for comment in lines:
	comment = comment.replace("\n", "")
	text_tokens = word_tokenize(comment)
	#filter out stopwords, apart from the list above
	tokens_without_sw = []
	for word in text_tokens:
		if word.lower() in stopwords.words('german') and word.lower() not in other_sw:
			continue
		else:
			tokens_without_sw.append(word)
	text.append(' '.join(tokens_without_sw))

#define the ngram range to be used
c_vec = CountVectorizer(ngram_range=(1,1))
"""
# load c_vec
with open('c_vec_open_responses_con.pkl', 'rb') as file:
    c_vec = pickle.load(file)
# load ngrams
with open('ngrams_open_responses_con.pkl', 'rb') as file:
    ngrams = pickle.load(file)
# count frequency of ngrams
count_values = ngrams.toarray().sum(axis=0)
# list of ngrams
vocab = c_vec.vocabulary_

#initialize graph
G = Graph(directed=False)
edge_list = []
weight_list = []
weight = G.new_edge_property("int")
# find duplicates + calculate overlap
del_els = []
for k, i in vocab.items():
	for h, j in vocab.items():
		if sorted(k.split()) == sorted(h.split()) and i != j and j not in del_els:
		#if set(k.split()).issubset(set(h.split())) and i != j and j not in del_els:
			count_values[j] += count_values[i]
			del_els.append(i)
inverted_dict = dict(map(reversed, vocab.items()))
for row in ngrams.toarray():
		entries = np.where(row > 0)[0]
		for el1 in entries:
			for el2 in entries:
				k_multiset = collections.Counter(inverted_dict[el1].split())
				h_multiset = collections.Counter(inverted_dict[el2].split())
				overlap = list((k_multiset & h_multiset).elements())
				if el1 != el2 and len(overlap) == 0:
					edge_list.append([str(inverted_dict[el1]), str(inverted_dict[el2]), int(1)])

#sorted list of counts
df_ngram = pd.DataFrame(sorted([(count_values[i],k) for k,i in vocab.items() if i not in del_els], reverse=True)
            ).rename(columns={0: 'frequency', 1:'gram'})

#populate graph
node_id = G.add_edge_list(edge_list, hashed=True, eprops=[weight])
G.vertex_properties['node_id'] = node_id
label = G.new_vertex_property("string")
for v in G.vertices():
	label[v] = G.vp.node_id[v]
activity = G.new_vertex_property("int")
G.vertex_properties['activity'] = activity
G.vertex_properties['label'] = label
G.edge_properties['weight'] = weight
G.list_properties()

#add frequency as vertex property
for v in G.vertices():
        try:
                G.vp.activity[v] = int(df_ngram.loc[df_ngram['gram'] == G.vp.node_id[v], 'frequency'].iloc[0])
        except IndexError:
                continue

G.vertex_properties['activity'] = activity
G.save('reasons_netw_con_1.graphml')

#plot the 20 most common reasons
D = df_ngram[:20]
plt.bar(range(len(D)), list(D['frequency']), align='center', color="#4cbc7c")
plt.xticks(range(len(D)), list(D['gram']), rotation=45, ha='right')
plt.ylabel('count')
plt.show()

