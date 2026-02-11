//+------------------------------------------------------------------+
//|                                        MultiStrategy_EA.mq5      |
//|                                   Advanced Trading System        |
//|                                   With Visual Indicators         |
//+------------------------------------------------------------------+
#property copyright "Advanced Trading System"
#property link      ""
#property version   "1.00"
#property strict

//--- Input Parameters
input double RiskPercent = 2.0;              // Risk per trade (%)
input double MaxDailyLoss = 15.0;            // Max daily loss ($)
input double TakeProfitPips = 50;            // Take Profit (pips)
input double StopLossPips = 25;              // Stop Loss (pips)
input int MagicNumber = 123456;              // Magic Number
input bool UseStrategy1_MA_Cross = true;     // Use MA Crossover Strategy
input bool UseStrategy2_RSI_BB = true;       // Use RSI + Bollinger Bands
input bool UseStrategy3_MACD_Trend = true;   // Use MACD Trend Strategy
input int FastMA_Period = 10;                // Fast MA Period
input int SlowMA_Period = 30;                // Slow MA Period
input int RSI_Period = 14;                   // RSI Period
input int RSI_Oversold = 30;                 // RSI Oversold Level
input int RSI_Overbought = 70;               // RSI Overbought Level
input int BB_Period = 20;                    // Bollinger Bands Period
input double BB_Deviation = 2.0;             // BB Deviation
input int MACD_Fast = 12;                    // MACD Fast EMA
input int MACD_Slow = 26;                    // MACD Slow EMA
input int MACD_Signal = 9;                   // MACD Signal
input color BuyArrowColor = clrLime;         // Buy Signal Color
input color SellArrowColor = clrRed;         // Sell Signal Color
input color InfoTextColor = clrWhite;        // Info Text Color

//--- Global Variables
double dailyProfit = 0.0;
datetime lastResetTime = 0;
int totalTrades = 0;
int winningTrades = 0;
string lastSignal = "";

//--- Indicator Handles
int handleFastMA, handleSlowMA, handleRSI, handleBB, handleMACD;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize indicators
   handleFastMA = iMA(_Symbol, PERIOD_CURRENT, FastMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   handleSlowMA = iMA(_Symbol, PERIOD_CURRENT, SlowMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   handleRSI = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
   handleBB = iBands(_Symbol, PERIOD_CURRENT, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
   handleMACD = iMACD(_Symbol, PERIOD_CURRENT, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   
   //--- Check if indicators initialized successfully
   if(handleFastMA == INVALID_HANDLE || handleSlowMA == INVALID_HANDLE || 
      handleRSI == INVALID_HANDLE || handleBB == INVALID_HANDLE || handleMACD == INVALID_HANDLE)
   {
      Print("Error initializing indicators!");
      return(INIT_FAILED);
   }
   
   Print("Multi-Strategy EA Initialized Successfully!");
   Print("Strategies Active: ", 
         (UseStrategy1_MA_Cross ? "MA Cross | " : ""),
         (UseStrategy2_RSI_BB ? "RSI+BB | " : ""),
         (UseStrategy3_MACD_Trend ? "MACD Trend" : ""));
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   IndicatorRelease(handleFastMA);
   IndicatorRelease(handleSlowMA);
   IndicatorRelease(handleRSI);
   IndicatorRelease(handleBB);
   IndicatorRelease(handleMACD);
   
   //--- Remove all objects
   ObjectsDeleteAll(0, "Strategy_");
   
   Print("EA Deinitialized. Total Trades: ", totalTrades, 
         " | Win Rate: ", (totalTrades > 0 ? (winningTrades * 100.0 / totalTrades) : 0), "%");
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Reset daily profit at start of new day
   if(TimeCurrent() >= lastResetTime + 86400) // 24 hours
   {
      dailyProfit = CalculateDailyProfit();
      lastResetTime = TimeCurrent();
   }
   
   //--- Check daily loss limit
   if(dailyProfit <= -MaxDailyLoss)
   {
      DrawInfoPanel("DAILY LOSS LIMIT REACHED: $" + DoubleToString(MathAbs(dailyProfit), 2) + " | TRADING STOPPED");
      return;
   }
   
   //--- Check if we have open positions
   bool hasPosition = PositionSelect(_Symbol);
   
   //--- Update daily profit
   dailyProfit = CalculateDailyProfit();
   
   //--- Draw information panel
   DrawInfoPanel("");
   
   //--- Only check for new signals if no position is open
   if(!hasPosition)
   {
      CheckForSignals();
   }
   else
   {
      //--- Manage open positions
      ManageOpenPositions();
   }
}

//+------------------------------------------------------------------+
//| Check for trading signals from all strategies                      |
//+------------------------------------------------------------------+
void CheckForSignals()
{
   int buySignals = 0;
   int sellSignals = 0;
   string signalDetails = "";
   
   //--- Strategy 1: Moving Average Crossover
   if(UseStrategy1_MA_Cross)
   {
      int signal = Strategy_MA_Crossover();
      if(signal == 1)
      {
         buySignals++;
         signalDetails += "MA Cross BUY | ";
      }
      else if(signal == -1)
      {
         sellSignals++;
         signalDetails += "MA Cross SELL | ";
      }
   }
   
   //--- Strategy 2: RSI + Bollinger Bands
   if(UseStrategy2_RSI_BB)
   {
      int signal = Strategy_RSI_BB();
      if(signal == 1)
      {
         buySignals++;
         signalDetails += "RSI+BB BUY | ";
      }
      else if(signal == -1)
      {
         sellSignals++;
         signalDetails += "RSI+BB SELL | ";
      }
   }
   
   //--- Strategy 3: MACD Trend Following
   if(UseStrategy3_MACD_Trend)
   {
      int signal = Strategy_MACD_Trend();
      if(signal == 1)
      {
         buySignals++;
         signalDetails += "MACD BUY | ";
      }
      else if(signal == -1)
      {
         sellSignals++;
         signalDetails += "MACD SELL | ";
      }
   }
   
   //--- Execute trade if at least 2 strategies agree
   if(buySignals >= 2)
   {
      lastSignal = "BUY: " + signalDetails;
      OpenTrade(ORDER_TYPE_BUY);
      DrawArrow("BUY", iTime(_Symbol, PERIOD_CURRENT, 0), iClose(_Symbol, PERIOD_CURRENT, 0));
   }
   else if(sellSignals >= 2)
   {
      lastSignal = "SELL: " + signalDetails;
      OpenTrade(ORDER_TYPE_SELL);
      DrawArrow("SELL", iTime(_Symbol, PERIOD_CURRENT, 0), iClose(_Symbol, PERIOD_CURRENT, 0));
   }
}

//+------------------------------------------------------------------+
//| Strategy 1: Moving Average Crossover                               |
//+------------------------------------------------------------------+
int Strategy_MA_Crossover()
{
   double fastMA[], slowMA[];
   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   
   if(CopyBuffer(handleFastMA, 0, 0, 3, fastMA) < 3) return 0;
   if(CopyBuffer(handleSlowMA, 0, 0, 3, slowMA) < 3) return 0;
   
   //--- Bullish crossover
   if(fastMA[1] > slowMA[1] && fastMA[2] <= slowMA[2])
      return 1;
   
   //--- Bearish crossover
   if(fastMA[1] < slowMA[1] && fastMA[2] >= slowMA[2])
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Strategy 2: RSI + Bollinger Bands                                 |
//+------------------------------------------------------------------+
int Strategy_RSI_BB()
{
   double rsi[], bbUpper[], bbLower[], close[];
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(bbUpper, true);
   ArraySetAsSeries(bbLower, true);
   ArraySetAsSeries(close, true);
   
   if(CopyBuffer(handleRSI, 0, 0, 2, rsi) < 2) return 0;
   if(CopyBuffer(handleBB, 1, 0, 2, bbUpper) < 2) return 0;
   if(CopyBuffer(handleBB, 2, 0, 2, bbLower) < 2) return 0;
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 2, close) < 2) return 0;
   
   //--- Buy: Price near lower BB and RSI oversold
   if(close[0] <= bbLower[0] && rsi[0] < RSI_Oversold)
      return 1;
   
   //--- Sell: Price near upper BB and RSI overbought
   if(close[0] >= bbUpper[0] && rsi[0] > RSI_Overbought)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Strategy 3: MACD Trend Following                                   |
//+------------------------------------------------------------------+
int Strategy_MACD_Trend()
{
   double macdMain[], macdSignal[];
   ArraySetAsSeries(macdMain, true);
   ArraySetAsSeries(macdSignal, true);
   
   if(CopyBuffer(handleMACD, 0, 0, 3, macdMain) < 3) return 0;
   if(CopyBuffer(handleMACD, 1, 0, 3, macdSignal) < 3) return 0;
   
   //--- Bullish: MACD crosses above signal line and both are negative
   if(macdMain[1] > macdSignal[1] && macdMain[2] <= macdSignal[2] && macdMain[1] < 0)
      return 1;
   
   //--- Bearish: MACD crosses below signal line and both are positive
   if(macdMain[1] < macdSignal[1] && macdMain[2] >= macdSignal[2] && macdMain[1] > 0)
      return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Open a trade with proper risk management                          |
//+------------------------------------------------------------------+
void OpenTrade(ENUM_ORDER_TYPE orderType)
{
   double price = (orderType == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   //--- Calculate SL and TP
   double sl, tp;
   if(orderType == ORDER_TYPE_BUY)
   {
      sl = NormalizeDouble(price - StopLossPips * 10 * point, digits);
      tp = NormalizeDouble(price + TakeProfitPips * 10 * point, digits);
   }
   else
   {
      sl = NormalizeDouble(price + StopLossPips * 10 * point, digits);
      tp = NormalizeDouble(price - TakeProfitPips * 10 * point, digits);
   }
   
   //--- Calculate lot size based on risk
   double lotSize = CalculateLotSize(StopLossPips);
   
   //--- Prepare trade request
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.type = orderType;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = MagicNumber;
   request.comment = "Multi-Strategy EA";
   
   //--- Send order
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Trade opened successfully! Type: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"),
               " | Lot: ", lotSize, " | SL: ", sl, " | TP: ", tp);
         totalTrades++;
      }
      else
      {
         Print("Order failed! Error: ", result.retcode);
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk percentage                        |
//+------------------------------------------------------------------+
double CalculateLotSize(double slPips)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * RiskPercent / 100.0;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   double lotSize = riskAmount / (slPips * 10 * point * tickValue / point);
   
   //--- Check lot size limits
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Manage open positions                                              |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   if(PositionSelect(_Symbol))
   {
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                           SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double profit = PositionGetDouble(POSITION_PROFIT);
      
      //--- Update trailing stop or other management logic here if needed
   }
}

//+------------------------------------------------------------------+
//| Calculate daily profit                                             |
//+------------------------------------------------------------------+
double CalculateDailyProfit()
{
   double profit = 0.0;
   datetime startOfDay = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   
   HistorySelect(startOfDay, TimeCurrent());
   
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
      {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol &&
            HistoryDealGetInteger(ticket, DEAL_MAGIC) == MagicNumber)
         {
            profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
            
            //--- Track win rate
            if(HistoryDealGetDouble(ticket, DEAL_PROFIT) > 0)
               winningTrades++;
         }
      }
   }
   
   //--- Add current open position profit
   if(PositionSelect(_Symbol))
   {
      profit += PositionGetDouble(POSITION_PROFIT);
   }
   
   return profit;
}

//+------------------------------------------------------------------+
//| Draw visual arrow for signals                                      |
//+------------------------------------------------------------------+
void DrawArrow(string type, datetime time, double price)
{
   string objName = "Strategy_Arrow_" + TimeToString(time);
   
   ObjectCreate(0, objName, OBJ_ARROW, 0, time, price);
   
   if(type == "BUY")
   {
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, 233); // Up arrow
      ObjectSetInteger(0, objName, OBJPROP_COLOR, BuyArrowColor);
      ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_TOP);
   }
   else
   {
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, 234); // Down arrow
      ObjectSetInteger(0, objName, OBJPROP_COLOR, SellArrowColor);
      ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
   }
   
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, 3);
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Draw information panel on chart                                    |
//+------------------------------------------------------------------+
void DrawInfoPanel(string extraInfo)
{
   int x = 10, y = 20;
   int lineHeight = 18;
   
   //--- Delete old labels
   ObjectsDeleteAll(0, "Strategy_Label_");
   
   //--- Title
   CreateLabel("Strategy_Label_Title", x, y, "=== MULTI-STRATEGY EA ===", InfoTextColor, 10, "Arial Bold");
   y += lineHeight + 5;
   
   //--- Account info
   CreateLabel("Strategy_Label_Balance", x, y, "Balance: $" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2), clrYellow, 9);
   y += lineHeight;
   
   CreateLabel("Strategy_Label_Equity", x, y, "Equity: $" + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2), clrYellow, 9);
   y += lineHeight;
   
   //--- Daily profit with color coding
   color profitColor = (dailyProfit >= 0) ? clrLime : clrRed;
   CreateLabel("Strategy_Label_DailyProfit", x, y, "Daily P/L: $" + DoubleToString(dailyProfit, 2), profitColor, 9);
   y += lineHeight;
   
   //--- Loss limit warning
   double lossRemaining = MaxDailyLoss + dailyProfit;
   color warningColor = (lossRemaining < 5) ? clrRed : clrOrange;
   CreateLabel("Strategy_Label_LossLimit", x, y, "Loss Limit: $" + DoubleToString(lossRemaining, 2) + " remaining", warningColor, 9);
   y += lineHeight + 5;
   
   //--- Statistics
   double winRate = (totalTrades > 0) ? (winningTrades * 100.0 / totalTrades) : 0;
   CreateLabel("Strategy_Label_Trades", x, y, "Total Trades: " + IntegerToString(totalTrades), clrWhite, 8);
   y += lineHeight;
   
   CreateLabel("Strategy_Label_WinRate", x, y, "Win Rate: " + DoubleToString(winRate, 1) + "%", clrWhite, 8);
   y += lineHeight + 5;
   
   //--- Last signal
   if(lastSignal != "")
   {
      CreateLabel("Strategy_Label_LastSignal", x, y, "Last: " + lastSignal, clrAqua, 8);
      y += lineHeight;
   }
   
   //--- Expected profit
   if(PositionSelect(_Symbol))
   {
      double expectedTP = PositionGetDouble(POSITION_TP);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double lotSize = PositionGetDouble(POSITION_VOLUME);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      double expectedProfit = MathAbs(expectedTP - openPrice) / point * tickValue * lotSize;
      
      CreateLabel("Strategy_Label_Expected", x, y, "Expected Profit: $" + DoubleToString(expectedProfit, 2), clrLightGreen, 9);
      y += lineHeight;
      
      double currentProfit = PositionGetDouble(POSITION_PROFIT);
      color currentColor = (currentProfit >= 0) ? clrLime : clrRed;
      CreateLabel("Strategy_Label_Current", x, y, "Current P/L: $" + DoubleToString(currentProfit, 2), currentColor, 9);
   }
   
   //--- Extra info (warnings, etc.)
   if(extraInfo != "")
   {
      y += lineHeight + 5;
      CreateLabel("Strategy_Label_Warning", x, y, extraInfo, clrRed, 10, "Arial Bold");
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create label on chart                                              |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int fontSize = 8, string font = "Arial")
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
}
//+------------------------------------------------------------------+
