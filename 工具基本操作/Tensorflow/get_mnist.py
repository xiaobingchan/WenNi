from tensorflow.examples.tutorials.mnist import input_data
import matplotlib.pyplot as plt

mnist = input_data.read_data_sets("MNIST_data/",one_hot=True)
print(mnist.train.images.shape)
#打印对应的标签
print(mnist.train.labels.shape)
#获取第6张图片
image = mnist.train.images[5,:]
#将图像数据还原成28*28的分辨率
image = image.reshape(28,28)


plt.figure()
plt.imshow(image)
plt.show()
