//+------------------------------------------------------------------+
//|                                                  LadinoTrade.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"
#property version   "1.00"

#include <Utils.mqh>

enum ATIVO_TIPO {
   ATIVO_INDICE,  // Indice
   ATIVO_ACAO     // Stock
};

struct TRADE_POSICAO {
   double precoEntrada;
   double corretagem;
   double volumeInicial;
   double volumeAtual;
};

struct TRADE_FECHADO {
   datetime data;
   int sucesso;
   int falha;
   double corretagem;
   double financeiro;
};

class LadinoTrade {
   private:
      SINAL_POSICAO _posicaoAtual;      
      double _precoEntrada;
      double _breakEvenPosicao;
      double _objetivoPosicao1;
      double _objetivoPosicao2;
      double _objetivoPosicao3;
   
      double _breakEvenVolume;
      double _objetivoVolume1;
      double _objetivoVolume2;
      double _objetivoVolume3;

      TRADE_POSICAO _posicoes[];   
      TRADE_FECHADO _trades[];
      //int candleCount;
      //CTrade trade;
      MqlTradeRequest _req;
      MqlTradeRequest _stop;
      MqlTradeResult _res;
      MqlTradeCheckResult _check;
      //int volume;
      double _resultado_dia;
      int _sucesso;
      int _falha;
      double _ganhoMaximo;
      double _perdaMaxima;
      double _financeiro; 
      double _financeiroAtual; 
      double _corretagem; 
      double _valorCorretagem;
      double _valorPonto;
      double _stopLoss;
      ATIVO_TIPO _tipoAtivo;
      
      double maxLote(double lot, double sl);
      void novoPosicionamento(double preco, double lot);
      void fecharPosicionamento(double preco, double lot);
      double precoPosicaoEmAberto();
   public:
      LadinoTrade();
      
      SINAL_POSICAO getPosicaoAtual();
      double getPrecoEntrada();
      double ultimoPrecoEntrada();
      
      double getBreakEvenPosicao();
      void setBreakEvenPosicao(double valor);
      double getObjetivoPosicao1();
      void setObjetivoPosicao1(double valor);
      double getObjetivoPosicao2();
      void setObjetivoPosicao2(double valor);
      double getObjetivoPosicao3();
      void setObjetivoPosicao3(double valor);
      
      double getVolume();
      double getBreakEvenVolume();
      void setBreakEvenVolume(double valor);
      double getObjetivoVolume1();
      void setObjetivoVolume1(double valor);
      double getObjetivoVolume2();
      void setObjetivoVolume2(double valor);
      double getObjetivoVolume3();
      void setObjetivoVolume3(double valor);
      
      double getValorCorretagem();
      void setValorCorretagem(double value);
      double getGanhoMaximo();
      void setGanhoMaximo(double value);
      double getPerdaMaxima();
      void setPerdaMaxima(double value);
      
      double getValorPonto();
      void setValorPonto(double valorPonto);
      ATIVO_TIPO getTipoAtivo();
      void setTipoAtivo(ATIVO_TIPO tipo);
      
      double getTotal();
      double getFinanceiroTotal();
      double getCorretagemTotal();
      int getSucessoTotal();
      int getFalhaTotal();

      double validarFinanceiro(double lot, double sl);

      bool comprarTP(double lot, double price);
      bool venderTP(double lot, double price);
      
      bool agendarCompra(double lot, double price, double sl = 0, double tp = 0);
      bool agendarVenda(double lot, double price, double sl = 0, double tp = 0);
      bool comprarMercado(double lot, double sl=0.0, double tp=0.0);
      bool venderMercado(double lot, double sl=0.0, double tp=0.0);
      bool comprarForcado(double lot, double sl=0.0, double tp=0.0, int tentativa = 20);
      bool venderForcado(double lot, double sl=0.0, double tp=0.0, int tentativa = 20);
      bool comprar(double lot, double price, double sl=0.0, double tp=0.0);
      bool vender(double lot, double price, double sl=0.0, double tp=0.0);
      bool finalizarPosicao();
      bool realizarPosicao(double lot);
      void abrirPosicao(double preco, double volume);
      void parcialPosicao(double preco, double volume);
      void fecharPosicao(double preco, double volume);
      void aoNegociar(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result);
      bool cancelarOrdem(const ulong ticket);
      void cancelarOrdemPendente();
      bool modificarPosicao(double sl, double tp = 0);
      bool alterarOrdem(const string ticket, const double sl, const double tp);
      int ordemTipo();
      void fecharDia();
      
      double getStopLoss();
      double posicaoPontoEmAberto(double preco);
      double precoOperacaoAtual();
      double precoAtual();
      
      virtual void escreverLog(string msg);
      virtual void aoAbrirPosicao();
      virtual void aoFecharPosicao(double saldo);
      virtual void aoAtingirGanhoMax();
      virtual void aoAtingirPerdaMax();
};

LadinoTrade::LadinoTrade() {
   _posicaoAtual = NENHUMA;
   _precoEntrada = 0;
   _financeiro = 0; 
   _corretagem = 0; 
   _valorCorretagem = 1;
   _valorPonto = 0.2;
   _tipoAtivo = ATIVO_INDICE;
}

SINAL_POSICAO LadinoTrade::getPosicaoAtual() {
   return _posicaoAtual;
}

double LadinoTrade::getPrecoEntrada() {
   return _precoEntrada;
}

double LadinoTrade::ultimoPrecoEntrada() {
   if (ArraySize(_posicoes) > 0)
      return _posicoes[ArraySize(_posicoes) - 1].precoEntrada;
   return 0;
}

double LadinoTrade::getBreakEvenPosicao() {
   return _breakEvenPosicao;
}

void LadinoTrade::setBreakEvenPosicao(double valor) {
   _breakEvenPosicao = valor;
}

double LadinoTrade::getObjetivoPosicao1() {
   return _objetivoPosicao1;
}

void LadinoTrade::setObjetivoPosicao1(double valor) {
   _objetivoPosicao1 = valor;
}

double LadinoTrade::getObjetivoPosicao2() {
   return _objetivoPosicao2;
}

void LadinoTrade::setObjetivoPosicao2(double valor) {
   _objetivoPosicao2 = valor;
}

double LadinoTrade::getObjetivoPosicao3() {
   return _objetivoPosicao3;
}

void LadinoTrade::setObjetivoPosicao3(double valor) {
   _objetivoPosicao3 = valor;
}

double LadinoTrade::getVolume() {
   double volume = 0;
   for (int i = 0; i < ArraySize(_posicoes); i++) {
      volume += _posicoes[i].volumeAtual;
   }
   return volume;
}

double LadinoTrade::getBreakEvenVolume() {
   return _breakEvenVolume;
}

void LadinoTrade::setBreakEvenVolume(double valor) {
   _breakEvenVolume = valor;
}

double LadinoTrade::getObjetivoVolume1(){
   return _objetivoVolume1;
}

void LadinoTrade::setObjetivoVolume1(double valor) {
   _objetivoVolume1 = valor;
}

double LadinoTrade::getObjetivoVolume2() {
   return _objetivoVolume2;
}

void LadinoTrade::setObjetivoVolume2(double valor) {
   _objetivoVolume2 = valor;
}

double LadinoTrade::getObjetivoVolume3() {
   return _objetivoVolume3;
}

void LadinoTrade::setObjetivoVolume3(double valor) {
   _objetivoVolume3 = valor;
}

double LadinoTrade::getValorCorretagem() {
   return _valorCorretagem;
}

void LadinoTrade::setValorCorretagem(double value) {
   _valorCorretagem = value;
}

double LadinoTrade::getGanhoMaximo(){
   return _ganhoMaximo;
}

void LadinoTrade::setGanhoMaximo(double value) {
   _ganhoMaximo = value;
}

double LadinoTrade::getPerdaMaxima() {
   return _perdaMaxima;
}

void LadinoTrade::setPerdaMaxima(double value) {
   _perdaMaxima = value;
}

double LadinoTrade::getTotal() {
   double total = 0;
   for (int i = 0; i < ArraySize(_trades); i++)
      total += _trades[i].financeiro - _trades[i].corretagem;
   total += _financeiro;
   total -= _corretagem;
   return total;
}

double LadinoTrade::getFinanceiroTotal() {
   double total = 0;
   for (int i = 0; i < ArraySize(_trades); i++)
      total += _trades[i].financeiro;
   total += _financeiro;
   return total;
}

double LadinoTrade::getCorretagemTotal() {
   double total = 0;
   for (int i = 0; i < ArraySize(_trades); i++)
      total += _trades[i].corretagem;
   total += _corretagem;
   return total;
}

int LadinoTrade::getSucessoTotal() {
   int total = 0;
   for (int i = 0; i < ArraySize(_trades); i++)
      total += _trades[i].sucesso;
   return total;
}

int LadinoTrade::getFalhaTotal() {
   int total = 0;
   for (int i = 0; i < ArraySize(_trades); i++)
      total += _trades[i].falha;
   return total;
}

double LadinoTrade::maxLote(double lot, double sl) {
   if (_posicaoAtual == NENHUMA) {
      int tentativa = _sucesso + _falha;
      double saldo = (_financeiro - _corretagem) + MathAbs(_ganhoMaximo);
      double maxlot = MathFloor( saldo / (sl * 0.2) );
      return (lot > maxlot) ? maxlot : lot;
   }
   else
      return lot;
}

double LadinoTrade::validarFinanceiro(double lot, double sl) {
   double loteAtual = maxLote(lot, sl);
   if (loteAtual <= 0) {
      escreverLog("Financial limit has been reached (" + StringFormat("%.2f", _financeiro) + ").");
      aoAtingirPerdaMax();
      return loteAtual;
   }
   return loteAtual;
}

bool LadinoTrade::comprarTP(double lot, double price) {
   ZeroMemory(_req);
   ZeroMemory(_res);
   ZeroMemory(_check);

   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = NormalizeDouble(price, _Digits);
   preco = preco - MathMod(preco, tickMinimo);

   _req.type = ORDER_TYPE_BUY_LIMIT;
   _req.action = TRADE_ACTION_PENDING;
   _req.price = preco;
   _req.symbol = _Symbol;
   _req.volume = lot;
   _req.deviation = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   _req.type_filling = ORDER_FILLING_IOC;
   _req.type_time = ORDER_TIME_DAY;
   //--
   string msg = "";
   if(OrderCheck(_req, _check)) {
      if(OrderSend(_req, _res)) {
         msg = "TAKE PROFIT buy for " + IntegerToString((int)_req.price) + " (" + _check.comment + ")";
         msg += ", v=" + IntegerToString((int)_req.position);
         escreverLog(msg);
         //candleCount = 0;
         return true;
      }
      else  {
         msg = "TAKE PROFIT buy not scheduled! (" + _res.comment + ")";
         msg += " price=" + IntegerToString((int)_req.price);
         msg += ", v=" + IntegerToString((int)_req.position);
         escreverLog(msg);
         return false;
      }
   }
   else {
      msg = "TAKE PROFIT buy not scheduled! (" + _check.comment + ")";
      msg += " price=" + IntegerToString((int)_req.price);
      msg += ", v=" + IntegerToString((int)_req.position);
      escreverLog(msg);
      return false;
   }
}

bool LadinoTrade::venderTP(double lot, double price) {
   ZeroMemory(_req);
   ZeroMemory(_res);
   ZeroMemory(_check);

   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = NormalizeDouble(price, _Digits);
   preco = preco - MathMod(preco, tickMinimo);

   _req.type = ORDER_TYPE_SELL_LIMIT;
   _req.action = TRADE_ACTION_PENDING;
   _req.price = preco;
   _req.symbol = _Symbol;
   _req.volume = lot;
   _req.deviation = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   _req.type_filling = ORDER_FILLING_IOC;
   _req.type_time = ORDER_TIME_DAY;
   //req.expiration = 
   //--
   string msg = "";
   if(OrderCheck(_req, _check)) {
      if(OrderSend(_req, _res)) {
         msg = "TAKE PROFIT sell for " + IntegerToString((int)_req.price) + " (" + _check.comment + ")";
         msg += ", v=" + IntegerToString((int)_req.position);
         escreverLog(msg);
         //candleCount = 0;
         return true;
      }
      else  {
         msg = "TAKE PROFIT sell not scheduled! (" + _res.comment + ")";
         msg += " price=" + IntegerToString((int)_req.price);
         msg += ", v=" + IntegerToString((int)_req.position);
         escreverLog(msg);
         return false;
      }
   }
   else {
      msg = "TAKE PROFIT sell not scheduled! (" + _check.comment + ")";
      msg += " price=" + IntegerToString((int)_req.price);
      msg += ", v=" + IntegerToString((int)_req.position);
      escreverLog(msg);
      return false;
   }
}

bool LadinoTrade::agendarCompra(double lot, double price, double sl=0.0, double tp=0.0) {

   ZeroMemory(_req);
   ZeroMemory(_res);
   ZeroMemory(_check);

   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = NormalizeDouble(price, _Digits);
   preco = preco - MathMod(preco, tickMinimo);

   double loteAtual = lot;
   if (sl > 0) {
      loteAtual = maxLote(lot, sl);
      if (loteAtual <= 0) {
         escreverLog("Financial limit has been reached (" + StringFormat("%.2f", _financeiro) + ").");
         aoAtingirPerdaMax();
         return false;
      }
   }

   _req.type = ORDER_TYPE_BUY_STOP_LIMIT;
   _req.action = TRADE_ACTION_PENDING;
   _req.price = preco;
   _req.stoplimit = preco;
   if (sl > 0) {
      sl = NormalizeDouble(sl, _Digits);
      sl = sl - MathMod(sl, tickMinimo);
      _req.sl = preco - sl;
   }
   if (tp > 0) {
      tp = NormalizeDouble(tp, _Digits);
      tp = tp - MathMod(tp, tickMinimo);
      _req.tp = preco + tp;
   }
   else
      _req.tp = 0;
   _req.symbol = _Symbol;
   _req.volume = loteAtual;
   _req.deviation = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   _req.type_filling = ORDER_FILLING_IOC;
   //--
   string msg = "";
   if(OrderCheck(_req, _check)) {
      if(OrderSend(_req, _res)) {
         msg = "Buy schedule at " + IntegerToString((int)_req.price) + " (" + _check.comment + ")";
         msg += ", v=" + IntegerToString((int)_req.position);
         msg += ", sl=" + IntegerToString((int)_req.sl);
         if (_req.tp > 0)
            msg += ", tp=" + IntegerToString((int)_req.tp);
         escreverLog(msg);
         //candleCount = 0;
         return true;
      }
      else  {
         msg = "Buy not scheduled! (" + _res.comment + ")";
         msg += " price=" + IntegerToString((int)_req.price);
         msg += ", v=" + IntegerToString((int)_req.position);
         msg += ", sl=" + IntegerToString((int)_req.sl);
         if (_req.tp > 0)
            msg += ", tp=" + IntegerToString((int)_req.tp);
         escreverLog(msg);
         //operando = false;
         return false;
      }
   }
   else {
      msg = "Buy not scheduled! (" + _check.comment + ")";
      msg += " price=" + IntegerToString((int)_req.price);
      msg += ", v=" + IntegerToString((int)_req.position);
      msg += ", sl=" + IntegerToString((int)_req.sl);
      if (_req.tp > 0)
         msg += ", tp=" + IntegerToString((int)_req.tp);
      escreverLog(msg);
      //operando = false;
      return false;
   }
}

bool LadinoTrade::agendarVenda(double lot, double price, double sl=0.0, double tp=0.0) {

   ZeroMemory(_req);
   ZeroMemory(_res);
   ZeroMemory(_check);
   
   //price = NormalizeDouble(price - MathMod(price, 5), 0);
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = NormalizeDouble(price, _Digits);
   preco = preco - MathMod(preco, tickMinimo);

   double loteAtual = lot;
   if (sl > 0) {
      loteAtual = maxLote(lot, sl);
      if (loteAtual <= 0) {
         escreverLog("Financial limit has been reached (" + StringFormat("%.2f", _financeiro) + ").");
         aoAtingirPerdaMax();
         return false;
      }
   }
   
   //req.type = ORDER_TYPE_SELL_STOP_LIMIT;
   _req.type = ORDER_TYPE_SELL_LIMIT;
   _req.action = TRADE_ACTION_PENDING;
   _req.price = preco;
   _req.stoplimit = preco;
   if (sl > 0) {
      sl = NormalizeDouble(sl, _Digits);
      sl = sl - MathMod(sl, tickMinimo);
      _req.sl = preco - sl;
   }
   if (tp > 0) {
      tp = NormalizeDouble(tp, _Digits);
      tp = tp - MathMod(tp, tickMinimo);
      _req.tp = preco + tp;
   }
   else
      _req.tp = 0;
   _req.symbol = _Symbol;
   _req.volume = loteAtual;
   _req.deviation = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   _req.type_filling = ORDER_FILLING_IOC;
   //--
   string msg = "";
   if(OrderCheck(_req, _check)) {
      if(OrderSend(_req, _res)) {
         msg = "Sell schedule at " + IntegerToString((int)_req.price) + " (" + _check.comment + ")";
         msg += ", v=" + IntegerToString((int)_req.position);
         msg += ", sl=" + IntegerToString((int)_req.sl);
         if (_req.tp > 0)
            msg += ", tp=" + IntegerToString((int)_req.tp);
         escreverLog(msg);
         //candleCount = 0;
         return true;
      }
      else  {
         msg = "Sell not scheduled! (" + _res.comment + ")";
         msg += " price=" + IntegerToString((int)_req.price);
         msg += ", v=" + IntegerToString((int)_req.position);
         msg += ", sl=" + IntegerToString((int)_req.sl);
         if (_req.tp > 0)
            msg += ", tp=" + IntegerToString((int)_req.tp);
         escreverLog(msg);
         //operando = false;
         return false;
      }
   }
   else {
      msg = "Sell not scheduled! (" + _check.comment + ")";
      msg += " price=" + IntegerToString((int)_req.price);
      msg += ", v=" + IntegerToString((int)_req.position);
      msg += ", sl=" + IntegerToString((int)_req.sl);
      if (_req.tp > 0)
         msg += ", tp=" + IntegerToString((int)_req.tp);
      escreverLog(msg);
      //operando = false;
      return false;
   }
}

bool LadinoTrade::comprarMercado(double lot, double sl=0.0, double tp=0.0) {
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   preco = NormalizeDouble(preco, _Digits);
   preco = preco - MathMod(preco, tickMinimo);
   return comprar(lot, preco, sl, tp);
}

bool LadinoTrade::venderMercado(double lot, double sl=0.0, double tp=0.0) {
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   preco = NormalizeDouble(preco, _Digits);
   preco = preco - MathMod(preco, tickMinimo);
   return vender(lot, preco, sl, tp);
}

bool LadinoTrade::comprarForcado(double lot, double sl=0.0, double tp=0.0, int tentativa = 20) {
   bool retorno = false;
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   preco = NormalizeDouble(preco, _Digits);
   preco = preco - MathMod(preco, tickMinimo);
   
   if (comprar(lot, preco, sl, tp)) {
      retorno = true;
   }
   else {
      preco += tickMinimo;
      for (int i = 0; i < tentativa; i++) {
         if (agendarCompra(lot, preco, sl, tp)) {
            retorno = true;
            break;
         }
         preco += tickMinimo;
      }
   }
   return retorno;
}

bool LadinoTrade::venderForcado(double lot, double sl=0.0, double tp=0.0, int tentativa = 20) {
   bool retorno = false;
   
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   preco = NormalizeDouble(preco, _Digits);
   preco = preco - MathMod(preco, tickMinimo);
   
   if (vender(lot, preco, sl, tp)) {
      retorno = true;
   }
   else {
      preco -= tickMinimo;
      for (int i = 0; i < tentativa; i++) {
         if (agendarVenda(lot, preco, sl, tp)) {
            retorno = true;
            break;
         }
         preco -= tickMinimo;
      }
   }
   return retorno;
}

bool LadinoTrade::comprar(double lot, double price, double sl=0.0, double tp=0.0) {

   ZeroMemory(_req);
   ZeroMemory(_res);
   ZeroMemory(_check);

   double tickMinimo = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double preco = NormalizeDouble(price, _Digits);
   preco = preco - MathMod(preco, tickMinimo);

   _req.type=ORDER_TYPE_BUY;
   _req.action=TRADE_ACTION_DEAL;
   _req.price = preco;
   if (sl > 0) {
      sl = NormalizeDouble(sl, _Digits);
      sl = sl - MathMod(sl, tickMinimo);
      _req.sl = preco - sl;
      if (_posicaoAtual == COMPRADO && _stopLoss > 0 && _req.sl < _stopLoss)
         _req.sl = _stopLoss;
         
   }
   if (tp > 0) {
      tp = NormalizeDouble(tp, _Digits);
      tp = tp + MathMod(tp, tickMinimo);
      _req.tp = preco + tp;
   }
   else
      _req.tp = 0;
   _req.symbol = _Symbol;
   _req.volume = lot;
   _req.deviation = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   _req.type_filling = ORDER_FILLING_IOC;
   //--
   string msg = "";
   if(OrderCheck(_req, _check)) {
      if(OrderSend(_req, _res)) {
         _stopLoss = _req.sl;
         //candleCount = 0;
         return true;
      }
      else  {
         msg = "Buy not sent! (" + _res.comment + ")";
         msg += " price=" + IntegerToString((int)_req.price);
         msg += ", v=" + IntegerToString((int)_req.volume);
         msg += ", sl=" + IntegerToString((int)_req.sl);
         if (tp > 0)
            msg += ", tp=" + IntegerToString((int)_req.tp);
         escreverLog(msg);
         //operando = false;
         return false;
      }
   }
   else {
      msg = "Buy not sent! (" + _check.comment + ")";
      msg += " price=" + IntegerToString((int)_req.price);
      msg += ", v=" + IntegerToString((int)_req.volume);
      msg += ", sl=" + IntegerToString((int)_req.sl);
      if (_req.tp > 0)
         msg += ", tp=" + IntegerToString((int)_req.tp);
      escreverLog(msg);
      //operando = false;
      return false;
   }
}

bool LadinoTrade::vender(double lot, double price, double sl=0.0, double tp=0.0) {

   ZeroMemory(_req);
   ZeroMemory(_res);
   ZeroMemory(_check);

   //double loteAtual = validarFinanceiro(lot, sl);
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double preco = NormalizeDouble(price, _Digits);
   preco = preco - MathMod(preco, tickMinimo);

   _req.type = ORDER_TYPE_SELL;
   _req.action = TRADE_ACTION_DEAL;
   _req.price = preco;
   if (sl > 0) {
      sl = NormalizeDouble(sl, _Digits);
      sl = sl - MathMod(sl, tickMinimo);
      _req.sl = preco + sl;
      if (_posicaoAtual == VENDIDO && _stopLoss > 0 && _req.sl > _stopLoss)
         _req.sl = _stopLoss;
   }
   if (tp > 0) {
      tp = NormalizeDouble(tp, _Digits);
      tp = tp - MathMod(tp, tickMinimo);
      _req.tp = preco - tp;
   }
   else
      _req.tp = 0;
   _req.symbol = _Symbol;
   _req.volume = lot;
   _req.deviation = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   _req.type_filling=ORDER_FILLING_IOC;
   //--
   string msg = "";
   if(OrderCheck(_req, _check)) {
      if(OrderSend(_req, _res)) {
         /*
         msg = "VENDER à " + IntegerToString((int)req.price) + " (" + check.comment + ")";
         msg += ", v=" + IntegerToString((int)req.volume);
         msg += ", sl=" + IntegerToString((int)req.sl);
         if (req.tp > 0)
            msg += ", tp=" + IntegerToString((int)req.tp);
         escreverLog(msg);
         */
         _stopLoss = _req.sl;
         //candleCount = 0;
         return true;
      }
      else  {
         msg = "Sell not sent! (" + _res.comment + ")";
         msg += " price=" + IntegerToString((int)_req.price);
         msg += ", v=" + IntegerToString((int)_req.volume);
         msg += ", sl=" + IntegerToString((int)_req.sl);
         if (_req.tp > 0)
            msg += ", tp=" + IntegerToString((int)_req.tp);
         escreverLog(msg);
         //operando = false;
         return false;
      }
   }
   else {
      msg = "Sell not sent! (" + _check.comment + ")";
      msg += " price=" + IntegerToString((int)_req.price);
      msg += ", v=" + IntegerToString((int)_req.volume);
      msg += ", sl=" + IntegerToString((int)_req.sl);
      if (_req.tp > 0)
         msg += ", tp=" + IntegerToString((int)_req.tp);
      escreverLog(msg);
      //operando = false;
      return false;
   }
}

bool LadinoTrade::finalizarPosicao()  {
   if(PositionSelect(_Symbol)) {
      ResetLastError();
      
      ZeroMemory(_stop);
      ZeroMemory(_check);
      ZeroMemory(_res);
   
      double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
      double preco = 0;
      //preco = preco - MathMod(preco, tickMinimo);
      
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
         _stop.type = ORDER_TYPE_SELL;
         preco = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      }
      else {
         _stop.type = ORDER_TYPE_BUY;
         preco = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      }
      preco = NormalizeDouble(preco, _Digits);
      preco = preco - MathMod(preco, tickMinimo);
      _stop.price = preco;
      
      _stop.action = TRADE_ACTION_DEAL;
      _stop.symbol = _Symbol;
      _stop.volume = MathAbs(getVolume());
      _stop.deviation = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
      _stop.type_filling = ORDER_FILLING_IOC;
      
      string msg;
      if(OrderCheck(_stop, _check)) {
         if(OrderSend(_stop, _res)) {
            if (_stop.type == ORDER_TYPE_SELL)
               msg = "Closing buy position selling in ";
            else
               msg = "Closing sell position buying in ";
            msg += IntegerToString((int)_stop.price) + " (" + _res.comment + ")";
            escreverLog(msg);
            return true;
         }
         else {
            if (_stop.type == ORDER_TYPE_SELL)
               msg = "Sell not sent for ";
            else
               msg = "Buy not sent for ";
            msg += IntegerToString((int)_stop.price) + " (" + _res.comment + ")";
            escreverLog(msg);
            return false;
         }
      }
      else {
         if (_stop.type == ORDER_TYPE_SELL)
            msg = "Sell not sent for ";
         else
            msg = "Buy not sent for ";
         msg += IntegerToString((int)_stop.price) + " (" + _res.comment + ")";
         escreverLog(msg);
         return false;
      }
   }
   return false;
}

bool LadinoTrade::realizarPosicao(double lot) {
   if(PositionSelect(_Symbol)) {
      double lote = (MathAbs(getVolume()) < lot) ? MathAbs(getVolume()) : lot;
      if (_posicaoAtual == COMPRADO)
         return venderMercado(lote);
      else if (_posicaoAtual == VENDIDO)
         return comprarMercado(lote);
   }
   return false;
}

void LadinoTrade::abrirPosicao(double preco, double volume) {
   _financeiroAtual = 0;
   //volumePosicao += volume;
   _precoEntrada = preco;
   //double realizado = -(valorCorretagem * MathAbs(volume));
   //corretagem += valorCorretagem * MathAbs(volume);
   //financeiro += realizado;
   double p = 0, volumeLocal = 0;
   double vtotal = MathAbs(volume);
   if (volume > 0) { 
      _posicaoAtual = COMPRADO;
      if (_breakEvenVolume > 0 && _breakEvenPosicao > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _breakEvenVolume) ? _breakEvenVolume : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada + _breakEvenPosicao;
         if (volumeLocal > 0 && !venderTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar o Break Even para " + IntegerToString((int) p) + ".");
      }
      if (_objetivoVolume1 > 0 && _objetivoPosicao1 > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _objetivoVolume1) ? _objetivoVolume1 : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada + _objetivoPosicao1;
         if (volumeLocal > 0 && !venderTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar Take Profit para " + IntegerToString((int) p) + ".");               
      }
      if (_objetivoVolume2 > 0 && _objetivoPosicao2 > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _objetivoVolume2) ? _objetivoVolume2 : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada + _objetivoPosicao2;
         if (volumeLocal > 0 && !venderTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar Take Profit para " + IntegerToString((int) p) + ".");               
      }
      if (_objetivoVolume3 > 0 && _objetivoPosicao3 > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _objetivoVolume3) ? _objetivoVolume3 : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada + _objetivoPosicao3;
         if (volumeLocal > 0 && !venderTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar Take Profit para " + IntegerToString((int) p) + ".");               
      }
   }
   else if (volume < 0) {
      _posicaoAtual = VENDIDO;
      if (_breakEvenVolume > 0 && _breakEvenPosicao > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _breakEvenVolume) ? _breakEvenVolume : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada - _breakEvenPosicao;
         if (volumeLocal > 0 && !comprarTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar o Break Even para " + IntegerToString((int) p) + ".");
      }
      if (_objetivoVolume1 > 0 && _objetivoPosicao1 > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _objetivoVolume1) ? _objetivoVolume1 : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada - _objetivoPosicao1;
         if (volumeLocal > 0 && !comprarTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar Take Profit para " + IntegerToString((int) p) + ".");               
      }
      if (_objetivoVolume2 > 0 && _objetivoPosicao2 > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _objetivoVolume2) ? _objetivoVolume2 : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada - _objetivoPosicao2;
         if (volumeLocal > 0 && !comprarTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar Take Profit para " + IntegerToString((int) p) + ".");               
      }
      if (_objetivoVolume3 > 0 && _objetivoPosicao3 > 0 && vtotal > 0) {
         volumeLocal = (vtotal > _objetivoVolume3) ? _objetivoVolume3 : vtotal;
         vtotal -= volumeLocal;
         p = _precoEntrada - _objetivoPosicao3;
         if (volumeLocal > 0 && !comprarTP(volumeLocal, p))
            escreverLog("ERRO ao tentar agendar Take Profit para " + IntegerToString((int) p) + ".");               
      }
   }
   novoPosicionamento(preco, volume);
   aoAbrirPosicao();
   //operacaoAtual = SITUACAO_ABERTA;
   //return realizado;
}

void LadinoTrade::parcialPosicao(double preco, double volume) {
   //volumePosicao += volume;
   if (_posicaoAtual == COMPRADO) {
      if (volume > 0)
         novoPosicionamento(preco, volume);
      else if (volume < 0)
         fecharPosicionamento(preco, volume);
   }
   else if (_posicaoAtual == VENDIDO) {
      if (volume < 0)
         novoPosicionamento(preco, volume);
      else if (volume > 0)
         fecharPosicionamento(preco, volume);
   }
   /*
   double pontos = 0;
   if (_posicaoAtual == COMPRADO)
      pontos = preco - _precoEntrada;
   else if (_posicaoAtual == VENDIDO)
      pontos = _precoEntrada - preco;
   */
   //double cc = (_tipoAtivo == ATIVO_INDICE) ? valorCorretagem * MathAbs(volume) : valorCorretagem;
   //corretagem += cc;
   //double realizado = pontos * _valorPonto * MathAbs(volume);
   //financeiro += realizado;
   //return realizado - cc;
}

void LadinoTrade::fecharPosicao(double preco, double volume) {
   //volumePosicao += volume;
   /*
   double pontos = 0;
   if (_posicaoAtual == COMPRADO)
      pontos = preco - _precoEntrada;
   else if (_posicaoAtual == VENDIDO) 
      pontos = _precoEntrada - preco;
   //double cc = valorCorretagem * MathAbs(volume);
   double cc = (_tipoAtivo == ATIVO_INDICE) ? valorCorretagem * MathAbs(volume) : valorCorretagem;
   corretagem += cc;
   //double realizado = pontos * 0.2 * MathAbs(volume);
   double realizado = pontos * _valorPonto * MathAbs(volume);
   financeiro += realizado;
   //realizado -= cc;
   */
   fecharPosicionamento(preco, volume);
   if (_financeiroAtual > 0)
      _sucesso++;
   else
      _falha++;
      
   string msg = (_posicaoAtual == COMPRADO) ? "BUY" : "SELL";
   msg += " finished, $=" + StringFormat("%.2f", _financeiroAtual);
   msg += ", c=-" + IntegerToString((int)_corretagem);
   msg += ", $$=" + StringFormat("%.2f", _financeiro - _corretagem);
   msg += ", s/f=" + IntegerToString(_sucesso) + "/" + IntegerToString(_falha);
   escreverLog(msg);
   
      
   _posicaoAtual = NENHUMA;
   _precoEntrada = 0;
   _stopLoss = 0;
   //operacaoTipo = LIQUIDO;
   //currentSL = 0;
   //currentTP = 0;
   //operacaoAtual = SITUACAO_FECHADA;   
   cancelarOrdemPendente();
   aoFecharPosicao(_financeiroAtual);
   //return realizado - cc;
}

void LadinoTrade::aoNegociar(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
   if (trans.type == TRADE_TRANSACTION_DEAL_ADD) {
      double realizado = 0;
      //string msg = "";
      if (trans.deal_type == DEAL_TYPE_BUY) {
         //msg = "COMPRADO à " +  + IntegerToString((int)trans.price) + "!";
         if (getVolume() == 0)
            abrirPosicao(trans.price, trans.volume);
         else {
            if ((getVolume() + trans.volume) == 0)
               //realizado = fecharPosicao(trans.price, trans.volume);
               fecharPosicao(trans.price, trans.volume);
            else
               //realizado = parcialPosicao(trans.price, trans.volume);
               parcialPosicao(trans.price, trans.volume);
         }
      }
      if (trans.deal_type == DEAL_TYPE_SELL) {
         //msg = "VENDIDO à " +  + IntegerToString((int)trans.price) + "!";
         if (getVolume() == 0)
            abrirPosicao(trans.price, -trans.volume);
         else {
            if ((getVolume() - trans.volume) == 0)
               //realizado = fecharPosicao(trans.price, -trans.volume);
               fecharPosicao(trans.price, -trans.volume);
            else
               //realizado = parcialPosicao(trans.price, -trans.volume);
               parcialPosicao(trans.price, -trans.volume);
         }
      }
      /*
      msg += ", v=" + IntegerToString((int)volumePosicao);
      if (realizado != 0)
         msg += ", $=" + StringFormat("%.2f", realizado);
      msg += ", $$=" + StringFormat("%.2f", financeiro);
      msg += ", s/f=" + IntegerToString(sucesso) + "/" + IntegerToString(falha);
      escreverLog(msg);
      */
      //cancelarOrdemPendente();
   }
}

bool LadinoTrade::cancelarOrdem(const ulong ticket) {
   ZeroMemory(_req);
   ZeroMemory(_res);
   _req.action = TRADE_ACTION_REMOVE;
   _req.magic = PositionGetInteger(POSITION_MAGIC);
   _req.order = ticket;
   return OrderSend(_req, _res);
}

void LadinoTrade::cancelarOrdemPendente() {
   ulong order_ticket; 
   for(int i = OrdersTotal() - 1; i>=0; i--) {
      if((order_ticket = OrderGetTicket(i)) > 0) 
         //trade.OrderDelete(order_ticket);
         cancelarOrdem(order_ticket);
   } 
   escreverLog("Cancelando todas as ordens pendentes.");
}

bool LadinoTrade::alterarOrdem(const string symbol, const double sl, const double tp) {

   //if (!SelectPosition(symbol))
   if (!PositionSelect(symbol))   
      return false;
      
   ZeroMemory(_req);
   ZeroMemory(_res);
   _req.action = TRADE_ACTION_SLTP;
   _req.symbol = symbol;
   //req.symbol = PositionGetString(POSITION_SYMBOL);
   _req.magic = PositionGetInteger(POSITION_MAGIC);
   _req.sl = sl;
   _req.tp = tp;
   return OrderSend(_req, _res);
}

bool LadinoTrade::modificarPosicao(double sl, double tp = 0) {
   //double stopLoss = sl;
   if (_posicaoAtual == COMPRADO && sl < _stopLoss)
      sl = _stopLoss;
   if (_posicaoAtual == VENDIDO && sl > _stopLoss)
      sl = _stopLoss;
         
   if (alterarOrdem(_Symbol, sl, tp)) {
      _stopLoss = sl;
      return true;
   }
   else 
      return false;
      
}

int LadinoTrade::ordemTipo() {
   return _req.type;
}

void LadinoTrade::fecharDia() {
   ArrayResize(_trades, ArraySize(_trades) + 1);
   TRADE_FECHADO tt;
   ZeroMemory(tt);
   tt.data = TimeCurrent();
   tt.corretagem = _corretagem;
   tt.financeiro = _financeiro;
   tt.sucesso = _sucesso;
   tt.falha = _falha;
   
   _trades[ArraySize(_trades) - 1] = tt;
   
   _financeiro = 0;
   _corretagem = 0;
   _sucesso = 0;
   _falha = 0;
}

double LadinoTrade::getValorPonto() {
   return _valorPonto;
}

void LadinoTrade::setValorPonto(double valorPonto) {
   _valorPonto = valorPonto;
}

ATIVO_TIPO LadinoTrade::getTipoAtivo() {
   return _tipoAtivo;
}

void LadinoTrade::setTipoAtivo(ATIVO_TIPO tipo) {
   _tipoAtivo = tipo;
}

void LadinoTrade::escreverLog(string msg) {
   Print(msg);
}

void LadinoTrade::novoPosicionamento(double preco, double lot) {
   TRADE_POSICAO posicao;
   ZeroMemory(posicao);
   //posicao.dataEntrada = TimeCurrent();
   posicao.precoEntrada = preco;
   //posicao.precoSaida = 0;
   posicao.volumeInicial = lot;
   posicao.volumeAtual = lot;
   posicao.corretagem = (_tipoAtivo == ATIVO_INDICE) ? _valorCorretagem * MathAbs(lot) : _valorCorretagem;
   _corretagem += posicao.corretagem;
   ArrayResize(_posicoes, ArraySize(_posicoes) + 1);
   _posicoes[ArraySize(_posicoes) - 1] = posicao;
   
   string msg = "*";
   /*
   if (_posicaoAtual == COMPRADO)
      msg += "BUY";
   else if (_posicaoAtual == VENDIDO)
      msg += "SELL";
   */
   if (lot > 0)
      msg += "BUY";
   else if (lot < 0)
      msg += "SELL";
   msg += " e=" + IntegerToString((int)preco);
   msg += ", v=" + IntegerToString((int)MathAbs(lot));
   msg += ", c=-" + IntegerToString((int)IntegerToString((int)posicao.corretagem));
   msg += ", $=" + IntegerToString((int)StringFormat("%.2f", _financeiroAtual));
   msg += ", $$=" + IntegerToString((int)StringFormat("%.2f", _financeiro));
   escreverLog(msg);
}

void LadinoTrade::fecharPosicionamento(double preco, double lot) {
   double v = lot; 
   while (ArraySize(_posicoes) > 0 && v != 0) {
      double pontos = 0;
      if (_posicaoAtual == COMPRADO)
         pontos = preco - _posicoes[0].precoEntrada;
      else if (_posicaoAtual == VENDIDO) 
         pontos = _posicoes[0].precoEntrada - preco;
      //double realizado = pontos * _valorPonto * v;
      if (MathAbs(v) >= MathAbs(_posicoes[0].volumeAtual)) {
         double realizado = pontos * _valorPonto * MathAbs(_posicoes[0].volumeAtual);
         _financeiro += realizado;
   
         double cc = (_tipoAtivo == ATIVO_INDICE) ? _valorCorretagem * MathAbs(_posicoes[0].volumeAtual) : _valorCorretagem;
         _posicoes[0].corretagem += cc;
         _corretagem += cc;
         _financeiroAtual += realizado - cc;
            
         string msg = "*";
         /*
         if (_posicaoAtual == COMPRADO)
            msg += "BUY";
         else if (_posicaoAtual == VENDIDO)
            msg += "SELL";
         */
         if (v > 0)
            msg += "BUY";
         else if (v < 0)
            msg += "SELL";
         msg += ", e/s=" + IntegerToString((int)_posicoes[0].precoEntrada) + "/" + IntegerToString((int)preco);
         msg += ", v=" + IntegerToString((int)MathAbs(_posicoes[0].volumeAtual));
         msg += ", c=-" + IntegerToString((int)IntegerToString((int)_posicoes[0].corretagem));
         msg += ", $=" + IntegerToString((int)StringFormat("%.2f", _financeiroAtual));
         msg += ", $$=" + IntegerToString((int)StringFormat("%.2f", _financeiro - _corretagem));
         escreverLog(msg);
            
         v += _posicoes[0].volumeAtual;
         for (int i = 1; i < ArraySize(_posicoes); i++)
            _posicoes[i-1] = _posicoes[i];
         ArrayResize(_posicoes, ArraySize(_posicoes) - 1);
      }
      else {
         _posicoes[0].volumeAtual += v;
         double realizado = pontos * _valorPonto * MathAbs(v);
         _financeiro += realizado;
         
         double cc = (_tipoAtivo == ATIVO_INDICE) ? _valorCorretagem * MathAbs(v) : _valorCorretagem;
         _posicoes[0].corretagem += cc;
         _corretagem += cc;
         _financeiroAtual += realizado - cc;
         
         string msg = "*";
         if (v > 0)
            msg += "BUY";
         else if (v < 0)
            msg += "SELL";
         msg += ", e/s=" + IntegerToString((int)_posicoes[0].precoEntrada) + "/" + IntegerToString((int)preco);
         msg += ", v=" + IntegerToString((int)MathAbs(_posicoes[0].volumeAtual));
         msg += ", c=-" + IntegerToString((int)IntegerToString((int)_posicoes[0].corretagem));
         msg += ", $=" + IntegerToString((int)StringFormat("%.2f", _financeiroAtual));
         msg += ", $$=" + IntegerToString((int)StringFormat("%.2f", _financeiro - _corretagem));
         escreverLog(msg);
         
         v = 0;
      }
   }
}

double LadinoTrade::getStopLoss() {
   return _stopLoss;
}

double LadinoTrade::posicaoPontoEmAberto(double preco) {
   double pontoAtual = 0;
   if (_posicaoAtual == COMPRADO) {
      for (int i = 0; i < ArraySize(_posicoes); i++) {
         double v = MathAbs(_posicoes[i].volumeAtual);
         pontoAtual += (preco - _posicoes[i].precoEntrada) * v;
      }
   }
   else if (_posicaoAtual == VENDIDO) {
      for (int i = 0; i < ArraySize(_posicoes); i++) {
         double v = MathAbs(_posicoes[i].volumeAtual);
         pontoAtual += (_posicoes[i].precoEntrada - preco) * v;
      }
   }
   return pontoAtual;
}

double LadinoTrade::precoPosicaoEmAberto() {
   double precoAtual = 0;
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   if (_posicaoAtual == COMPRADO) {
      double preco = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      preco = NormalizeDouble(preco, _Digits);
      preco = preco - MathMod(preco, tickMinimo);  
      for (int i = 0; i < ArraySize(_posicoes); i++) {
         double v = MathAbs(_posicoes[i].volumeAtual);
         double pontos = preco - _posicoes[i].precoEntrada;
         double realizado = pontos * _valorPonto * v;
         double cc = (_tipoAtivo == ATIVO_INDICE) ? _valorCorretagem * MathAbs(v) : _valorCorretagem;
         precoAtual += realizado - cc;
      }
   }
   else if (_posicaoAtual == VENDIDO) {
      double preco = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      preco = NormalizeDouble(preco, _Digits);
      preco = preco - MathMod(preco, tickMinimo);  
      for (int i = 0; i < ArraySize(_posicoes); i++) {
         double v = MathAbs(_posicoes[i].volumeAtual);
         double pontos = _posicoes[i].precoEntrada - preco;
         double realizado = pontos * _valorPonto * v;
         double cc = (_tipoAtivo == ATIVO_INDICE) ? _valorCorretagem * MathAbs(v) : _valorCorretagem;
         precoAtual += realizado - cc;
      }
   }
   return precoAtual;
}

double LadinoTrade::precoOperacaoAtual() {
   return _financeiroAtual + precoPosicaoEmAberto();
}

double LadinoTrade::precoAtual() {
   return _financeiro - _corretagem + precoPosicaoEmAberto();
}

void LadinoTrade::aoAbrirPosicao() {
   // nada
}

void LadinoTrade::aoFecharPosicao(double saldo) {
   Print(saldo);
}

void LadinoTrade::aoAtingirGanhoMax() {
}

void LadinoTrade::aoAtingirPerdaMax() {
}