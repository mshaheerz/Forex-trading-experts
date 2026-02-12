# Real-Time Indicator Trading EA - User Guide

## Overview
This EA implements **real-time buy and sell signals** using multiple technical indicators:
- **CCI (Commodity Channel Index)** - Identifies overbought/oversold conditions
- **RSI (Relative Strength Index)** - Momentum oscillator
- **MA Crossover (Moving Average)** - Trend direction

## Key Features

### ✅ Real-Time Execution
- Checks signals on **every new bar**
- Executes trades immediately when conditions are met
- No manual pattern detection required

### ✅ Flexible Signal Configuration
- Use **ANY signal** (at least 1 indicator agrees) OR
- Use **ALL signals** (all indicators must agree)
- Enable/disable individual indicators

### ✅ Advanced Position Management
- Automatic trailing stop
- Close opposite positions
- Maximum positions limit
- Configurable lot size, SL, TP

## Trading Signals Explained

### 🟢 BUY Signals Generated When:

1. **CCI Signal**: CCI crosses **above** the oversold level (default: -100)
2. **RSI Signal**: RSI crosses **above** the oversold level (default: 30)
3. **MA Signal**: Fast MA crosses **above** Slow MA (bullish crossover)

### 🔴 SELL Signals Generated When:

1. **CCI Signal**: CCI crosses **below** the overbought level (default: 100)
2. **RSI Signal**: RSI crosses **below** the overbought level (default: 70)
3. **MA Signal**: Fast MA crosses **below** Slow MA (bearish crossover)

## Input Parameters Guide

### Indicator Settings

```
CCI Period = 14              // Lookback period for CCI calculation
CCI Applied Price = TYPICAL  // Price type (Typical = (High+Low+Close)/3)
CCI Buy Level = -100         // Oversold threshold for buy signals
CCI Sell Level = 100         // Overbought threshold for sell signals

RSI Period = 14              // Lookback period for RSI calculation
RSI Applied Price = CLOSE    // Price type for RSI
RSI Buy Level = 30           // Oversold threshold (standard)
RSI Sell Level = 70          // Overbought threshold (standard)

Fast MA Period = 12          // Shorter moving average
Slow MA Period = 26          // Longer moving average
MA Method = EMA              // Type: SMA, EMA, SMMA, LWMA
MA Applied Price = CLOSE     // Price for MA calculation
```

### Signal Filter Settings

```
Use CCI Signal = true                  // Enable CCI indicator
Use RSI Signal = true                  // Enable RSI indicator
Use MA Crossover Signal = true         // Enable MA crossover
Require ALL Signals = false            // Signal combination mode
```

**Important Signal Modes:**
- `Require ALL Signals = false` → Trade when **ANY** indicator gives signal (more trades)
- `Require ALL Signals = true` → Trade only when **ALL** indicators agree (fewer, higher quality trades)

### Trade Management

```
Lot Size = 0.1               // Position size
Stop Loss = 100 points       // Distance from entry price
Take Profit = 200 points     // Profit target distance
Trailing Stop = 50 points    // Distance for trailing stop (0=disabled)
Trailing Step = 10 points    // Minimum price movement to adjust SL
Slippage = 10 points         // Maximum acceptable price slippage
```

### Position Management

```
Close Opposite Positions = true    // Auto-close opposite direction trades
Max Positions = 1                  // Maximum positions per direction
Magic Number = 124200              // Unique EA identifier
```

## Recommended Settings

### Conservative (High Probability, Fewer Trades)
```
Require ALL Signals = true
CCI Buy Level = -150
CCI Sell Level = 150
RSI Buy Level = 25
RSI Sell Level = 75
Stop Loss = 150
Take Profit = 300
```

### Aggressive (More Trades, Higher Risk)
```
Require ALL Signals = false
CCI Buy Level = -80
CCI Sell Level = 80
RSI Buy Level = 35
RSI Sell Level = 65
Stop Loss = 80
Take Profit = 160
```

### Trend Following (MA Focus)
```
Use CCI Signal = false
Use RSI Signal = false
Use MA Crossover Signal = true
Fast MA Period = 8
Slow MA Period = 21
Stop Loss = 100
Take Profit = 300
Trailing Stop = 60
```

### Mean Reversion (Oscillator Focus)
```
Use CCI Signal = true
Use RSI Signal = true
Use MA Crossover Signal = false
Require ALL Signals = true
CCI Buy Level = -200
CCI Sell Level = 200
Stop Loss = 120
Take Profit = 180
```

## How It Works

### Step-by-Step Process:

1. **On Every Tick**: EA monitors all enabled indicators in real-time

2. **On New Bar**: 
   - Checks each indicator for buy/sell conditions
   - Counts how many indicators agree
   - Determines if signal meets requirements

3. **Signal Generation**:
   - If requirements met → Generate BUY or SELL signal
   - Print signal details to Experts log

4. **Trade Execution**:
   - Check if max positions reached
   - Close opposite positions (if enabled)
   - Calculate SL and TP levels
   - Open market order

5. **Position Management**:
   - Apply trailing stop if enabled
   - Monitor positions until closed

## Terminal Output Example

```
=== NEW BAR at 2026.02.12 10:00 ===
  CCI Buy: -98.45 (crossed above -100)
  RSI Buy: 31.23 (crossed above 30)
  MA Buy: Fast(1.0845) crossed above Slow(1.0842)
>>> BUY SIGNAL: 3/3 indicators agree
>>> BUY ORDER OPENED: Price=1.0847 SL=1.0837 TP=1.0867
```

## Tips for Best Results

### 1. Backtesting
Always backtest with historical data before live trading:
- Use Strategy Tester in MetaTrader 5
- Test with at least 1 year of data
- Optimize parameters for your symbol and timeframe

### 2. Timeframe Selection
- **M15-H1**: Good for day trading (fast signals)
- **H4**: Balanced approach (medium-term trades)
- **D1**: Swing trading (fewer, stronger signals)

### 3. Symbol Considerations
- Works best on major forex pairs (EUR/USD, GBP/USD, etc.)
- Requires decent volatility for signal generation
- Avoid during major news events (high slippage risk)

### 4. Risk Management
- Never risk more than 1-2% per trade
- Use appropriate lot sizes for your account
- Consider max drawdown in backtest results
- Set realistic profit expectations

### 5. Parameter Optimization
- Don't over-optimize (curve fitting)
- Test on out-of-sample data
- Keep settings simple and logical
- Monitor performance regularly

## Troubleshooting

### No Signals Generated
- Check that at least one indicator is enabled
- Verify indicator periods are appropriate for timeframe
- Ensure buy/sell levels allow for crossovers
- Check Experts log for initialization errors

### Orders Not Opening
- Verify account has sufficient margin
- Check if max positions limit is reached
- Ensure trading is allowed (AutoTrading button)
- Review broker requirements (minimum lot, etc.)

### Trailing Stop Not Working
- Set Trailing Stop > 0
- Ensure position is in profit
- Check Trailing Step is smaller than Trailing Stop
- Position must move at least Trailing Step to update

## Important Notes

⚠️ **Risk Warning**: Trading forex and CFDs involves substantial risk. This EA is provided for educational purposes. Always test thoroughly before live trading.

📊 **Monitor Performance**: Regularly review trading results and adjust parameters as needed based on market conditions.

🔧 **Updates**: Keep the EA updated and monitor for any broker-specific requirements or changes.

## Support

For questions or issues:
1. Check the Experts log in MetaTrader 5
2. Review this documentation
3. Test in Strategy Tester first
4. Contact developer with specific error messages

---

**Version**: 2.00  
**Last Updated**: February 2026  
**Compatible with**: MetaTrader 5
