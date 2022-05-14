/**
 *  Source file for implementation of module send
 AckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
    //interfaces for communication
    interface Receive;
    interface AMSend;
    interface SplitControl;
    interface Packet;
    interface PacketAcknowledgements;
    
	//interface for timer
	interface Timer<TMilli> as Timer;
	
    //other interfaces, if needed
	
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {
  //bool FLAG;
  uint8_t last_digit = 6; // 6+1?
  uint8_t counter=0;
  uint8_t i=0;
  //uint8_t counter2=0; // Do we need it?
  uint8_t rec_id = 62; //10562546
  message_t packet;

  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  void sendReq() {
	/* This function is called when we want to send a request - Read from the fake sensors
	 *
	 * STEPS:
	 * 1. Prepare the msg*/
	 my_msg_t* mess = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t)));
	  if (mess == NULL) {
		return;
	  }
	 mess->type = REQ;
	 //mess->data = data;
 	 mess->counter = counter;
	 dbg("radio_pack","Preparing the message... \n");
	 /* 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)*/ 
	 
	 if(call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {
	 /** 3. Send an UNICAST message to the correct node //**HOW?**
	 * X. Use debug statements showing what's happening (i.e. message fields)*/
  		if(call AMSend.send(RESP, &packet, sizeof(my_msg_t)) == SUCCESS){
  			dbg("radio", "REQ sent with counter %d and data: %d \n", counter, mess->data);
  			counter++;
  			}
  		}
	 }        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.*/
  	/*
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raises the event read done.
  	 */
  	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted on Mote %d\n", TOS_NODE_ID);
	call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
    if(err == SUCCESS) {
    	dbg("radio", "Radio on on node %d!\n",TOS_NODE_ID);
    	if (TOS_NODE_ID == REQ){
           call Timer.startPeriodic( 1000 );
  		}
    }
    else{
	//dbg for error
	dbgerror("radio", "Radio failed to start, retrying...\n"); //dbg(class of debug, message)
	call SplitControl.start();
    }
  }
  
  event void SplitControl.stopDone(error_t err){
    dbg("boot", "Radio stopped!\n");
  }

  //***************** MilliTimer interface ********************//
  event void Timer.fired() {
	/* This event is triggered every time the timer fires.*/
	sendReq();
	 //* When the timer fires, we send a request
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent*/
	 if (&packet == buf) {//&& error == SUCCESS
      dbg("radio_send", "Packet sent...");
      dbg_clear("radio_send", " at time %s \n", sim_time_string());
      if (call PacketAcknowledgements.wasAcked(&packet)&&counter>rec_id+last_digit+1){
      	call Timer.stop();
      }
      else{
      	dbg_clear("radio_ack", "Packet not acknowledged \n");
      }
    }
    else{
      dbgerror("radio_send", "Send done error!");
    }
   }
    /*
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer according to your id. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 if(len != sizeof(my_msg_t)) {
  		dbgerror("radio_pack", "Packet malformed\n");
  		return buf;
  	}
  	else {
  		my_msg_t* mess = (my_msg_t*)payload;
  		
  		dbg("radio_rec", "Received a message at time %s\n", sim_time_string());
  		/*dbg_clear("packet", "\t\tType: %u\n", mess->type);
  		dbg_clear("packet", "\t\tCounter: %u\n", mess->counter);
  		dbg_clear("packet", "\t\tValue: %u\n", mess->data);*/
  		
  		if(mess->type == REQ) {
  			counter = mess->counter;
  			sendResp();
  		}
  		
  		return buf;  	
  	}

  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data2) { // Data of fake sensors
	/* This event is triggered when the fake sensor finishes to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)*/
	 my_msg_t* mess = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t)));
	 if(mess == NULL){
  		return;
  	 }
  	 mess->type = RESP;
  	 mess->counter = counter;
  	 mess->data = data2;
	 /** 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
	 if(call PacketAcknowledgements.requestAck(&packet) == SUCCESS) {
  		if(call AMSend.send(REQ, &packet, sizeof(my_msg_t)) == SUCCESS){
  			dbg("radio_send", "RESP sent %d, %d \n",data2, counter); //	dbg("radio", "REQ sent with counter %d \n", counter);
  			}
  		}
  	}
  }
