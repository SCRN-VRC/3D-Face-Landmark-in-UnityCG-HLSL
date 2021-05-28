import tensorflow as tf
import numpy as np
import struct
import os
from keras.preprocessing.image import img_to_array
from keras.preprocessing.image import load_img

import matplotlib.pyplot as plt
from matplotlib.pyplot import figure

from tensorflow.python.framework import tensor_util

figure(figsize=(8, 8), dpi=80)
plt.style.use('seaborn-whitegrid')
# plt.xlim(0, 191)
# plt.ylim(191, 0)

GRAPH_PB_PATH = './facemesh.pb'

def load_image(filename, size=(192, 192)):
    # load image with the preferred size
    pixels = load_img(filename, target_size=size)
    # convert to numpy array
    pixels = img_to_array(pixels)
    #np.flipud(pixels)
    # scale from [0,255] to [-1,1]
    pixels = pixels / 255.0
    # reshape to 1 sample
    pixels = np.expand_dims(pixels, 0)
    return pixels

def load_graph(frozen_graph_filename):
    # We load the protobuf file from the disk and parse it to retrieve the 
    # unserialized graph_def
    with tf.io.gfile.GFile(frozen_graph_filename, "rb") as f:
        graph_def = tf.compat.v1.GraphDef()
        graph_def.ParseFromString(f.read())
        graph_nodes = [n for n in graph_def.node]
     
    # Then, we can use again a convenient built-in function to import a graph_def into the 
    # current default Graph
    with tf.Graph().as_default() as graph:
        tf.import_graph_def(
            graph_def, 
            input_map=None, 
            return_elements=None, 
            name="facemesh", 
            op_dict=None, 
            producer_op_list=None
            )

    input_name = 'facemesh/input_1:0'
    output_name = graph.get_operations()[-2].name+':0'
    #output_name = 'facemesh/Identity_2:0'
 
    return graph, graph_nodes, input_name, output_name

def predict(model_path, input_data):
    # load tf graph
    tf_model,graph_nodes,tf_input,tf_output = load_graph(model_path)

    # Create tensors for model input and output
    x = tf_model.get_tensor_by_name(tf_input)
    y_out = []
    # Get a list of outputs of every layer
    # WARNING:
    #   THIS IS SLOW BECAUSE I'M GETTING EVERY TENSOR OUTPUT FOR DEBUGGING
    #   INSTEAD OF JUST THE XYZ DATA AT THE END
    for o in tf_model.get_operations():
        if o.type != 'Const' and o.type != 'NoOp':
            y = tf_model.get_tensor_by_name(o.name + ':0')
            with tf.compat.v1.Session(graph=tf_model) as sess:
                y_out.append(sess.run(y, feed_dict={x: input_data}))
                
    return y_out, graph_nodes, tf_model

def test(size=(192, 192)):
    w = float(size[0] - 1)
    h = float(size[1] - 1)
    a = np.zeros((size[0], size[1], 3))
    for k in range(0, 3):
        for i in range(0, size[0]):
            for j in range(0, size[1]):
                if k == 0:
                    a[i][j][k] = (i / w) * (j / h)
                elif k == 1:
                    a[i][j][k] = ((w - i) / w) * (j / h)
                else:
                    a[i][j][k] = (i / w) * ((h - j) / h)
    a = np.expand_dims(a, 0)
    return a

INPUT_PATH = './data/face5.jpg'

src_image = load_image(INPUT_PATH)
org_image = load_img(INPUT_PATH)

# test_img = test()

output, graph_nodes, tf_model = predict(GRAPH_PB_PATH, src_image)

# coords
x = output[237][0][0::3]
y = output[237][0][1::3]

# plot
plt.plot(x, y, 'o', color='black')
plt.imshow(org_image)

#https://www.programmersought.com/article/64464830536/

# list of weights
wts = [tensor_util.MakeNdarray(n.attr['value'].tensor) for n in graph_nodes if n.op=='Const']
# list of layer names
names = [n.name for n in graph_nodes if n.op!='Const' and n.op!='NoOp']

if 0:
    # write to file
    def write_weights(array, dest, mode='ab'):
        with open(dest, mode) as f:
            if (len(array.shape) == 4):
                for i in range(0, len(array)):
                    for j in range(0, len(array[0])):
                        for k in range(0, len(array[0][0])):
                            for l in range(0, len(array[0][0][0])):
                                f.write(struct.pack('f', array[i][j][k][l]))
            elif (len(array.shape) == 3):
                for i in range(0, len(array)):
                    for j in range(0, len(array[0])):
                        for k in range(0, len(array[0][0])):
                            f.write(struct.pack('f', array[i][j][k]))
            elif (len(array.shape) == 2):
                for i in range(0, len(array)):
                    for j in range(0, len(array[0])):
                            f.write(struct.pack('f', array[i][j]))
            elif (len(array.shape) == 1):
                for i in range(0, len(array)):
                    f.write(struct.pack('f', array[i]))
            f.close()
            
    print("Exporting weights.")
    dest = './data/facemeshUNITY.bytes'
    
    try:
        os.remove(dest)
    except OSError:
        pass
    for i in range(0, len(wts)):
        write_weights(wts[i], dest)
        
    print("Done.")
