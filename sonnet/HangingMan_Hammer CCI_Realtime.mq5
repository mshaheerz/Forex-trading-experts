//+------------------------------------------------------------------+
//|                           HangingMan Hammer CCI Realtime.mq5     |
//|                             Copyright 2000-2026, MetaQuotes Ltd. |
//|                                                     www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "2.00"
#property description "Real-time indicator-based trading system"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

//--- Signal definitions
#define SIGNAL_BUY    1
#define SIGNAL_NOT    0
#define SIGNAL_SELL  -1

//--- Input parameters - Indicators
input group "=== Indicator Settings ==="
input int InpCCI_Period = 14;                    // CCI Period
input ENUM_APPLIED_PRICE InpCCI_Price = PRICE_TYPICAL; // CCI Applied Price
input int InpCCI_BuyLevel = -100;                // CCI Buy Level (oversold)
input int InpCCI_SellLevel = 100;                // CCI Sell Level (overbought)

input int InpRSI_Period = 14;                    // RSI Period
input ENUM_APPLIED_PRICE InpRSI_Price = PRICE_CLOSE; // RSI Applied Price
input double InpRSI_BuyLevel = 30.0;             // RSI Buy Level (oversold)
input double InpRSI_SellLevel = 70.0;            // RSI Sell Level (overbought)

input int InpMA_Fast = 12;                       // Fast MA Period
input int InpMA_Slow = 26;                       // Slow MA Period
input ENUM_MA_METHOD InpMA_Method = MODE_EMA;    // MA Method
input ENUM_APPLIED_PRICE InpMA_Price = PRICE_CLOSE; // MA Applied Price

input group "=== Signal Filter ==="
input bool InpUseCCI = true;                     // Use CCI Signal
input bool InpUseRSI = true;                     // Use RSI Signal
input bool InpUseMA = true;                      // Use MA Crossover Signal
input bool InpRequireAllSignals = false;         // Require ALL signals (true) or ANY signal (false)

input group "=== Trade Management ==="
input double InpLot = 0.1;                       // Lot Size
input uint InpSL = 100;                          // Stop Loss (points)
input uint InpTP = 200;                          // Take Profit (points)
input uint InpTrailingStop = 50;                 // Trailing Stop (points, 0=disabled)
input uint InpTrailingStep = 10;                 // Trailing Step (points)
input uint InpSlippage = 10;                     // Slippage (points)

input group "=== Position Management ==="
input bool InpCloseOpposite = true;              // Close opposite positions
input uint InpMaxPositions = 1;                  // Max positions per direction
input long InpMagicNumber = 124200;              // Magic Number

//--- Indicator handles
int ExtCCI_Handle = INVALID_HANDLE;
int ExtRSI_Handle = INVALID_HANDLE;
int ExtMA_Fast_Handle = INVALID_HANDLE;
int ExtMA_Slow_Handle = INVALID_HANDLE;

//--- Trading objects
CTrade ExtTrade;
CSymbolInfo ExtSymbolInfo;

//--- Global variables
datetime ExtLastBarTime = 0;
int ExtSignal = SIGNAL_NOT;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("=== Initializing Real-time Indicator EA ===");
   
//--- Setup symbol info
   if(!ExtSymbolInfo.Name(_Symbol))
     {
      Print("Error: Failed to initialize symbol info");
      return(INIT_FAILED);
     }

//--- Setup trade object
   ExtTrade.SetDeviationInPoints(InpSlippage);
   ExtTrade.SetExpertMagicNumber(InpMagicNumber);
   ExtTrade.LogLevel(LOG_LEVEL_ERRORS);

//--- Initialize CCI indicator
   if(InpUseCCI)
     {
      ExtCCI_Handle = iCCI(_Symbol, _Period, InpCCI_Period, InpCCI_Price);
      if(ExtCCI_Handle == INVALID_HANDLE)
        {
         Print("Error: Failed to create CCI indicator");
         return(INIT_FAILED);
        }
      Print("CCI Indicator initialized successfully");
     }

//--- Initialize RSI indicator
   if(InpUseRSI)
     {
      ExtRSI_Handle = iRSI(_Symbol, _Period, InpRSI_Period, InpRSI_Price);
      if(ExtRSI_Handle == INVALID_HANDLE)
        {
         Print("Error: Failed to create RSI indicator");
         return(INIT_FAILED);
        }
      Print("RSI Indicator initialized successfully");
     }

//--- Initialize Moving Averages
   if(InpUseMA)
     {
      ExtMA_Fast_Handle = iMA(_Symbol, _Period, InpMA_Fast, 0, InpMA_Method, InpMA_Price);
      ExtMA_Slow_Handle = iMA(_Symbol, _Period, InpMA_Slow, 0, InpMA_Method, InpMA_Price);
      
      if(ExtMA_Fast_Handle == INVALID_HANDLE || ExtMA_Slow_Handle == INVALID_HANDLE)
        {
         Print("Error: Failed to create MA indicators");
         return(INIT_FAILED);
        }
      Print("Moving Averages initialized successfully");
     }

   Print("=== EA Initialization Complete ===");
   Print("Signal mode: ", InpRequireAllSignals ? "ALL signals required" : "ANY signal sufficient");
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release indicator handles
   if(ExtCCI_Handle != INVALID_HANDLE)
      IndicatorRelease(ExtCCI_Handle);
   if(ExtRSI_Handle != INVALID_HANDLE)
      IndicatorRelease(ExtRSI_Handle);
   if(ExtMA_Fast_Handle != INVALID_HANDLE)
      IndicatorRelease(ExtMA_Fast_Handle);
   if(ExtMA_Slow_Handle != INVALID_HANDLE)
      IndicatorRelease(ExtMA_Slow_Handle);
      
   Print("=== EA Deinitialized ===");
  }

//+------------------------------------------------------------------+
//| Expert tick function - REAL-TIME EXECUTION                       |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check for new bar
   datetime current_bar_time = iTime(_Symbol, _Period, 0);
   bool is_new_bar = (current_bar_time != ExtLastBarTime);
   
   if(is_new_bar)
     {
      ExtLastBarTime = current_bar_time;
      Print("\n=== NEW BAR at ", TimeToString(current_bar_time), " ===");
     }

//--- Update symbol information
   ExtSymbolInfo.Refresh();
   ExtSymbolInfo.RefreshRates();

//--- Check for trading signals
   ExtSignal = GetTradingSignal();
   
//--- Execute trailing stop if enabled
   if(InpTrailingStop > 0)
      TrailingStop();

//--- Process signals on new bar only
   if(is_new_bar && ExtSignal != SIGNAL_NOT)
     {
      ProcessSignal(ExtSignal);
     }
  }

//+------------------------------------------------------------------+
//| Get combined trading signal from all indicators                  |
//+------------------------------------------------------------------+
int GetTradingSignal()
  {
   int buy_signals = 0;
   int sell_signals = 0;
   int active_indicators = 0;

//--- CCI Signal
   if(InpUseCCI)
     {
      active_indicators++;
      int cci_signal = GetCCISignal();
      if(cci_signal == SIGNAL_BUY)
         buy_signals++;
      else if(cci_signal == SIGNAL_SELL)
         sell_signals++;
     }

//--- RSI Signal
   if(InpUseRSI)
     {
      active_indicators++;
      int rsi_signal = GetRSISignal();
      if(rsi_signal == SIGNAL_BUY)
         buy_signals++;
      else if(rsi_signal == SIGNAL_SELL)
         sell_signals++;
     }

//--- MA Crossover Signal
   if(InpUseMA)
     {
      active_indicators++;
      int ma_signal = GetMASignal();
      if(ma_signal == SIGNAL_BUY)
         buy_signals++;
      else if(ma_signal == SIGNAL_SELL)
         sell_signals++;
     }

//--- Determine final signal based on settings
   if(InpRequireAllSignals)
     {
      // ALL signals must agree
      if(buy_signals == active_indicators)
        {
         Print(">>> BUY SIGNAL: All ", active_indicators, " indicators agree");
         return SIGNAL_BUY;
        }
      if(sell_signals == active_indicators)
        {
         Print(">>> SELL SIGNAL: All ", active_indicators, " indicators agree");
         return SIGNAL_SELL;
        }
     }
   else
     {
      // ANY signal is sufficient
      if(buy_signals > 0 && buy_signals > sell_signals)
        {
         Print(">>> BUY SIGNAL: ", buy_signals, "/", active_indicators, " indicators");
         return SIGNAL_BUY;
        }
      if(sell_signals > 0 && sell_signals > buy_signals)
        {
         Print(">>> SELL SIGNAL: ", sell_signals, "/", active_indicators, " indicators");
         return SIGNAL_SELL;
        }
     }

   return SIGNAL_NOT;
  }

//+------------------------------------------------------------------+
//| Get CCI signal                                                    |
//+------------------------------------------------------------------+
int GetCCISignal()
  {
   double cci[];
   ArraySetAsSeries(cci, true);
   
   if(CopyBuffer(ExtCCI_Handle, 0, 0, 3, cci) < 3)
     {
      Print("Error: Failed to copy CCI data");
      return SIGNAL_NOT;
     }

//--- Buy signal: CCI crosses above oversold level
   if(cci[1] < InpCCI_BuyLevel && cci[0] >= InpCCI_BuyLevel)
     {
      Print("  CCI Buy: ", cci[0], " (crossed above ", InpCCI_BuyLevel, ")");
      return SIGNAL_BUY;
     }

//--- Sell signal: CCI crosses below overbought level
   if(cci[1] > InpCCI_SellLevel && cci[0] <= InpCCI_SellLevel)
     {
      Print("  CCI Sell: ", cci[0], " (crossed below ", InpCCI_SellLevel, ")");
      return SIGNAL_SELL;
     }

   return SIGNAL_NOT;
  }

//+------------------------------------------------------------------+
//| Get RSI signal                                                    |
//+------------------------------------------------------------------+
int GetRSISignal()
  {
   double rsi[];
   ArraySetAsSeries(rsi, true);
   
   if(CopyBuffer(ExtRSI_Handle, 0, 0, 3, rsi) < 3)
     {
      Print("Error: Failed to copy RSI data");
      return SIGNAL_NOT;
     }

//--- Buy signal: RSI crosses above oversold level
   if(rsi[1] < InpRSI_BuyLevel && rsi[0] >= InpRSI_BuyLevel)
     {
      Print("  RSI Buy: ", rsi[0], " (crossed above ", InpRSI_BuyLevel, ")");
      return SIGNAL_BUY;
     }

//--- Sell signal: RSI crosses below overbought level
   if(rsi[1] > InpRSI_SellLevel && rsi[0] <= InpRSI_SellLevel)
     {
      Print("  RSI Sell: ", rsi[0], " (crossed below ", InpRSI_SellLevel, ")");
      return SIGNAL_SELL;
     }

   return SIGNAL_NOT;
  }

//+------------------------------------------------------------------+
//| Get MA crossover signal                                          |
//+------------------------------------------------------------------+
int GetMASignal()
  {
   double ma_fast[], ma_slow[];
   ArraySetAsSeries(ma_fast, true);
   ArraySetAsSeries(ma_slow, true);
   
   if(CopyBuffer(ExtMA_Fast_Handle, 0, 0, 3, ma_fast) < 3)
     {
      Print("Error: Failed to copy Fast MA data");
      return SIGNAL_NOT;
     }
   
   if(CopyBuffer(ExtMA_Slow_Handle, 0, 0, 3, ma_slow) < 3)
     {
      Print("Error: Failed to copy Slow MA data");
      return SIGNAL_NOT;
     }

//--- Buy signal: Fast MA crosses above Slow MA
   if(ma_fast[1] <= ma_slow[1] && ma_fast[0] > ma_slow[0])
     {
      Print("  MA Buy: Fast(", ma_fast[0], ") crossed above Slow(", ma_slow[0], ")");
      return SIGNAL_BUY;
     }

//--- Sell signal: Fast MA crosses below Slow MA
   if(ma_fast[1] >= ma_slow[1] && ma_fast[0] < ma_slow[0])
     {
      Print("  MA Sell: Fast(", ma_fast[0], ") crossed below Slow(", ma_slow[0], ")");
      return SIGNAL_SELL;
     }

   return SIGNAL_NOT;
  }

//+------------------------------------------------------------------+
//| Process trading signal                                           |
//+------------------------------------------------------------------+
void ProcessSignal(int signal)
  {
//--- Close opposite positions if enabled
   if(InpCloseOpposite)
     {
      if(signal == SIGNAL_BUY)
         ClosePositions(POSITION_TYPE_SELL);
      else if(signal == SIGNAL_SELL)
         ClosePositions(POSITION_TYPE_BUY);
     }

//--- Check maximum positions
   if(signal == SIGNAL_BUY && CountPositions(POSITION_TYPE_BUY) >= InpMaxPositions)
     {
      Print("Maximum BUY positions reached");
      return;
     }
   if(signal == SIGNAL_SELL && CountPositions(POSITION_TYPE_SELL) >= InpMaxPositions)
     {
      Print("Maximum SELL positions reached");
      return;
     }

//--- Open position
   if(signal == SIGNAL_BUY)
      OpenBuy();
   else if(signal == SIGNAL_SELL)
      OpenSell();
  }

//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy()
  {
   double price = ExtSymbolInfo.Ask();
   double sl = 0, tp = 0;
   
   int digits = ExtSymbolInfo.Digits();
   double point = ExtSymbolInfo.Point();

//--- Calculate Stop Loss
   if(InpSL > 0)
      sl = NormalizeDouble(price - InpSL * point, digits);

//--- Calculate Take Profit
   if(InpTP > 0)
      tp = NormalizeDouble(price + InpTP * point, digits);

//--- Open position
   if(ExtTrade.Buy(InpLot, _Symbol, price, sl, tp, "Buy Signal"))
     {
      Print(">>> BUY ORDER OPENED: Price=", price, " SL=", sl, " TP=", tp);
     }
   else
     {
      Print(">>> BUY ORDER FAILED: ", ExtTrade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell()
  {
   double price = ExtSymbolInfo.Bid();
   double sl = 0, tp = 0;
   
   int digits = ExtSymbolInfo.Digits();
   double point = ExtSymbolInfo.Point();

//--- Calculate Stop Loss
   if(InpSL > 0)
      sl = NormalizeDouble(price + InpSL * point, digits);

//--- Calculate Take Profit
   if(InpTP > 0)
      tp = NormalizeDouble(price - InpTP * point, digits);

//--- Open position
   if(ExtTrade.Sell(InpLot, _Symbol, price, sl, tp, "Sell Signal"))
     {
      Print(">>> SELL ORDER OPENED: Price=", price, " SL=", sl, " TP=", tp);
     }
   else
     {
      Print(">>> SELL ORDER FAILED: ", ExtTrade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Count positions by type                                          |
//+------------------------------------------------------------------+
int CountPositions(ENUM_POSITION_TYPE pos_type)
  {
   int count = 0;
   int total = PositionsTotal();
   
   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
            PositionGetInteger(POSITION_TYPE) == pos_type)
           {
            count++;
           }
        }
     }
   
   return count;
  }

//+------------------------------------------------------------------+
//| Close positions by type                                          |
//+------------------------------------------------------------------+
void ClosePositions(ENUM_POSITION_TYPE pos_type)
  {
   int total = PositionsTotal();
   
   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
            PositionGetInteger(POSITION_TYPE) == pos_type)
           {
            if(ExtTrade.PositionClose(ticket))
               Print("Position #", ticket, " closed");
            else
               Print("Failed to close position #", ticket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Trailing stop function                                           |
//+------------------------------------------------------------------+
void TrailingStop()
  {
   double point = ExtSymbolInfo.Point();
   int digits = ExtSymbolInfo.Digits();
   
   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
           {
            double pos_open = PositionGetDouble(POSITION_PRICE_OPEN);
            double pos_sl = PositionGetDouble(POSITION_SL);
            ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            if(pos_type == POSITION_TYPE_BUY)
              {
               double price = ExtSymbolInfo.Bid();
               double new_sl = NormalizeDouble(price - InpTrailingStop * point, digits);
               
               if(new_sl > pos_sl && (new_sl - pos_sl) >= InpTrailingStep * point)
                 {
                  if(ExtTrade.PositionModify(ticket, new_sl, PositionGetDouble(POSITION_TP)))
                     Print("Trailing stop updated for BUY #", ticket, " new SL=", new_sl);
                 }
              }
            else if(pos_type == POSITION_TYPE_SELL)
              {
               double price = ExtSymbolInfo.Ask();
               double new_sl = NormalizeDouble(price + InpTrailingStop * point, digits);
               
               if((pos_sl == 0 || new_sl < pos_sl) && (pos_sl - new_sl) >= InpTrailingStep * point)
                 {
                  if(ExtTrade.PositionModify(ticket, new_sl, PositionGetDouble(POSITION_TP)))
                     Print("Trailing stop updated for SELL #", ticket, " new SL=", new_sl);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
