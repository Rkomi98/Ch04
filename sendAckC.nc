/**
 *  Source file for implementation of module sendAckC in which
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
    
	//interface for timer
	interface Timer<TMilli> as Timer0;
	
    //other interfaces, if needed
	
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {
  bool FLAG;
  uint8_t last_digit = 7; // 6+1
  uint8_t counter=0;
  uint8_t rec_id = 62; //10562546
  message_t packet;

  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  void sendReq(uint8_t type, uint16_t counter, uint16_t data) {
	/* This function is called when we want to send a request - Read from the fake sensors
	 *
	 * STEPS:
	 * 1. Prepare the msg*/
	 sensor_msg_t* mess = (sensor_msg_t*)(call Packet.getPayload(&packet, sizeof(sensor_msg_t)));
	  if (mess == NULL) {
		return;
	  }
	 mess->type = type;
	 mess->data = data;
 	 mess->counter = counter;
	 dbg("radio_pack","Preparing the message... \n");
	 /* 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)*/
	 FLAG = requestAck( sensor_msg_t* mess );
	 /* Has to be changed!
	 if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_toss_msg_t)) == SUCCESS) {
		dbg("radio_send", "Sending packet");	
		locked = TRUE;
		dbg_clear("radio_send", " at time %s \n", sim_time_string());
      }
	 /** 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
 }        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raises the event read done.
  	 */
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted.\n");
	/* Fill it ... */
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
    /* Fill it ... */
  }
  
  event void SplitControl.stopDone(error_t err){
    /* Fill it ... */
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer according to your id. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
  }

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

  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) { // Data of fake sensors
	/* This event is triggered when the fake sensor finishes to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */

}

