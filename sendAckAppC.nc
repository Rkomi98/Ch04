/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"

configuration sendAckAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendAckC as App;
  //add the other components here
  
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC() as Timer;
  components ActiveMessageC;
  components new FakeSensorC();

/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  //App.AMControl -> ActiveMessageC;

  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC;
  
  //Timer interface
  App.Timer -> Timer;
  
  // Fake Sensor read
  App.Read -> FakeSensorC;

}

