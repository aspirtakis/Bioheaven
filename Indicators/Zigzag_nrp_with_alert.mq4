//+------------------------------------------------------------------+
//|                                                     (ZigZag).mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Orange 
//---- input parameters
extern int       barn            = 300;
extern int       Length          = 15;
extern bool      Alert_message   = true;

//---- buffers
double ExtMapBuffer1[];
int alert_flag = 0;
//double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexEmptyValue(0,0.0);
  //SetIndexDrawBegin(0, barn);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

   int counted_bars = IndicatorCounted();
   int shift, Swing = 0, Swing_n = 0, uzl = 0, i, zu = barn, zd = barn, mv;
   double LL, HH, BH = High[barn], BL = Low[barn], last_value_1 = 0, last_value_2 = 0; 
   double Uzel[10000][2]; 

   
   // loop from first bar to current bar ( with shift = 0 )  

   for ( shift = barn; shift >= 0; shift--) { 
   
      LL = 10000000;HH = -100000000; 
      
      for ( i = shift + Length;i >= shift + 1; i-- ) { 
      
         if ( Low[i] < LL ) LL=Low[i];
         if ( High[i] > HH ) HH=High[i];
      } 


      if ( Low[shift] < LL && High[shift] > HH ) { 
      
         Swing = 2; 
         if ( Swing_n == 1 ) zu=shift + 1;
         if ( Swing_n == -1 ) zd=shift + 1;
      } 
      else { 
      
         if ( Low[shift] < LL ) Swing = -1;
         if ( High[shift] > HH ) Swing = 1; 
      } 

      if ( Swing != Swing_n && Swing_n !=0 ) { 
      
         if ( Swing == 2 ) {
         
            Swing = -Swing_n;
            BH = High[shift];
            BL = Low[shift]; 
         } 
         
         uzl++; 
         
         if ( Swing == 1 ) {
         
            Uzel[uzl][0] = zd;
            Uzel[uzl][1] = BL;

         } 
         
         if ( Swing == -1 ) {
         
            Uzel[uzl][0] = zu;
            Uzel[uzl][1] = BH; 

         } 
         
         BH = High[shift];
         BL = Low[shift]; 
      } 

      if ( Swing == 1 ) { 
      
         if ( High[shift] >= BH ) {
            
            BH = High[shift];
            zu = shift;
         }
      } 
      
      if ( Swing == -1 ) {
      
         if ( Low[shift] <= BL ) {
            
            BL = Low[shift]; 
            zd = shift;
         }
      } 
      
      Swing_n = Swing; 
   } 
   
   for ( i = 1; i <= uzl; i++ ) { 

      mv = StrToInteger( DoubleToStr( Uzel[i][0], 0 ) );
      ExtMapBuffer1[mv] = Uzel[i][1];

   } 
   
   i = 0;
   
   while ( ExtMapBuffer1[i] == 0 ) i++;
   
   last_value_1 = ExtMapBuffer1[i];
   int ct=i;
   i++;
   
   while ( ExtMapBuffer1[i] == 0 ) i++;
   
   last_value_2 = ExtMapBuffer1[i];
   
   if ( ( last_value_1 < last_value_2 ) && ( alert_flag != 1 ) ) {
      
      AlertZigZag( 1,last_value_1,ct);
      alert_flag = 1;
   }
   if ( ( last_value_1 > last_value_2 ) && ( alert_flag != -1 ) ) {
      
      AlertZigZag( 0,last_value_1,ct);
      alert_flag = -1;
   }
   Comment("Entry # candles back: ",ct,"\n",
           "ZZ value: ",last_value_1,"\n",
           "Entry price: ",NormalizeDouble(Bid,Digits),"\n",
           "Trend: ",alert_flag);
   return(0);
}
//+------------------------------------------------------------------+

void AlertZigZag( int direction, double price, int Ct) {
   
   if ( Alert_message == true ) {
      
      if ( direction == 0 ) {
         
         Alert("ZigZag down ",Ct," candles ago on ", Symbol(), "[", Period(), "m] at ", NormalizeDouble(price,Digits),", Entry price: ",NormalizeDouble(Bid,Digits));
      }
      
      if ( direction == 1 ) {
         
         Alert("ZigZag up ",Ct," candles ago on ", Symbol(), "[", Period(), "m] at ", NormalizeDouble(price,Digits),", Entry price: ",NormalizeDouble(Ask,Digits));
      }
   }
}