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

### SendAckAppC.nc
In the application file (SendAckAppC.nc) we added all the useful components and the wiring. 
- The components are: MainC, sendAckC as App, TimerMilliC as Timer.
- The components used for the communication are: 
AMSenderC, AMReceiverC, ActiveMessageC and FakeSensorC to generate the values from the fake sensor.

For the wiring of:
- Send and Receive interfaces we used: 
   ```
   App.Receive -> AMReceiverC;
  	App.AMSend -> AMSenderC;
   ```
- interfaces to access package fields:
   ```
	  App.Packet -> AMSenderC;
  	App.PacketAcknowledgements -> AMSenderC;
   ```
- fake sensor:
   ```
	  App.Read -> FakeSensorC;
   ```
### SendAckC.nc
We implemented the logic, writing the code in the SendAckC.nc file, following the template instructions. In the code, after mote 1 and mote 2 boot, they turn on their radio, but only mote 1 has a timer which starts after booting and works with a periodicity of 1000 milliseconds. Every time the clock is Fired the function sendReq is called. In this function mote 1 creates a new request message, each time, and sends it to mote 2 requesting for an acknowledgment. Since it doesn’t receive an acknowledgment, it increments the counter.
For every packet sent and not acknowledged, mote 1 continues sending packets every time the timer is fired, so after one second the first message is sent. If the packet will be acknowledged by mote 2, the timer will stop.

Mote 2 doesn’t use a timer but waits for the message from mote 1, arriving after Y seconds, so in our case after 62 seconds. When mote 2 receives a request message from mote 1 and this message is not malformed, it prints the time when this message is received, saves the counter and as a final step goes to sendResp function.

This function reads a value from the fake sensor component through read.Read(). 
The last function executed is readDone. In this function mote 2 creates a new response message, which will contain the saved counter and the random value from the fake sensor. As a last step, it sends this packet to mote 1, requesting for an acknowledgement. This is repeated X+1 times so in our case, 7 times. After this, the simulation is done.

### RunSimulationScript.py
Last but not least we modified the RunSimulationScript.py, only adding the value of Y (line 13 of the code) and modifying the time for Mote 2 (line 64).
