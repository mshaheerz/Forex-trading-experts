# Moving Averages EA - Buy/Sell Direction Control
## Installation and Usage Guide

### WHAT'S NEW
This modified EA allows you to choose whether to trade only BUY signals or only SELL signals.

### INSTALLATION INSTRUCTIONS

1. **Download the file:**
   - File name: `Moving_Averages_BuySell.mq5`

2. **Install in MetaTrader 5:**
   - Open MT5
   - Go to: File → Open Data Folder
   - Navigate to: MQL5 → Experts
   - Copy `Moving_Averages_BuySell.mq5` into this folder
   - Return to MT5 and click "Refresh" in Navigator panel (or press F4)

3. **Compile the EA:**
   - In MT5, open MetaEditor (press F4 or Tools → MetaQuotes Language Editor)
   - Open the file: Moving_Averages_BuySell.mq5
   - Press F7 or click "Compile"
   - Check for errors in the Toolbox window

### HOW TO USE

1. **Attach EA to chart:**
   - Drag the EA from Navigator → Expert Advisors onto your chart
   - A settings window will appear

2. **Configure Settings:**

   **Trade Direction (NEW!):**
   - `ORDER_TYPE_BUY` = Trade only BUY signals (price crosses UP through MA)
   - `ORDER_TYPE_SELL` = Trade only SELL signals (price crosses DOWN through MA)

   **Other Settings:**
   - Maximum Risk: 0.02 (2% of free margin per trade)
   - Decrease Factor: 3 (reduces lot size after consecutive losses)
   - Moving Period: 12 (MA period in bars)
   - Moving Shift: 6 (MA shift/offset)

3. **Enable Auto Trading:**
   - Click "Auto Trading" button in MT5 toolbar (should turn green)
   - Make sure "Allow Algo Trading" is checked in EA settings

### HOW IT WORKS

**BUY Signal (if Trade Direction = BUY):**
- Opens BUY when price crosses UP through the Moving Average
- Closes BUY when price crosses DOWN through the Moving Average

**SELL Signal (if Trade Direction = SELL):**
- Opens SELL when price crosses DOWN through the Moving Average
- Closes SELL when price crosses UP through the Moving Average

**Entry Conditions:**
- Signal must occur on a new bar (first tick)
- Must have at least 100 bars of history
- Auto trading must be enabled
- Only trades in the selected direction

**Exit Conditions:**
- Position closes when price crosses back through the MA in opposite direction

### IMPORTANT NOTES

⚠️ **Risk Warning:**
- This EA trades with real money when used on a live account
- Test thoroughly on a demo account first
- The EA uses percentage-based position sizing (default 2% of free margin)
- Consecutive losses will reduce position size automatically

✅ **Best Practices:**
- Start with demo account
- Use conservative risk settings (1-2%)
- Monitor the EA regularly
- Test on different timeframes to find what works best
- Keep an eye on the Experts log for trade confirmations

### TROUBLESHOOTING

**EA not opening trades:**
- Check that Auto Trading is enabled (green button)
- Verify "Allow Algo Trading" is checked in EA properties
- Ensure you have sufficient free margin
- Check the Experts tab for error messages

**Wrong direction trades:**
- Double-check the "Trade Direction" parameter
- ORDER_TYPE_BUY = BUY only
- ORDER_TYPE_SELL = SELL only

**EA not compiling:**
- Make sure you have the Trade.mqh library (included in standard MT5)
- Check for any error messages in MetaEditor

### PARAMETERS EXPLAINED

| Parameter | Default | Description |
|-----------|---------|-------------|
| Maximum Risk | 0.02 | 2% of free margin risked per trade |
| Decrease Factor | 3 | Reduces lot after losses (higher = more reduction) |
| Moving Period | 12 | Number of bars for MA calculation |
| Moving Shift | 6 | Shifts MA forward/backward on chart |
| **Trade Direction** | **ORDER_TYPE_BUY** | **BUY or SELL only** |

### BACKTEST INSTRUCTIONS

1. Open Strategy Tester (Ctrl+R)
2. Select: Moving_Averages_BuySell
3. Choose symbol and timeframe
4. Set date range
5. In Inputs tab, select your Trade Direction
6. Click Start

### SUPPORT

For issues or questions:
- Check MT5 Experts log for error messages
- Review this guide carefully
- Test on demo first

---
**Version:** 1.01
**Magic Number:** 1234501
**Created:** 2026
