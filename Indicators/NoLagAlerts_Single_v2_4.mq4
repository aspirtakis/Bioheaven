//+------------------------------------------------------------------+
//|                           NonLagAlerts_Single_v2.4               |
//|                        Copyright 2016 SmoothTrader               |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_buffers 2       
#property indicator_color1 Blue     
#property indicator_color2 Red     

//=============================
 
 
 extern bool AlertsAndMessages = false;
 extern int dist = 100; // Distance Arrow is from High or Low
 extern int BarCount = 200; // Set how many bars to look back
 
 double RedHigh;
 double BlueLow;
 double Buf0[];
 double Buf1[];  
  
 bool FirstBlueSignal = true;
 bool FirstRedSignal = true;  
 bool BlueSignal = false;
 bool RedSignal = false;
 bool NewBar;

 datetime opp1, opp2;  

string Message2;     
//--------------------------------------------------------------------
int init()                         
  {
   SetIndexBuffer(0,Buf0);         
   SetIndexStyle (0,DRAW_ARROW, STYLE_SOLID, 3);
   SetIndexArrow(0, 225);
   SetIndexBuffer(1,Buf1);         
   SetIndexStyle (1,DRAW_ARROW, STYLE_SOLID, 3);
   SetIndexArrow(1, 226); 
   return(0);                            
  }
//--------------------------------------------------------------------
int start()                         
  {
   int i, cnt; 
   
   double blue_signal,red_signal;
  
//==================================================================== 


CheckNewBar();

if(NewBar == true)
{


    
   i = BarCount;          
   while(i >=1)
                        
     {
      Buf1[i] = 0;
      Buf0[i] = 0;
      blue_signal  = iCustom(NULL,0,"nonlagdot",1,i); 
      red_signal  = iCustom(NULL,0,"nonlagdot",2,i); 
      
       if (iCustom(NULL,0,"nonlagdot",1,(i+1)) == 0 && iCustom(NULL,0,"nonlagdot",1,i) > 0) 
          {
          FirstBlueSignal = true;
          FirstRedSignal = false;
          Buf1[i] = 0;
          }
            
       if(iCustom(NULL,0,"nonlagdot",2,(i+1)) == 0 && iCustom(NULL,0,"nonlagdot",2,i) > 0) 
        {
             FirstRedSignal = true;
             FirstBlueSignal = false;
             Buf0[i] = 0;
         } 
      


      if(blue_signal > 0 && Close[i] < Open[i] && FirstBlueSignal == true) 
         {        
          Buf0[i] = Low[i] - dist*Point;
          Buf1[i] = 0;      
          FirstBlueSignal = false;   
          BlueLow = High[i];
          BlueSignal = true;
          RedSignal = false;
          RedHigh = 10000;
          
          if(i==1 && opp1 != Time[0] && AlertsAndMessages == true)
            {
             opp1 = Time[0];    
             Alert(StringConcatenate("ALERT - Stop Buy Signal ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES)));        
             Message2 = StringConcatenate("Buy STOP ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES));            
             SendNotification(Message2);
             SendMail("NonLagDot Signal",Message2);
            
            }    
                 
         }      


      if(red_signal > 0 && Close[i] > Open[i] && FirstRedSignal == true) 
         {
          Buf1[i] = High[i] + dist*Point;
          Buf0[i] = 0;
          FirstRedSignal = false;
          RedHigh = Low[i];
          RedSignal = true;
          BlueSignal = false;
          BlueLow = 0;
          
         
         
          if(i==1 && opp2 != Time[0] && AlertsAndMessages == true)
            {
             opp2 = Time[0];
             Alert(StringConcatenate("ALERT - Stop Sell Signal ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES)));
             Message2 = StringConcatenate("SELL STOP ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES));            
             SendNotification(Message2);
             SendMail("NonLagDot Signal",Message2);
            }
               
         } 
 
         if(BlueSignal == true && High[i] > BlueLow)
           {
             BlueSignal = false;
             BlueLow = 0;
           }
           
        if(RedSignal == true && Low[i] < RedHigh)
           {
             RedSignal = false;
             RedHigh = 10000;
           }


         if(BlueSignal == true && Close[i] < Open[i] && High[i] < BlueLow && blue_signal > 0)
            {
              Buf0[i] = Low[i] - dist * Point;
              Buf1[i] = 0;
              BlueLow = High[i];
              BlueSignal = true;
              RedSignal = false;
              RedHigh = 10000;
              
               for(cnt = (i+1); cnt < (i+20); cnt++)
                {
                  if(Buf0[cnt] != 0)
                   {
                     Buf0[cnt] = 0;
                     break;
                   }
                }
              
                if(i==1 && opp1 != Time[0] && AlertsAndMessages == true)
                 {
                   opp1 = Time[0];    
                  Alert(StringConcatenate("ALERT - Stop Buy Signal has moved ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES)));        
                  Message2 = StringConcatenate("Buy STOP has moved ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES));            
                 SendNotification(Message2);
                 SendMail("NonLagDot Signal",Message2);
            
                 }    
                 
            } 
            
         if(RedSignal == true && Close[i] > Open[i] && Low[i] > RedHigh && red_signal > 0)
           {
             Buf1[i] = High[i] + dist * Point;
             Buf0[i] = 0;
             RedHigh = Low[i];
             RedSignal = true;
             BlueSignal = false;
             BlueLow = 0;
             
            for(cnt = (i+1); cnt < (i+20); cnt++)
               {
                 if(Buf1[cnt] != 0)
                  {
                    Buf1[cnt] = 0;
                    break;
                  }
               }
             

              if(i==1 && opp2 != Time[0] && AlertsAndMessages == true)
                {
                  opp2 = Time[0];
                  Alert(StringConcatenate("ALERT - Stop Sell Signal has moved ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES)));
                  Message2 = StringConcatenate("SELL STOP has moved ",Symbol()," - ",Period(),"min at ",TimeToString(TimeCurrent(),TIME_MINUTES));            
                  SendNotification(Message2);
                  SendMail("NonLagDot Signal",Message2);
                }
               
           } 
              
          
      i--;                          
     }
     
     
   }
     
    return(0);                          
  }
  
  void CheckNewBar()
     {
        static datetime NewTime = 0;
        NewBar = false;
        if(NewTime != Time[0])
           {
              NewTime = Time[0];
              NewBar = true;
           }
      }