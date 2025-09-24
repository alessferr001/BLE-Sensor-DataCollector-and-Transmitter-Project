#include <WaspBLE.h>
#include <WaspSensorEvent_v30.h>//This is not part of the waspote board.


// Auxiliary variables
uint8_t flag = 0;
uint16_t handler = 0;

void setup() 
{  

}


void loop() 
{
  
  BLE.ON(SOCKET0);
  // 1. Make Waspmote visible to other BLE modules
  BLE.setDiscoverableMode(BLE_GAP_GENERAL_DISCOVERABLE);

  // 2. Make Waspmote connectable to any other BLE device
  BLE.setConnectableMode(BLE_GAP_UNDIRECTED_CONNECTABLE);
  USB.println(F("Waiting for incoming connections..."));

  // 3. Wait for connection status event during 30 seconds. 
  flag = BLE.waitEvent(30000);
  if (flag == BLE_EVENT_CONNECTION_STATUS)
  {
    USB.println(F("Connected!"));
    USB.println(F("Now Waspmote is connected as slave.")); 


    // 3.3 Parse connection handler. other information about status not used in this example.
    BLE.connection_handle = BLE.event[4];

    // 4 Now wait to other events forever. If disconnection is detected, exit loop and start again
    flag = 0;
    while(flag != BLE_EVENT_CONNECTION_DISCONNECTED)
    {

      // 4.1 Wait for indication event 
      USB.println(F("Waiting events..."));
      flag = BLE.waitEvent(5000);

      if (flag == BLE_EVENT_ATTRIBUTES_STATUS)
      {
        USB.println(F("Status event found"));

        // 4.2 look if one attribute has been indicated. flag = 2 means that indications are enabled.
        /* status event structure:
         Field:   | Message type | Payload| Msg Class | Method |  Handle | Flags |
         Length:  |       1      |    1   |     1     |    1   |    2    |    1  |
         Example: |      80      |   10   |     02    |   02   |    00   |   02  |
         */

        if(BLE.event[6] == 2)
        {
          // 4.3 Subscription received.
          handler = ((uint16_t)BLE.event[5] << 8) | BLE.event[4];
          USB.print(F("The master has suscribed to indications of the attribute with handle: "));
          USB.println(handler, DEC);
          
          //effettuare 3 sensing successivi ed inviarli separatamente nel seguente ordine: temperatura, pressione, umidità

          Events.ON();
          
          for (uint8_t a = 1; a <= 3; a++){
            
            if(a==1){

              char tempValue[10];
              Utils.float2String(Events.getTemperature(),tempValue,2);
              flag = BLE.writeLocalAttribute(handler, BLE_INDICATE_ENABLED, tempValue);

              
              if (flag == 1)
              {
                // parse handler
                handler = ((uint16_t)BLE.event[6] << 8) | BLE.event[5];
                USB.print("Attribute ");
                USB.print(handler, DEC);
                USB.println(" Indicated!");
  
                /* NOTE: if the master unsubscribes during this loop, then the event will be missed.
                 This is not managed by this example and the user should add his own code to handle it.
                 */
              }
              else
              {
                USB.print("Error writing. flag = ");
                USB.println(flag, DEC);
              }
  
              // 4.4.3 Wait 5 seconds till change the attribute value
              delay(2000);
                
            }//Temperatura

            if(a==2){
              
              char pressValue[10];
              Utils.float2String(Events.getTemperature(),pressValue,2);
              flag = BLE.writeLocalAttribute(handler, BLE_INDICATE_ENABLED, pressValue);
              
              if (flag == 1)
              {
                // parse handler
                handler = ((uint16_t)BLE.event[6] << 8) | BLE.event[5];
                USB.print("Attribute ");
                USB.print(handler, DEC);
                USB.println(" Indicated!");
  
                /* NOTE: if the master unsubscribes during this loop, then the event will be missed.
                 This is not managed by this example and the user should add his own code to handle it.
                 */
              }
              else
              {
                USB.print("Error writing. flag = ");
                USB.println(flag, DEC);
              }
  
              // 4.4.3 Wait 5 seconds till change the attribute value
              delay(2000);
              
            }//Pressione 

            if(a==3){
              
              char humValue[10];
              Utils.float2String(Events.getTemperature(),humValue,2);
              flag = BLE.writeLocalAttribute(handler, BLE_INDICATE_ENABLED, humValue);

              
              if (flag == 1)
              {
                // parse handler
                handler = ((uint16_t)BLE.event[6] << 8) | BLE.event[5];
                USB.print("Attribute ");
                USB.print(handler, DEC);
                USB.println(" Indicated!");
  
                /* NOTE: if the master unsubscribes during this loop, then the event will be missed.
                 This is not managed by this example and the user should add his own code to handle it.
                 */
              }
              else
              {
                USB.print("Error writing. flag = ");
                USB.println(flag, DEC);
              }
  
              // 4.4.3 Wait 5 seconds till change the attribute value
              delay(2000);
              
            }//Umidità


          } // End for loop.
     
          Events.OFF();
          
        }
        else 
        {
          // 4.2.1 Indicate subscription not received
          USB.println(F("Master not subscribed"));
        }
      }
      else
      {
        // 4.1.1 Maybe Other event found
        if (flag != 0)
        {          
          // Other event received from BLE module
          USB.print(F("Event found. flag = "));
          USB.print(flag, DEC);
        }
        else 
        {
          // no event received. 
          USB.println(F("No event received"));

        }
      }

      //4.5 get status. If not connected, exit.
      if (BLE.getStatus(BLE.connection_handle) == 0)
      {        
        BLE.disconnect(BLE.connection_handle);
        break;
      }

    } // end while

    // 4. if here, disconnected.
    USB.println(F("Disconnected"));    

  }//--if flag==connection status
  else 
  {
    if (flag == 0)
    {
      // If there are no events, then no one tried to connect Waspmote
      USB.println(F("No events found. No devices tried to connect Waspmote."));
    }
    else
    {
      // Other event received from BLE module
      USB.print(F("Other event found. flag = "));
      USB.println(flag, DEC);
    }
  }

  BLE.OFF();
  
  USB.println(F("Go to sleep mode..."));
  PWR.deepSleep("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);
  USB.println(F("Wake Up!!\r\n"));
  
  //put in deep sleep in the waspmote, RTC_OFFSET Absolute specific time, RTC_OFFSET OffSet time from now, All off (all the board is off)
  
}




















