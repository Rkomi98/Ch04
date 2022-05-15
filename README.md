# Ch04
In this challenge the main goal was to send periodic (periodicity of 1000 ms) request from Mote 1 to mote 2, without receiving any response. Then after time Y, Mote 2 responses X times. After that, the execution stopped.
According to the requirements as an X and Y parameters we are using:
 - Y = 62 
 - X = 6
So we will consider X+1 =7 response of Mote 2. 

As a first step of solving this challenge, we are specifying that we used the person code 10562546. According to the requirements as an X and Y parameters we are using:
Y = 62 and X = 6, so we will consider X+1 =7 response of Mote 2. 

Inside the folder provided we modified only the below files:
-	[SendAck.h](https://github.com/Rkomi98/Ch04/blob/Main/sendAck.h)
-	[SendAckAppC.nc](https://github.com/Rkomi98/Ch04/blob/Main/SendAckAppC.nc)
-	[RunSimulationScript.py](https://github.com/Rkomi98/Ch04/blob/Main/RunSimulationScript.py)
-	[SendAckC.nc](https://github.com/Rkomi98/Ch04/blob/Main/SendAckC.nc)

### SendAck.h
In the header file (SendAck.h) we defined the structure of the message that is going to be sent by the motes. The message contains the:
- **msg_type**, which in case of a request message is going to have the value 1 and in case it is a response is going to have the value 2. 
- **msg_counter**, which is filled by mote 1 in each request message sent and then by mote 2 in the response messages.
- **value**, which is the value of the fake sensor filled by mote 2 in the response message.

