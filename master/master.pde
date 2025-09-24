#include <WaspBLE.h>
#include <WaspWIFI_PRO.h> 
#include <WaspFrame.h>

// MAC address of BLE device to find and connect.
char MAC[14] = "886B0F47E825";
uint8_t socket = SOCKET1;

// choose URL settings
///////////////////////////////////////
char type[] = "http";
char host[] = "10.10.10.1";
char port[] = "80";
///////////////////////////////////////

uint8_t error;
uint8_t status;
unsigned long previous;


// define the Waspmote ID 
char moteID[] = "BLE_group";

// Aux variable
uint16_t flag = 0;

int receivedPackets = 0;
int lastIndex = 0;


float tempValues[10];
float humidityValues[10];
float pressureValues[10];


void setup() 
{  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
  frame.setID(moteID);  

}

void loop() 
{

  flag = 0;

  // 1. Look for a specific device
  USB.print("Scan for device: ");
  USB.println(MAC);
  if (BLE.scanDevice(MAC) == 1)
  {
    // 2. Now try to connect with the defined parameters.
    USB.println(F("Device found. Connecting... "));
    flag = BLE.connectDirect(MAC);

    if (flag == 1) 
    {
      
      
      USB.print("Connected. connection_handle: ");
      USB.println(BLE.connection_handle, DEC);

      /* 4. Subscribe to indications of one characteristic. 
       In this case an attribute with handler 48.
       
       NOTE 1: the client characteristic configuration attribute of 
       this characteristic has the handler 50.
       
       NOTE 2: To subscribe indications it is necessary to write a '2'
       */
       
      USB.println(F("Subscribing to indications on characteristic 1.5"));
      char indicate[2] = "2";
      flag = BLE.attributeWrite(BLE.connection_handle, 50, indicate);

      if (flag == 0)
      {
        /* 5. Indication subscription successful. Now start a loop till 
         receive 3 indication or timeout is reached (30 seconds). If disconnected, 
         then exit while loop.
         
         NOTE 3: 5 indications are done by the example BLE_13.
         */
        unsigned long previous = millis();
        int eventCounter = 0;
        
        float lastTemp;
        float lastPres;
        float lastHum;
  
        while (( eventCounter <  3) && (millis() - previous) < 30000)
        {
          // 5.1 Wait for indicate event. 
          USB.println(F("Waiting events..."));
          flag = BLE.waitEvent(5000);

          if (flag == BLE_EVENT_ATTCLIENT_ATTRIBUTE_VALUE)
          {

            //Accendere led quando ricevo
            Utils.setLED(LED0, LED_ON);
            Utils.setLED(LED1, LED_ON);
            
            USB.println(F("Indication received."));

            delay(2000);

            Utils.setLED(LED0, LED_OFF);
            Utils.setLED(LED1, LED_OFF);

            /* attribute value event structure:
             Field:   | Message type | Payload| Msg Class | Method |  Connection |...
             Length:  |       1      |    1   |     1     |    1   |      1      |...
             Example: |      80      |   05   |     04    |   05   |     00      |...
             
             ...| att handle | att type | value |
             ...|     2      |     8    |   n   |
             ...|   30 00    |     x    |   n   |
             */
     
            
            // 5.2 Extract the handler from the received event saved on the buffer BLE.event

            uint16_t handler = ((uint16_t)BLE.event[6] << 8) | BLE.event[5];
            USB.print("attribute with handler ");
            USB.print(handler, DEC);
            USB.println(" has changed. ");
            USB.println();

            char temp[BLE.event[8]];
            char pres[BLE.event[8]];
            char hum[BLE.event[8]];
            
            //Temp
            if(eventCounter == 0){
                USB.print("Temp: ");

                for(uint8_t i = 0; i < BLE.event[8]; i++)
                {
                  temp[i]=BLE.event[i+9];
                       
                }
                
                lastTemp = atof(temp);
                USB.println();
            }

            //Press
            if(eventCounter == 1){
                USB.print("Press: ");
                for(uint8_t i = 0; i < BLE.event[8]; i++)
                {
                  pres[i]=BLE.event[i+9];  
                }
                
                lastPres = atof(pres);
                USB.println();
            }


            //Hum
            if(eventCounter == 2){
                USB.print("Hum: ");
                for(uint8_t i = 0; i < BLE.event[8]; i++)
                {
                  hum[i]=BLE.event[i+9]; 
                }
                
                lastHum = atof(hum);
                USB.println();
                
            }
         
            USB.println(F("Indicate acknowledge event automatically sent to the slave."));
            USB.println();
            
            eventCounter++;
            flag = 0;
            
          }
          else
          {
            // 5.4 If disconnection event is received, then exit the while loop.
            if (flag == BLE_EVENT_CONNECTION_DISCONNECTED)
            {
              break;
            }
          }

          // Condition to avoid an overflow (DO NOT REMOVE)
          if( millis() < previous ) previous=millis();

        } // end while loop

        delay(2000);

        if(eventCounter==3){

          
            receivedPackets++;
            USB.print("Received packets: ");
            USB.println(receivedPackets);

            USB.print("Last Temp: ");
            USB.printFloat(lastTemp,2);
            USB.println();
            USB.print("Last Pres: ");
            USB.printFloat(lastPres,2);
            USB.println();
            USB.print("Last Hum: ");
            USB.printFloat(lastHum,2);

            USB.println();

            USB.print("Last index: ");
            USB.println(lastIndex);

            tempValues[lastIndex] = lastTemp;
            pressureValues[lastIndex] = lastPres;
            humidityValues[lastIndex] = lastHum;
            
            lastIndex = (lastIndex+1)%10;
            
            
            //convertire i dati da char a float e salvarli nell'ultima posizione dei rispettivi array
           
            if(receivedPackets%10==0){

             USB.println("Computation");
             
              float avgT = 0;
              float avgH = 0;
              float avgP = 0;
  
              for(uint8_t i = 0; i < 10; i++)
              {
                  avgT+=tempValues[i];
                  avgH+=humidityValues[i];
                  avgP+=pressureValues[i];      
              }

              avgT = avgT/10;
              avgH = avgH/10;
              avgP = avgP/10;
  
              USB.println(F("Average temperature is: "));
              USB.printFloat(avgT,2);
          
              USB.println(F("Average pressure is: "));
              USB.printFloat(avgH,2);
          
              USB.println(F("Average humidity is: "));
              USB.printFloat(avgP,2);
              
              float scartiQT = 0;
              float scartiQH = 0;
              float scartiQP = 0;
              
              for(uint8_t i = 0; i < 10; i++)
              {
                  scartiQT+=(tempValues[i]-avgT)*(tempValues[i]-avgT);
                  scartiQH+=(humidityValues[i]-avgH)*(humidityValues[i]-avgH);
                  scartiQP+=(pressureValues[i]-avgP)*(pressureValues[i]-avgP);
                      
                  tempValues[i]=0;
                  humidityValues[i]=0;
                  pressureValues[i]=0;
                  
              }

              float StdTemperature = sqrt(scartiQT/10);
              float StdHumidity = sqrt(scartiQH/10);
              float StdPressure = sqrt(scartiQP/10);
              
              USB.println(F("Standard Deviation of temperature is: "));
              USB.printFloat(StdTemperature,2);
              
              USB.println(F("Standard Deviation of humidity is: "));
              USB.printFloat(StdHumidity,2);
              
              USB.println(F("Standard Deviation of pressure is: "));
              USB.printFloat(StdPressure,2);

              char STD_Temperature[10];
              char avg_temp[10];

              Utils.float2String(avgT,avg_temp,2);
              Utils.float2String(StdTemperature,STD_Temperature,2);
              
              char STD_Pressure[10];
              char avg_press[10];

              Utils.float2String(avgP,avg_press,2);
              Utils.float2String(StdPressure,STD_Pressure,2);
              
              char STD_Humidity[10];
              char avg_hum[10];

              Utils.float2String(avgH,avg_hum,2);
              Utils.float2String(StdHumidity,STD_Humidity,2);
              


                //Send to the gateway
                error = WIFI_PRO.ON(socket);

                if (error == 0)
                {    
                  USB.println(F("WiFi switched ON"));
                }
                else
                {
                  USB.println(F("WiFi did not initialize correctly"));
                }

                status =  WIFI_PRO.isConnected();

                // check if module is connected
                if (status == true)
                {    
                  USB.print(F("WiFi is connected OK"));
                  USB.print(F(" Time(ms):"));    
                  USB.println(millis()-previous);
              
                  ///////////////////////////////
                  // 3.1. Create a new Frame 
                  ///////////////////////////////
                  
                  // create new frame (only ASCII)
                  frame.createFrame(ASCII); 
              
                  // add sensor fields
                  frame.addSensor(SENSOR_STR, STD_Temperature);
                  frame.addSensor(SENSOR_STR, avg_temp);
                  
                  frame.addSensor(SENSOR_STR, STD_Pressure);
                  frame.addSensor(SENSOR_STR, avg_press);

                  frame.addSensor(SENSOR_STR, STD_Humidity);
                  frame.addSensor(SENSOR_STR, avg_hum);
                  
                 
              
                  // print frame
                  frame.showFrame();  
              
              
                  ///////////////////////////////
                  // 3.2. Send Frame to Meshlium
                  ///////////////////////////////
              
                  // http frame
                  error = WIFI_PRO.sendFrameToMeshlium( type, host, port, frame.buffer, frame.length);
              
                  // check response
                  if (error == 0)
                  {
                    USB.println(F("HTTP OK"));          
                    USB.print(F("HTTP Time from OFF state (ms):"));    
                    USB.println(millis()-previous);
                  }
                  else
                  {
                    USB.println(F("Error calling 'getURL' function"));
                    WIFI_PRO.printErrorCode();
                  }
                }
                else
                {
                  USB.print(F("WiFi is connected ERROR")); 
                  USB.print(F(" Time(ms):"));    
                  USB.println(millis()-previous);  
                }
              
              
                //////////////////////////////////////////////////
                // 3. Switch OFF
                //////////////////////////////////////////////////  
                WIFI_PRO.OFF(socket);
                USB.println(F("WiFi switched OFF\n\n")); 

                
            }//computation and sending to the sink
        }

        // 6. Disconnect. Remember that after a disconnection, 
        // the slave becomes invisible automatically.
        if (BLE.getStatus(BLE.connection_handle) == 1)
        {
          flag = BLE.disconnect(BLE.connection_handle);
          if (flag != 0) 
          {
            if (flag == 534)
            {
              USB.println(F("Disconected."));
              USB.println(F("Connection Terminated by Local Host"));
              USB.println();
              USB.println();
            }
            else
            {
              // Error trying to disconnect
              USB.print("disconnect fail. flag = ");
              USB.println(flag, DEC);
            }
          }
          else
          {
            USB.println(F("Disconnected."));
            USB.println();
            USB.println();
          } 
        }
        else
        {
          // Already disconnected
          USB.println(F("Disconnected.."));
          USB.println();
        } 
      }
      else
      {
        // 4.1 Failed to subscribe.
        USB.println(F("Failed subscribing."));
        USB.println();
      }
    }
    else
    {
      // 2.1 Failed to connect
      USB.println(F("NOT Connected"));
      USB.println();  
    }
  }
  else
  {
    // 1.1 Scan failed.
    USB.println(F("Device not found: "));
    USB.println();
  }
  
}





















