# SHA256 GPULab Project

This is a project done in a laboratory course at the University of Stuttgart in Summer 2018.

The goal of the project was to showcase the power of modern GPUs compared to CPUs when it comes to huge parallelizable problem instances.

We thought about having a problem, that is easily parallelizable by exploiting data parallelism, has only a small amount of data transfer involved and is computationally expensive.

So we came up with the idea to inverse a cryptographic hash function, which is not theoretically not possible for many of these cryptographic hash function, unless a brute-force/dictionary-attack is performed. These kind of attack require a lot of computational power and it is not guaranteed that the inverse is found in finite time.

We decided to use SHA-256, since it was a very popular hash function at that time used for example in Bitcoin for block hashing.

## Implementation
On the CPU side, the hash is computed by the SHA module of the OpenSSL library.
On the GPU side, we developed a kernel which is capable of computing SHA256 hashes. 

Thanks to C++11, we could create two structures called wordStruct and outStruct and put them into a std::vector. This makes it possible to feed the GPU directly with the desired input for each kernel run and have an output, which is easy to handle.


## Results

We used two different systems for benchmarking. Since nearly all components and software versions differ between these systems, comparision between these systems is not possible.

|    System   |                         1                        |                 2                 |
|:-----------:|:------------------------------------------------:|:---------------------------------:|
|     CPU     | Intel Core i5-2500K (Sandy Bridge) @ 4.3GHz (OC) | Intel i7-5820K (Haswell) @ 3.3GHz |
|     RAM     |                     16GB DDR3                    |             32GB DDR3             |
|     GPU     |       Nvidia Geforce GTX 1060 (Pascal) 6GB       |    AMD Radeon R290 (Hawaii) 8GB   |
|      OS     |                 Ubuntu 18.04 LTS                 |          Ubuntu 16.04 LTS         |
|  GPU Driver |           Nvidia Driver Version 390.48           |     AMD Driver Version 16.60.3    |
| G++ version |                       7.3.0                      |               5.4.0               |


On the first system, we were able to unroll all for-loops within the kernel in compile time using #pragma unroll. This internally saves one if-command per iteration in the loop.

##### System 1
| Plaintext length |    Time    | Speed-up w/o \#pragma unroll | Speed-up w/ \#pragma unroll |
|------------------|:----------:|------------------------------|:---------------------------:|
| 3                |  Execution | 40.41                        |            63.98            |
|                  | Total Time | 19.68                        |            23.99            |
| 4                |  Execution | 56.99                        |            91.55            |
|                  | Total Time | 23.57                        |            27.94            |
| 5                |  Execution | 55.33                        |            93.70            |
|                  | Total Time | 23.18                        |            27.96            |
| 6                |  Execution | 56.13                        |            89.19            |
|                  | Total Time | 23.30                        |            27.54            |
##### System 2
| Plaintext length | Speed-up w/o memory copy time | Speed-up w/ memory copy time |
|:----------------:|:-----------------------------:|:----------------------------:|
|         3        |             51.81             |             31.75            |
|         4        |             95.94             |             45.35            |
|         5        |             191.77            |             29.47            |
|         6        |             192.80            |             29.19            |


More details can be found in the **report.pdf** file.
