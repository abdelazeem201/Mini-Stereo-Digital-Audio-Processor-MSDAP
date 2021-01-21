# Mini-Stereo-Digital-Audio-Processor-MSDAP
This is a project of ASIC. MSDAP is a low-cost, low-power and application specific mini stereo digital audio processor used in a hearing aid. The main function of this processor is a two-channel, 256 order, finite impulse response (FIR) digital filter. It receives 16 bits voice data(sampled at 50 kHz) and computes the FIR result at the speed of 25.MHz.

![Architected of MSDAP](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/MSDAP.jpg)

The core function of MSDAP is a FIR filter.The FIR algorithm comes from this paper, which proposed a equation to calculate convolution only required finite integer addition/subtraction and right shift instead of multiplication.Such algorithm largely reduce the complexity of hardware architecture as well as cost and power consumption.
As shown below,the convolution in equation(1) is converted to equation (2) and (3).

 ![Equations](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/equation.png)

So from the equation above we can see that all the float point coefficient are turn into integer uj data.The uj data can be further decomposed to rj and uj data,which further compress the data and reduce the memory required.The rj indicates how many terms are in one uj equation and uj data indicates which previous input data will be used.

 ![Equations](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/22.png)

Before implementing this algorithm in Verilog I verified it in C. And the C code really helped me a lot when I was writing and debugging Verilog code. Here is the computing part in C:


After verifying the algorithm and having a big picture of the system,I started to designed the architecture in Verilog.The picture below shows the system diagram of MSDAP.What the MSDAP does can be put into 2 groups: receiving/storing data and computing/sending data. Two finite state machines(FSM) are used to determine the workflow of the chip.
  
![System](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/system.png)

As for the FSM, there are 9 state in the chip, starting from initialization to sleeping mode.After initialization the chip should receive rj data and coefficient data. And then it’s ready for FIR computing. When it’s in working mode, the chip will go to sleep to reduce power consumption if it receive 800 successive zeros on both channels.

 ![MSDAP FSM](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/FSM.png)

The data format is described in the following figure.Since we use integer to do the FIR computation so we need to extend the data range in order to keep the precision. So the 16 bit input data is extended to 40 bit data before computation.

![MSDAP data Format](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/41.png)


# Implementation in Verilog:

