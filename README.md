# EE314-Quality-of-Service-Based-Queuing
Basically, Quality of Service (QoS)
networks are developed to control the data traffic to optimize the network capacity. In this project,
we have implemented a queuing algorithm using Verilog HDL on FPGAs.

Visualization of the QoS system is transferred to the monitor through VGA implementation. 
Priority Queuing and First in & First out the implementation are utilized in that system.
4-bit input data are stored inside four different buffers, and each buffer consists of 6 boxes. 
The weight of each buffer is designed and determined according to the designed buffer weight table.
Upper pink box shows readed data from buffers. Lower pink data shows entered 4 bit data synchronously. 


QoS project video presentation is provided link below. 

https://youtu.be/pKJ2QgwZ-wY



Each buffers' weight is designed according to following table.
![Copy of priority table](https://user-images.githubusercontent.com/88316097/178002606-d37c98ef-96a1-4653-8f34-9f0710c4cf9e.png)


Monitored VGA screen is shownn below too. 

![fig3](https://user-images.githubusercontent.com/88316097/178003329-bfa16853-c546-4419-800e-a23f3e930faf.png)


![fig4](https://user-images.githubusercontent.com/88316097/178003207-b19797ea-6b06-44ef-84b7-b878a80f09e9.png)

VGA implementation diagram is designed according to following schematic.

![5  general block diagram](https://user-images.githubusercontent.com/88316097/178036638-d3c7b32d-d849-41bb-8b5c-0065a0bd69a4.png)

Some Testbench results of the QoS system can be found in the following results. 

![figure1](https://user-images.githubusercontent.com/88316097/178003594-07e274a7-ff0d-4a46-98c4-fc63d29ddf6d.png)

![figure2](https://user-images.githubusercontent.com/88316097/178003668-3b400124-6ab7-4bed-ba5d-72f5fd21ecb2.png)


