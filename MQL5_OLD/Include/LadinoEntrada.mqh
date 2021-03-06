//+------------------------------------------------------------------+
//|                                                    LadinoBot.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <LadinoCandlestick.mqh>
#include <LadinoSR.mqh>
#include <LadinoCore.mqh>

class LadinoEntrada: public LadinoCore {
   private:
   public:
      LadinoEntrada(void);
      bool inicializarCompra(double price, double stopLoss);
      bool inicializarVenda(double price, double stopLoss);
      bool aumentarCompra(double lot, double price, double stopLoss);
      bool aumentarVenda(double lot, double price, double stopLoss);
      bool comprarCruzouHiLo(SINAL_TENDENCIA tendenciaHiLo, ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, double mm);
      bool venderCruzouHiLo(SINAL_TENDENCIA tendenciaHiLo, ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, double mm);
      bool comprarNaTendencia(VELA& velaAtual, VELA& velaAnterior);
      bool venderNaTendencia(VELA& velaAtual, VELA& velaAnterior);
      void comprarDunnigan(ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, VELA& vela3, VELA& vela4);
      void venderDunnigan(ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, VELA& vela3, VELA& vela4);
      bool iniciandoExecucaoCompra();
      bool iniciandoExecucaoVenda();
      bool executarAumento(SINAL_POSICAO tendencia, double volume);
      void verificarRompimentoLTB();
      void verificarRompimentoLTA();
      bool verificarEntrada();
};

LadinoEntrada::LadinoEntrada(void) {

}

bool LadinoEntrada::inicializarCompra(double price, double stopLoss) {

   if (_TipoOperacao != COMPRAR_VENDER && _TipoOperacao != APENAS_COMPRAR)
      return false;

   double sl = price - NormalizeDouble(stopLoss - getStopExtra(), _Digits);
   if (getStopLossMax() > 0 && sl >= getStopLossMax()) {
      if (_ultimoStopMax != sl) {
         _ultimoStopMax = sl;
         escreverLog("Stop Loss exceeds max value=" + IntegerToString((int)sl) + ".");
      }
      if (getForcarEntrada())
         sl = getStopLossMax();
      else
         return false;
   }
   
   if (getStopLossMin() > 0 && sl < getStopLossMin())
      sl = getStopLossMin();
   
   double lot = this.validarFinanceiro(_InicialVolume, sl);
   if (lot <= 0)
      return false;

   if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      if (getForcarOperacao()) {
         if (this.comprarForcado(lot, sl, 0, 10)) {
            configurarTakeProfit(COMPRADO, price);
            return true;
         }
      }
      else {
         if (this.comprar(lot, price, sl)) {
            configurarTakeProfit(COMPRADO, price);
            return true;
         }
      }
   }
   return false;
}

bool LadinoEntrada::inicializarVenda(double price, double stopLoss) {

   if (_TipoOperacao != COMPRAR_VENDER && _TipoOperacao != APENAS_VENDER)
      return false;

   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double sl = NormalizeDouble(stopLoss + getStopExtra(), _Digits) - price;
   
   if (getStopLossMax() > 0 && sl >= getStopLossMax()) {
      if (_ultimoStopMax != sl) {
         _ultimoStopMax = sl;
         escreverLog("Stop Loss exceeds max value=" + IntegerToString((int)sl) + ".");
      }
      if (getForcarEntrada())
         sl = getStopLossMax();
      else
         return false;      
   }
   if (getStopLossMin() > 0 && sl < getStopLossMin())
      sl = getStopLossMin();
   
   double lot = this.validarFinanceiro(_volumeAtual, sl);
   if (lot <= 0)
      return false;
   
   if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {      
      if (getForcarOperacao()) {
         if (this.venderForcado(lot, sl, 0, 10)) {
            configurarTakeProfit(VENDIDO, price);
            return true;
         }      
      }
      else {
         if (this.vender(lot, price, sl)) {
            configurarTakeProfit(VENDIDO, price);
            return true;
         }
      }
   }
   return false;
}


bool LadinoEntrada::aumentarCompra(double lot, double price, double stopLoss) {

   if (!(price > (this.ultimoPrecoEntrada() + getAumentoMinimo())))
      return false;      
   if ((MathAbs(this.getVolume()) + lot) > _MaximoVolume)
      return false;

   //double sl = price - NormalizeDouble(stopLoss - AumentoPosicaoStopExtra, _Digits);   
   double sl = NormalizeDouble(stopLoss, _Digits);   
   if (getStopLossMin() > 0 && sl < getStopLossMin())
      sl = getStopLossMin();

   if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      if (this.comprar(lot, price, sl)) {
         return true;
      }
   }
   return false;
}

bool LadinoEntrada::aumentarVenda(double lot, double price, double stopLoss) {

   if (!(price < (this.ultimoPrecoEntrada() - getAumentoMinimo())))
      return false;
   if ((MathAbs(this.getVolume()) + lot) > _MaximoVolume)
      return false;

   //double sl = price + NormalizeDouble(stopLoss + AumentoPosicaoStopExtra, _Digits);   
   double sl = NormalizeDouble(stopLoss, _Digits);   
   if (getStopLossMin() > 0 && sl < getStopLossMin())
      sl = getStopLossMin();

   if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      if (this.vender(lot, price, sl)) {
         return true;
      }
   }
   return false;
}

bool LadinoEntrada::comprarCruzouHiLo(SINAL_TENDENCIA tendenciaHiLo, ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, double mm) {
   if (tendenciaHiLo == ALTA && _negociacaoAtual != ALTA) {
      if (velaAtual.tipo == COMPRADORA && velaAnterior.tipo == COMPRADORA && _precoCompra > velaAtual.abertura) { // Rompeu a anterior
         if (_precoCompra > mm && mm >= velaAtual.minima && mm <= velaAtual.maxima) {
            if (getT1LinhaTendencia()) {
               _negociacaoAtual = ALTA;
               atualizarNegociacaoAtual();
               _tamanhoLinhaTendencia = autoTrend.gerarLTB(ultimaLT, tempo, ChartID(), 15);
               return true;
            }
            else {
               double posicaoStop = pegarPosicaoStop(COMPRADO);
               if (inicializarCompra(_precoCompra, posicaoStop)) {
                  ultimaLT = velaAtual.tempo;
                  return true;
               }
            }
         }
      }
   }
   return false;
}

bool LadinoEntrada::venderCruzouHiLo(SINAL_TENDENCIA tendenciaHiLo, ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, double mm) {
   if (tendenciaHiLo == BAIXA && _negociacaoAtual != BAIXA) {
      if (velaAtual.tipo == VENDEDORA && velaAnterior.tipo == VENDEDORA && _precoVenda < velaAtual.abertura) { // Rompeu a anterior
         if (_precoVenda < mm && mm <= velaAtual.maxima && mm >= velaAtual.minima) {
         
            if (getT1LinhaTendencia()) {
               _negociacaoAtual = BAIXA;
               atualizarNegociacaoAtual();
               _tamanhoLinhaTendencia = autoTrend.gerarLTA(ultimaLT, tempo, ChartID(), 15);
               return true;
            }
            else {
               double posicaoStop = pegarPosicaoStop(VENDIDO);
               if (inicializarVenda(_precoVenda, posicaoStop)) {
                  ultimaLT = velaAtual.tempo;
                  return true;
               }
            }
            
         }
      }
   }
   return false;
}

bool LadinoEntrada::comprarNaTendencia(VELA& velaAtual, VELA& velaAnterior) {
   //if (negociacaoAtual != ALTA)
   //   return false;
   if (getT1HiloTendencia() && _t1TendenciaHiLo != ALTA) 
      return false;
   if (getT2HiloTendencia() && _t2TendenciaHiLo != ALTA) 
      return false;
   if (getT3HiloTendencia() && _t3TendenciaHiLo != ALTA) 
      return false;
      
   if (getT1SRTendencia() && _t1TendenciaSR != ALTA)
      return false;
   if (getT2SRTendencia() && _t2TendenciaSR != ALTA)
      return false;
   if (getT3SRTendencia() && _t3TendenciaSR != ALTA)
      return false;
      
   if (!(velaAtual.tipo == COMPRADORA && _precoCompra > velaAtual.abertura)) 
      return false;
   if (!(velaAnterior.tipo == COMPRADORA && _precoCompra > velaAnterior.maxima)) 
      return false;
   _negociacaoAtual = ALTA;
   atualizarNegociacaoAtual();
   _tamanhoLinhaTendencia = autoTrend.gerarLTB(ultimaLT, PERIOD_CURRENT, ChartID(), 15);
   return true;
}

bool LadinoEntrada::venderNaTendencia(VELA& velaAtual, VELA& velaAnterior) {
   //if (negociacaoAtual != BAIXA)
   //   return false;
   if (getT1HiloTendencia() && _t1TendenciaHiLo != BAIXA) 
      return false;
   if (getT2HiloTendencia() && _t2TendenciaHiLo != BAIXA) 
      return false;
   if (getT3HiloTendencia() && _t3TendenciaHiLo != BAIXA) 
      return false;
      
   if (getT1SRTendencia() && _t1TendenciaSR != BAIXA)
      return false;
   if (getT2SRTendencia() && _t2TendenciaSR != BAIXA)
      return false;
   if (getT3SRTendencia() && _t3TendenciaSR != BAIXA)
      return false;
      
   if (!(velaAtual.tipo == VENDEDORA && _precoVenda < velaAtual.abertura)) 
      return false;
   if (!(velaAnterior.tipo == VENDEDORA && _precoVenda < velaAnterior.minima)) 
      return false;
   _negociacaoAtual = BAIXA;
   atualizarNegociacaoAtual();
   _tamanhoLinhaTendencia = autoTrend.gerarLTA(ultimaLT, PERIOD_CURRENT, ChartID(), 15);
   return true;
}

void LadinoEntrada::comprarDunnigan(ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, VELA& vela3, VELA& vela4) {
}

void LadinoEntrada::venderDunnigan(ENUM_TIMEFRAMES tempo, VELA& velaAtual, VELA& velaAnterior, VELA& vela3, VELA& vela4) {
}

bool LadinoEntrada::iniciandoExecucaoCompra() {
   double posicaoLTB = 0, posicaoStop = 0;
   if (_negociacaoAtual != ALTA)
      return false;
   if (getT1HiloTendencia() && _t1TendenciaHiLo != ALTA) 
      return false;
   if (getT2GraficoExtra() && getT2HiloTendencia() && _t2TendenciaHiLo != ALTA)
      return false;
   if (getT3GraficoExtra() && getT3HiloTendencia() && _t3TendenciaHiLo != ALTA) 
      return false;
      
   if (getT1SRTendencia() && _t1TendenciaSR != ALTA)
      return false;
   if (getT2GraficoExtra() && getT2SRTendencia() && _t2TendenciaSR != ALTA)
      return false;
   if (getT3GraficoExtra() && getT3SRTendencia() && _t3TendenciaSR != ALTA)
      return false;
      
   if (_tamanhoLinhaTendencia >= 3 && t1VelaAnterior.tipo == COMPRADORA)
      posicaoLTB = autoTrend.posicaoLTB(ChartID(), t1VelaAtual.tempo) + getLTExtra();
   else
      return false;
   if (posicaoLTB > 0 && _precoCompra > posicaoLTB && posicaoLTB >= t1VelaAtual.minima && posicaoLTB <= t1VelaAtual.maxima && _precoCompra > t1VelaAnterior.maxima)
      posicaoStop = pegarPosicaoStop(COMPRADO);
   else
      return false;
   if (inicializarCompra(_precoCompra, posicaoStop)) {
      autoTrend.limparLinha(ChartID());
      ultimaLT = t1VelaAtual.tempo;
      return true;
   }
   return false;
}

bool LadinoEntrada::iniciandoExecucaoVenda() {
   double posicaoLTA = 0, posicaoStop = 0;
   if (_negociacaoAtual != BAIXA)
      return false;
   if (getT1HiloTendencia() && _t1TendenciaHiLo != ALTA) 
      return false;
   if (getT2GraficoExtra() && getT2HiloTendencia() && _t2TendenciaHiLo != BAIXA) 
      return false;
   if (getT3GraficoExtra() && getT3HiloTendencia() && _t3TendenciaHiLo != BAIXA) 
      return false;
      
   if (getT1SRTendencia() && _t1TendenciaSR != BAIXA)
      return false;
   if (getT2GraficoExtra() && getT2SRTendencia() && _t2TendenciaSR != BAIXA)
      return false;
   if (getT3GraficoExtra() && getT3SRTendencia() && _t3TendenciaSR != BAIXA)
      return false;

   if (_tamanhoLinhaTendencia >= 3 && t1VelaAnterior.tipo == VENDEDORA)
      posicaoLTA = autoTrend.posicaoLTA(ChartID(), t1VelaAtual.tempo) - getLTExtra();
   else
      return false;
   if (posicaoLTA > 0 && _precoVenda < posicaoLTA && posicaoLTA >= t1VelaAtual.minima && posicaoLTA <= t1VelaAtual.maxima && _precoVenda < t1VelaAnterior.minima)
      posicaoStop = pegarPosicaoStop(VENDIDO);
   else
      return false;
   if (inicializarVenda(_precoVenda, posicaoStop)) {
      autoTrend.limparLinha(ChartID());
      ultimaLT = t1VelaAtual.tempo;
      return true;
   }
   return false;
}


bool LadinoEntrada::executarAumento(SINAL_POSICAO tendencia, double volume) {
   double sl = 0;
   double stopLoss = pegarPosicaoStop(tendencia);
   if (tendencia == COMPRADO)
      sl = (_precoCompra - stopLoss) + getAumentoStopExtra();
   else if (tendencia == VENDIDO)
      sl = (stopLoss - _precoVenda) + getAumentoStopExtra();
   
   double volumeLocal = volume;
   if (getGestaoRisco() == RISCO_PROGRESSIVO) {
      double precoSR = 0;
      if (tendencia == COMPRADO)
         precoSR = _precoCompra + sl;
      else if (tendencia == VENDIDO)
         precoSR = _precoVenda - sl;
      double pontos = this.posicaoPontoEmAberto(precoSR);
      volumeLocal = MathFloor(pontos / sl);
   }
   if (volumeLocal > 0) {
      if (tendencia == COMPRADO) {
         if (aumentarCompra(volumeLocal, _precoCompra, sl)) {
            autoTrend.limparLinha(ChartID());
            ultimaLT = t1VelaAtual.tempo;
            if (getGestaoRisco() == RISCO_PROGRESSIVO) {
               double volumeTP = MathAbs(this.getVolume());
               this.venderTP(volumeTP, _precoCompra + 100);
            }
            return true;
         }
      }
      else if (tendencia == VENDIDO) {
         if (aumentarVenda(volumeLocal, _precoVenda, sl)) {
            autoTrend.limparLinha(ChartID());
            ultimaLT = t1VelaAtual.tempo;
            if (getGestaoRisco() == RISCO_PROGRESSIVO) {
               double volumeTP = MathAbs(this.getVolume());
               this.comprarTP(volumeTP, _precoVenda - 100);
            }
            return true;
         }
      }
   }
   else 
      ultimaLT = t1VelaAtual.tempo;
   return false;
}


void LadinoEntrada::verificarRompimentoLTB() {
   //if (_trade.getPosicaoAtual() == COMPRADO && t1TendenciaSR == ALTA && negociacaoAtual == ALTA && tamanhoLinhaTendencia >= 3) {
   if (this.getPosicaoAtual() == COMPRADO && _negociacaoAtual == ALTA && _tamanhoLinhaTendencia >= 3) {
      double posicaoLTB = autoTrend.posicaoLTB(ChartID(), t1VelaAtual.tempo);
      if (posicaoLTB > 0 && _precoCompra > posicaoLTB && posicaoLTB >= t1VelaAtual.minima && posicaoLTB <= t1VelaAtual.maxima && _precoCompra > t1VelaAnterior.maxima) {
         executarObjetivo(this.getPosicaoAtual());
      }
   }
}

void LadinoEntrada::verificarRompimentoLTA() {
   //if (_trade.getPosicaoAtual() == VENDIDO && t1TendenciaSR == BAIXA && negociacaoAtual == BAIXA && tamanhoLinhaTendencia >= 3) {
   if (this.getPosicaoAtual() == VENDIDO && _negociacaoAtual == BAIXA && _tamanhoLinhaTendencia >= 3) {
      double posicaoLTA = autoTrend.posicaoLTA(ChartID(), t1VelaAtual.tempo);
      if (posicaoLTA > 0 && _precoVenda < posicaoLTA && posicaoLTA >= t1VelaAtual.minima && posicaoLTA <= t1VelaAtual.maxima && _precoVenda < t1VelaAnterior.minima) {
         executarObjetivo(this.getPosicaoAtual());
      }
   }
}


bool LadinoEntrada::verificarEntrada() {

   if(Bars(_Symbol,_Period)<100)
      return false;
    
   atualizarPreco();
      
   carregarVelaT1();
   carregarVelaT2();
   carregarVelaT3();

   if(t1NovaVela)
      tentativaCandle = false;
   if (tentativaCandle)
      return false;

   if(t1NovaVela) {
      atualizarSR(ALTA);
      SINAL_TENDENCIA tendencia = t1hilo.tendenciaAtual();
      if (tendencia != _t1TendenciaHiLo) {
         if (getCondicaoEntrada() == HILO_CRUZ_MM_T1_TICK || getCondicaoEntrada() == HILO_CRUZ_MM_T1_FECHAMENTO) {
            _negociacaoAtual = INDEFINIDA;
            atualizarNegociacaoAtual();
         }
         _t1TendenciaHiLo = tendencia;
      }
   }

   // De acordo com cruzamento de média no HiLo
   if (t2NovaVela) {
      SINAL_TENDENCIA tendencia = t2hilo.tendenciaAtual();
      if (tendencia != _t2TendenciaHiLo) {
         if (getCondicaoEntrada() == HILO_CRUZ_MM_T2_TICK || getCondicaoEntrada() == HILO_CRUZ_MM_T2_FECHAMENTO) {
            _negociacaoAtual = INDEFINIDA;
            atualizarNegociacaoAtual();
         }
         _t2TendenciaHiLo = tendencia;
      }
   }
   if (t3NovaVela) {
      SINAL_TENDENCIA tendencia = t3hilo.tendenciaAtual();
      if (tendencia != _t3TendenciaHiLo) {
         if (getCondicaoEntrada() == HILO_CRUZ_MM_T3_TICK || getCondicaoEntrada() == HILO_CRUZ_MM_T3_FECHAMENTO) {
            _negociacaoAtual = INDEFINIDA;
            atualizarNegociacaoAtual();
         }
         _t3TendenciaHiLo = tendencia;
      }
   }

   if (getCondicaoEntrada() == HILO_CRUZ_MM_T1_TICK) {
      double mm = pegarMMT1();
      string nome = "arrow_" + TimeToString(t1VelaAtual.tempo);
      if (comprarCruzouHiLo(_t1TendenciaHiLo, _Period, t1VelaAtual, t1VelaAnterior, mm)) {
         ObjectCreate(ChartID(), nome, OBJ_ARROW_UP, 0, t1VelaAtual.tempo, _precoCompra);
         ObjectSetInteger(ChartID(), nome, OBJPROP_COLOR, clrLimeGreen); 
      }
      if (venderCruzouHiLo(_t1TendenciaHiLo, _Period, t1VelaAtual, t1VelaAnterior, mm)) {
         ObjectCreate(ChartID(), nome, OBJ_ARROW_DOWN, 0, t1VelaAtual.tempo, _precoVenda);
         ObjectSetInteger(ChartID(), nome, OBJPROP_COLOR, clrRed); 
      }
   }   
   else if (getCondicaoEntrada() == HILO_CRUZ_MM_T2_TICK) {
      double mm = pegarMMT2();
      string nome = "arrow_" + TimeToString(t2VelaAtual.tempo);
      if (comprarCruzouHiLo(_t2TendenciaHiLo, getT2TempoGrafico(), t2VelaAtual, t2VelaAnterior, mm)) {         
         //ObjectCreate(t2chartid, nome, OBJ_ARROW_UP, 0, t2VelaAtual.tempo, _precoCompra);
         //ObjectSetInteger(t2chartid, nome, OBJPROP_COLOR, clrLimeGreen); 
         t2DesenharSetaCima(t2VelaAtual.tempo, _precoCompra);
      }
      if (venderCruzouHiLo(_t2TendenciaHiLo, getT2TempoGrafico(), t2VelaAtual, t2VelaAnterior, mm)) {
         //ObjectCreate(t2chartid, nome, OBJ_ARROW_DOWN, 0, t2VelaAtual.tempo, _precoVenda);
         //ObjectSetInteger(t2chartid, nome, OBJPROP_COLOR, clrRed); 
         t2DesenharSetaBaixo(t2VelaAtual.tempo, _precoVenda);
      }
   }
   else if (getCondicaoEntrada() == HILO_CRUZ_MM_T3_TICK) {
      double mm = pegarMMT3();
      string nome = "arrow_" + TimeToString(t3VelaAtual.tempo);
      if (comprarCruzouHiLo(_t3TendenciaHiLo, getT3TempoGrafico(), t3VelaAtual, t3VelaAnterior, mm)) {
         //ObjectCreate(t3chartid, nome, OBJ_ARROW_UP, 0, t3VelaAtual.tempo, _precoCompra);
         //ObjectSetInteger(t3chartid, nome, OBJPROP_COLOR, clrLimeGreen); 
         t3DesenharSetaCima(t3VelaAtual.tempo, _precoCompra);
      }
      if (venderCruzouHiLo(_t3TendenciaHiLo, getT3TempoGrafico(), t3VelaAtual, t3VelaAnterior, mm)) {
         //ObjectCreate(t3chartid, nome, OBJ_ARROW_DOWN, 0, t3VelaAtual.tempo, _precoVenda);
         //ObjectSetInteger(t3chartid, nome, OBJPROP_COLOR, clrRed); 
         t3DesenharSetaBaixo(t3VelaAtual.tempo, _precoCompra);
      }
   }
   else if (getCondicaoEntrada() == HILO_CRUZ_MM_T1_FECHAMENTO && t1NovaVela) {
      double mm = pegarMMT1();
      string nome = "arrow_" + TimeToString(t1VelaAtual.tempo);
      if (comprarCruzouHiLo(_t1TendenciaHiLo, _Period, t1VelaAtual, t1VelaAnterior, mm)) {
         //ObjectCreate(ChartID(), nome, OBJ_ARROW_UP, 0, t1VelaAtual.tempo, _precoCompra);
         //ObjectSetInteger(ChartID(), nome, OBJPROP_COLOR, clrLimeGreen); 
         t1DesenharSetaCima(t1VelaAtual.tempo, _precoCompra);
      }
      if (venderCruzouHiLo(_t1TendenciaHiLo, _Period, t1VelaAtual, t1VelaAnterior, mm)) {
         //ObjectCreate(ChartID(), nome, OBJ_ARROW_DOWN, 0, t1VelaAtual.tempo, _precoVenda);
         //ObjectSetInteger(ChartID(), nome, OBJPROP_COLOR, clrRed); 
         t1DesenharSetaBaixo(t1VelaAtual.tempo, _precoVenda);
      }
   }
   else if (getCondicaoEntrada() == HILO_CRUZ_MM_T2_FECHAMENTO && t2NovaVela) {
      double mm = pegarMMT2();
      string nome = "arrow_" + TimeToString(t2VelaAtual.tempo);
      if (comprarCruzouHiLo(_t2TendenciaHiLo, getT2TempoGrafico(), t2VelaAtual, t2VelaAnterior, mm)) {
         //ObjectCreate(t2chartid, nome, OBJ_ARROW_UP, 0, t2VelaAtual.tempo, _precoCompra);
         //ObjectSetInteger(t2chartid, nome, OBJPROP_COLOR, clrLimeGreen); 
         t1DesenharSetaCima(t1VelaAtual.tempo, _precoCompra);
      }
      if (venderCruzouHiLo(_t2TendenciaHiLo, getT2TempoGrafico(), t2VelaAtual, t2VelaAnterior, mm)) {
         //ObjectCreate(t2chartid, nome, OBJ_ARROW_DOWN, 0, t2VelaAtual.tempo, _precoVenda);
         //ObjectSetInteger(t2chartid, nome, OBJPROP_COLOR, clrRed); 
         t2DesenharSetaBaixo(t2VelaAtual.tempo, _precoVenda);
      }
   }
   else if (getCondicaoEntrada() == HILO_CRUZ_MM_T3_FECHAMENTO && t3NovaVela) {
      double mm = pegarMMT3();
      string nome = "arrow_" + TimeToString(t3VelaAtual.tempo);
      if (comprarCruzouHiLo(_t3TendenciaHiLo, getT3TempoGrafico(), t3VelaAtual, t3VelaAnterior, mm)) {
         //ObjectCreate(t3chartid, nome, OBJ_ARROW_UP, 0, t2VelaAtual.tempo, _precoCompra);
         //ObjectSetInteger(t3chartid, nome, OBJPROP_COLOR, clrLimeGreen); 
         t3DesenharSetaCima(t3VelaAtual.tempo, _precoCompra);
      }
      if (venderCruzouHiLo(_t3TendenciaHiLo, getT3TempoGrafico(), t3VelaAtual, t3VelaAnterior, mm)) {
         //ObjectCreate(t3chartid, nome, OBJ_ARROW_DOWN, 0, t2VelaAtual.tempo, _precoVenda);
         //ObjectSetInteger(t3chartid, nome, OBJPROP_COLOR, clrRed); 
         t3DesenharSetaBaixo(t3VelaAtual.tempo, _precoVenda);
      }
   }
   else if (getCondicaoEntrada() == APENAS_TENDENCIA_T1) {
      comprarNaTendencia(t1VelaAtual, t1VelaAnterior);
      venderNaTendencia(t1VelaAtual, t1VelaAnterior);
   }
   else if (getCondicaoEntrada() == APENAS_TENDENCIA_T2) {
      comprarNaTendencia(t2VelaAtual, t2VelaAnterior);
      venderNaTendencia(t2VelaAtual, t2VelaAnterior);
   }
   else if (getCondicaoEntrada() == APENAS_TENDENCIA_T3) {
      comprarNaTendencia(t3VelaAtual, t3VelaAnterior);
      venderNaTendencia(t3VelaAtual, t3VelaAnterior);
   }
   
   if (t1NovaVela && getT1LinhaTendencia())
      desenharLinhaTendencia();

   iniciandoExecucaoCompra();
   iniciandoExecucaoVenda();
   
   //ObjectSetString(0, labelPosicaoAtual, OBJPROP_TEXT, labelPosicaoAtualTexto + "0.00");
   //ObjectSetString(0, labelPosicaoGeral, OBJPROP_TEXT, labelPosicaoGeralTexto +  + StringFormat("%.2f", _trade.precoAtual()));
   inicializarPosicao();
   
   return false;
}
