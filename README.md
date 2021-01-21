# Mini-Stereo-Digital-Audio-Processor-MSDAP
This is a project of ASIC. MSDAP is a low-cost, low-power and application specific mini stereo digital audio processor used in a hearing aid. The main function of this processor is a two-channel, 256 order, finite impulse response (FIR) digital filter. It receives 16 bits voice data(sampled at 50 kHz) and computes the FIR result at the speed of 25.MHz.

![Architected of MSDAP](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/MSDAP.jpg)

The core function of MSDAP is a FIR filter.The FIR algorithm comes from this paper, which proposed a equation to calculate convolution only required finite integer addition/subtraction and right shift instead of multiplication.Such algorithm largely reduce the complexity of hardware architecture as well as cost and power consumption.
As shown below,the convolution in equation(1) is converted to equation (2) and (3).

 <p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/equation.png" alt="Equations">
 </p>

So from the equation above we can see that all the float point coefficient are turn into integer uj data.The uj data can be further decomposed to rj and uj data,which further compress the data and reduce the memory required.The rj indicates how many terms are in one uj equation and uj data indicates which previous input data will be used.

 <p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/22.png" alt="EQ">
 </p>

Before implementing this algorithm in Verilog I verified it in C. And the C code really helped me a lot when I was writing and debugging Verilog code. Here is the computing part in C:


After verifying the algorithm and having a big picture of the system,I started to designed the architecture in Verilog.The picture below shows the system diagram of MSDAP.What the MSDAP does can be put into 2 groups: receiving/storing data and computing/sending data. Two finite state machines(FSM) are used to determine the workflow of the chip.
  
<p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/system.png" alt="System">
 </p>

As for the FSM, there are 9 state in the chip, starting from initialization to sleeping mode.After initialization the chip should receive rj data and coefficient data. And then it’s ready for FIR computing. When it’s in working mode, the chip will go to sleep to reduce power consumption if it receive 800 successive zeros on both channels.

 <p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/FSM.png" alt="MSDAP FSM">
 </p>

The data format is described in the following figure.Since we use integer to do the FIR computation so we need to extend the data range in order to keep the precision. So the 16 bit input data is extended to 40 bit data before computation.

<p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/41.png" alt="MSDAP Data Format">
 </p>


# Implementation in Verilog:

*1.FSM*

The FSM used in this project is moore machine and there are two FSM in the code and each FSM consists of 3 processes:

Determine State:  Determine the next state base on current information.

Change State: current_state <= next_state

Data Process:  The data process implementation of each state

Since the implementation of FSM and data processing are separated so it’s easier to code,debug and synthesize.

*2. Nosignal_Detect*

The chip goes into sleeping mode after receiving 800 successive zeros on both channels. From 0 to 798 there are 799 zeros, FSM go into sleep at 800th circle. However, if the 800th value is not zero then FSM would be put into working mode immediately.

*3.Receive_data*

Since the voice data would come in over and over again, so it’s impossible to save all the data. Actually only 256 memory size is needed. So we used a circle buffer of size 256.Buffer_head indicate where the current data is located and buffer circle indicates if the number of data in buffer greater then 256.And we also need a pointer to find which previous voice data is needed when calculating uj. 

Resetting data is basically setting the buffer head to zero and discarding the receive data.

*4.Data computing and sending*

This part contains 7 states, computing process and sending data process:

s0,s1      :initialize

s2         :computing each uj (512 sclk)

s3         :sum=(sum+uj)>>1 (16 sclk)

s5         :inform testbench it’s ready to send data and wait for “frame” signal

s6         :shifting out the data through outputL outputR (40 sclk)

s7         :finish the sending, go back to s0

*5. Testbench and Simulation Results*

To ensure that our architecture matches with the verified behavior of the MDAP we present below the Modelsim simulation of our structural model Verilog code.

![MSDAP Simulation](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/MODELSIM.PNG)

This project is tested with 7000 input data so it’s impossible to verified the correctness of output by eyes(you could but who wants to :P) .So I used a XOR gate to verify the data.


# Synthesis With DC:

I have Synthesis the Design using Design Compiler and met my Constranits 

Frequency of sclk    | 25 MHZ 
-------------        | ------------- 
Total Dynamic Power  | 42.1118 mW  
Leakage Power        | 37.3090 uW
Total Chip Area      | 2.9835mm2
Technology node      | SMIC 180nm

and the MSDAP CHIP 

 <p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/dc_schematic.PNG" alt="MSDAP CHIP">
 </p>

and the Critical Path

![Critical Path](https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/worst_slak.PNG)

# PnR Flow:

I implemented the design using SMIC 180nm by IC Compiler

<p align="center"> 
    <img src="https://github.com/abdelazeem201/Mini-Stereo-Digital-Audio-Processor-MSDAP/blob/main/Pics/Physical%20Design%20Layout.png" alt="Physical Design">
 </p>

# Conclusion

*In this project, the low power and low cost MSDAP has been presented and designed in SMIC 180nm CMOS technolog.*

*The total chip area is about 2.9mm2 and the power dissipationis about 45 mw* 

*END*


