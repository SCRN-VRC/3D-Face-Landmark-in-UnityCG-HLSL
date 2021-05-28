import cv2
import onnx
import numpy as np
from onnx import numpy_helper
from onnx import helper
from onnx_tf.backend import prepare
import onnxruntime as rt
import struct
import os

import matplotlib.pyplot as plt
from matplotlib.pyplot import figure

figure(figsize=(8, 8), dpi=80)
plt.style.use('seaborn-whitegrid')

def test(size=(64, 64)):
    w = float(size[0] - 1)
    h = float(size[1] - 1)
    a = np.zeros((3, size[0], size[1]))
    for k in range(0, 3):
        for i in range(0, size[0]):
            for j in range(0, size[1]):
                if k == 0:
                    a[k][i][j] = (i / w) * (j / h)
                elif k == 1:
                    a[k][i][j] = ((w - i) / w) * (j / h)
                else:
                    a[k][i][j] = (i / w) * ((h - j) / h)
    a = np.expand_dims(a, 0)
    a = np.float32(a)
    return a

# img = cv2.imread("D:/Storage/Unity/facemesh-python/data/eye2.jpg")
# img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
# imgR = cv2.resize(img, dsize=(64, 64), interpolation=cv2.INTER_AREA)
# imgR.resize((1, 3, 64, 64))
# imgData = np.array(imgR).astype('float32')
# imgData = imgData / 255.0

imgData = test()

onnx_model = onnx.load("iris_landmark.onnx")  # load onnx model
init = onnx_model.graph.initializer
weights = []
w_names = []
for initializer in init:
    weights.append(numpy_helper.to_array(initializer))
    w_names.append(initializer.name)

end_node_shapes_and_names = dict()
for node in onnx_model.graph.value_info:
    end_node_shapes_and_names[node.name] = [x.dim_value for x in node.type.tensor_type.shape.dim]

outputs = []
o_names = []

# Absolutely cursed way of getting intermediate layer outputs
# Add layer to output layer, save model, reload model, loop for all layers
for name, shape in end_node_shapes_and_names.items():
    out_node = helper.make_tensor_value_info(name=name, elem_type=onnx.TensorProto.FLOAT, shape=shape)
    onnx_model.graph.output.append(out_node)
    model_path = './model_layers/' + name
    onnx.save_model(onnx_model, model_path)
    onnx_rt_sess = rt.InferenceSession(model_path)
    end_node_names = [name]
    feed_dict = {onnx_rt_sess.get_inputs()[0].name: imgData}
    output = np.array(onnx_rt_sess.run(end_node_names, feed_dict))
    outputs.append(output)
    o_names.append(name)

# output = prepare(onnx_model).run(imgData)  # run the loaded model

# x = output[0][0][0::3]
# y = output[0][0][1::3]

# # plot
# plt.plot(x, y, 'o', color='black')
# plt.imshow(img)

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
    dest = './data/irisUnity.bytes'
    
    try:
        os.remove(dest)
    except OSError:
        pass
    for i in range(0, len(weights)):
        write_weights(weights[i], dest)
        
    print("Done.")