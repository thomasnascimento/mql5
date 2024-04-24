//+------------------------------------------------------------------+
//|                                           tns_basic_ea_v1.00.mq5 |
//|                                       Thomas Nascimento da Silva |
//|                       https://www.instagram.com/_thomnascimento/ |
//+------------------------------------------------------------------+
#property copyright   "Thomas Nascimento da Silva"
#property link        "https://www.instagram.com/_thomnascimento/"
#property version     "1.00"
#property description "Última atualização em 24/04/2024"


//+------------------------------------------------------------------+
//| Imports and includes                                             |
//+------------------------------------------------------------------+
  //Import: Funções são importadas a partir de módulos MQL5 compilados (arquivos *.ex5) e a partir de módulos do sistema operacional (arquivos *.dll).
  //Include: Realiza a inclusão de arquivos.
#include <Trade/SymbolInfo.mqh> //Classe para facilitar o acesso às propriedades do símbolo (ativo).
#include <Trade/Trade.mqh>      //Classe para facilitar o acesso às funções de negociação.

CSymbolInfo simbolo;
CTrade      trade;


//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
  //Dados do tipo enum pertencem a um determinado conjunto limitado de dados.
  //A lista de valores é uma lista de identificadores de constantes nomeados separados por vírgulas.
  
  //Enum referente ao tipo de ordem (compra ou venda)
enum ENUM_LADO
  {
   COMPRA, //Compra
   VENDA   //Venda
  };
  
  
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
  //A classe de armazenamento input define uma variável externa.
input ENUM_LADO Lado        = COMPRA; //Lado da ordem permitido
input double    Volume      = 0.0;    //Tamanho da posição (0=volume mínimo)
input double    Entrada     = 0.0;    //Preço de entrada na operação
input double    Stop_loss   = 0.0;    //Stop loss em pontos (0=OFF)
input double    Take_profit = 0.0;    //Take profit em pontos (0=OFF)
  
  
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
  //Variáveis globais são criadas colocando suas declarações fora de descrições da função.
double Volume_minimo;
double Volume_step;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
  //A função é projetada para inicialização de um programa MQL5 em execução.
int OnInit()
  {
   //Verificando se o ativo foi carregado corretamente no gráfico.
   if(!simbolo.Name(_Symbol))
     {
      Print("Erro ao carregar o ativo.");
      return INIT_FAILED;
     }
     
   //Inicializando as variáveis
   SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN, Volume_minimo); //Volume mínimo permitido
   SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP, Volume_step);  //Variação mínima permitida no volume
     
   Print("Algoritmo carregado com sucesso.");
   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
  //A função é projetada para desinicialização de um programa MQL5 em execução.
void OnDeinit(const int reason)
  {
   printf("Reiniciando EA: %d", reason);
  }
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
  //Função é chamada em EAs quando ocorre o evento NewTick para processar uma nova cotação.
void OnTick()
  {
   //Atualizando os dados de cotação do ativo
   if(!simbolo.RefreshRates()) return;
   
   //Verificando se há alguma posição em aberto
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      PositionSelectByTicket(PositionGetTicket(i));
      
      //Caso esteja posicionado, não prosegue com o restante do script
      if(PositionGetString(POSITION_SYMBOL) == _Symbol) return;
     }
     
   //Verificando se há alguma ordem em aberto
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(OrderSelect(OrderGetTicket(i)))
        {
         //Caso haja ordem em aberto, não prosegue com o restante do script
         if(OrderGetString(ORDER_SYMBOL) == _Symbol) return;
        }
     }
   
   //Normalizando o volume
   double volume = floor((floor(Volume * 100) / 100) / Volume_step) * Volume_step;
      
   if(volume < Volume_minimo) volume = Volume_minimo;
   
   //Envio de ordem stop e caso dê algum erro é enviado uma ordem limit em seguida
   if(Lado == COMPRA)
     {
      if(!trade.BuyStop(volume, simbolo.NormalizePrice(Entrada), _Symbol, simbolo.NormalizePrice(Entrada - Stop_loss), simbolo.NormalizePrice(Entrada + Take_profit)))
        trade.BuyLimit(volume, simbolo.NormalizePrice(Entrada), _Symbol, simbolo.NormalizePrice(Entrada - Stop_loss), simbolo.NormalizePrice(Entrada + Take_profit));
     }
     
   else
     {
      if(!trade.SellStop(volume, simbolo.NormalizePrice(Entrada), _Symbol, simbolo.NormalizePrice(Entrada + Stop_loss), simbolo.NormalizePrice(Entrada - Take_profit)))
        trade.SellLimit(volume, simbolo.NormalizePrice(Entrada), _Symbol, simbolo.NormalizePrice(Entrada + Stop_loss), simbolo.NormalizePrice(Entrada - Take_profit));
     }
  }
