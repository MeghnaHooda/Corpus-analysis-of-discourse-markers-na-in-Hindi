
import os
import csv
from conllu import parse
import networkx as nx

def statistics_corpus(file_in, file_out):
    file_out = os.path.join(file_out, "Sentence_Wise_Discourse_markers_na.csv") 
    with open(file_out, "w",encoding="utf-8", newline='',) as csvfile: 
    
        csvwriter = csv.writer(csvfile, delimiter = ',')   
        csvwriter.writerow(["Phase", "File", "Sent Id", "Sentence", "Sentence Length","precede-pos","succeed-pos",'Avg DD', 'Verb Type','na'])
        dirs = sorted(os.listdir(file_in))       # Creating sorted list of directories from given path
        print('dir',dirs)
        # for every file in the directory
        for file in dirs:
            print('file',file)
            if not os.path.isfile((file_in+str(file))):         # Ignoring the files and only considering folders in given path  

                phase_dir = sorted(os.listdir(file_in+str(file)))
                # print("p_dir",phase_dir)
                Phase = file[-1]                                  # Considering the phase of output files

                for phases in phase_dir:
                    if not os.path.isfile((file_in+str(file)+"/"+str(phases))):
                        outputfiles_dir = sorted(os.listdir(file_in+str(file)+"/"+str(phases)))   # Accessing output files folder in each phase
                        # print("output",outputfiles_dir)
                        for output_file in outputfiles_dir:
                            filename = file_in+str(file)+"/"+str(phases)+"/"+str(output_file)    # Looping over each output file in output files folder
                            print("filename",filename)
                            if filename.endswith(".conllu"): #or filename.endswith(".txt"):
                                filename_in = filename

                                data_file = open(str(filename_in),'r',encoding='utf-8').read()
                                file1 = parse(data_file)       # Loading CoNLL output file using pyconll module

                                # count_sent = 0   
                                token_sent = 0
                                for sentence in file1:
                                    # count_sent+=1             # Counting number of sentences in each output file
                                    # print(count_sent)
                                    sentence_length=0
                                    # print(sentence.metadata['sent_id'])
                                    
                                    tree = nx.DiGraph()                              # An empty directed graph (i.e., edges are uni-directional)
                                    for nodeinfo in sentence[0:]:                    # retrieves information of each node from dependency tree in UD format
                                        entry=list(nodeinfo.items())
                                        tree.add_node(entry[0][1], form=entry[1][1], lemma=entry[2][1], upostag=entry[3][1], xpostag=entry[4][1], feats=entry[5][1], head=entry[6][1], deprel=entry[7][1], deps=entry[8][1], misc=entry[9][1])                #adds node to the directed graph
                                    ROOT=0
                                    tree.add_node(ROOT)                            # adds an abstract root node to the directed graph

                                    for nodex in tree.nodes:
                                        if not nodex==0:
                                            if tree.has_node(tree.nodes[nodex]['head']):                                         # to handle disjoint trees
                                                tree.add_edge(tree.nodes[nodex]['head'],nodex,drel=tree.nodes[nodex]['deprel'])       # adds edges as relation between nodes

                                    n=len(tree.edges) #length of sentence 

                                    nsubj=[]
                                    obj=[]
                                    iobj=[]
                                    verb_index=[]
                                    for nodex in tree.nodes:
                                        if not nodex==0:
                                            if tree.nodes[nodex]['upostag']=='VERB':
                                                # if tree.nodes[nodex]['head']==0:
                                                # verb_index.append(nodex)
                                                verb_temp=nodex
                                                nsubj_temp=0
                                                obj_temp=0
                                                iobj_temp=0
                                                for nodex in tree.nodes:
                                                    if not nodex==0:
                                                        if tree.nodes[nodex]['deprel']=='nsubj' and tree.nodes[nodex]['head']==verb_temp:
                                                            nsubj_temp=nodex
                                                        if tree.nodes[nodex]['deprel']=='obj' and tree.nodes[nodex]['head']==verb_temp:
                                                            obj_temp=nodex
                                                        if tree.nodes[nodex]['deprel']=='iobj' and tree.nodes[nodex]['head']==verb_temp:
                                                            iobj_temp=nodex
                                                if nsubj_temp!=0 and obj_temp!=0:
                                                    verb_index.append(verb_temp)
                                                    nsubj.append(nsubj_temp)
                                                    obj.append(obj_temp)
                                                    if iobj_temp!=0:
                                                        iobj.append(iobj_temp)
                                                    else:
                                                        iobj.append(0)
                                    dd=[]
                                    for edgex in tree.edges:
                                        if not edgex[0]==ROOT:
                                            dd_temp=dependency_distance(tree, ROOT,edgex)
                                            dd.append(dd_temp)
                                    if dd == []:
                                        dd=[1]
                                    # print(dd)
                                    sentence_str = (sentence.metadata['Sentence'])
                                    transitivity = "Intransitive"
                                    if " ना " in sentence_str:
                                        for  i in range(0, len(sentence)):
                                            token=sentence[i]
                                            # print(token["deprel"])
                                            # print(sentence[i]["upos"])
                                            if token["deprel"]=="obj":
                                                transitivity = "Transitive"
                                            if transitivity == "Intransitive" and token["deprel"]=="iobj":
                                                transitivity = "Dintransitive"
                                            
                                            if token["form"]=="ना":#"तो":
                                                # print(sentence.metadata['sent_id'], token["form"])
                                                if i!=0:
                                                    precede_pos=sentence[i-1]["upos"]
                                                if i<len(sentence)-1:
                                                    succed_pos=sentence[i+1]["upos"]
                                            token_sent+=1 
                                            if token["upos"] != "PUNCT" and "[" not in token["form"] and "_" not in token["form"]: #if its not a chunk
                                                sentence_length+=1
                                            else:
                                                if token["misc"]!= None:
                                                    for i in token["misc"].keys():#miscellaneous column
                                                        if i == 'CodeSwitch' or i == "Quote" or i=="Expletive":
                                                            chunk_split=token["form"].split("_")
                                                            sentence_length+=len(chunk_split)
                                        if not "[" in sentence_str and len(sentence):
                                            if succed_pos == 'VERB':
                                                csvwriter.writerow([Phase, output_file.replace("_output", ""), sentence.metadata['sent_id'], sentence.metadata['Sentence'], sentence_length, precede_pos, succed_pos, sum(dd)/len(dd), transitivity,'Neg na'])
                                            else:
                                                csvwriter.writerow([Phase, output_file.replace("_output", ""), sentence.metadata['sent_id'], sentence.metadata['Sentence'], sentence_length, precede_pos, succed_pos, sum(dd)/len(dd), transitivity, 'na'])
                                    else:
                                        for  i in range(0, len(sentence)):
                                            token=sentence[i]
                                            if token["deprel"]=="obj":
                                                transitivity = "Transitive"
                                            if transitivity == "Intransitive" and token["deprel"]=="iobj":
                                                transitivity = "Dintransitive"
                                            if token["upos"] != "PUNCT" and "[" not in token["form"] and "_" not in token["form"]: #if its not a chunk
                                                sentence_length+=1
                                            else:
                                                if token["misc"]!= None:
                                                    for i in token["misc"].keys():#miscellaneous column
                                                        if i == 'CodeSwitch' or i == "Quote" or i=="Expletive":
                                                            chunk_split=token["form"].split("_")
                                                            sentence_length+=len(chunk_split)
                                        csvwriter.writerow([Phase, output_file.replace("_output", ""), sentence.metadata['sent_id'], sentence.metadata['Sentence'], sentence_length, precede_pos, succed_pos, sum(dd)/len(dd), transitivity,'No na'])

def dependency_distance(tree, root, edge):        # Computes the dependency length i.e., no. of nodes between head and its dependent 
    dd=0
    if edge[0]>edge[1]:                      
        for nodex in nx.descendants(tree, root):        
            if edge[1]<=nodex<edge[0]:                             # all the nodes that lies linearly between dependent and head   
                dd+=1
    else:
        for nodex in nx.descendants(tree, root):
            if edge[0]<=nodex<edge[1]:
                dd+=1
    return dd
file_in ="" #data 
file_out ="data/"
statistics_corpus(file_in, file_out)
         