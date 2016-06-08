;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     The agents and attributes      ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [Producers Producer]
breed [Distributors Distributor]
breed [STS STSs]
breed [Consumers Consumer]

Producers-own [cooperative-actionP Categoria TocaMoverloPD TakeBackSystem GlobalLocal ResourcesP punishments] 
Distributors-own [cooperative-actionD Categoria TocaMoverloPD TakeBackSystem GlobalLocal] 
Consumers-own [WEEEInConsumer TocaMoverlo IDelivered MainInterest MoneyReceived DeliverRandom PosibleChangeOfMind RandomDifus]
STS-own [TakeBackSystem WEEEinSTS ResourcesBag CollectionCounter 
  ResourcesBagBeforeDelivering Active SEP ConsumersClose WEEENotCollected]
patches-own [coopNeeded potentialCoopStability potentialImpact fullness]

Globals [STSToReceive ConsumerCloseToSTStoReceive STSToReceiveWithMoney STSToReceiveWithSEP TickWithoutDelivering                    ;;global variables
  EntregadosEnElTick EntregadosAntesDelTick 
  STS4Properties STS5Properties STS8Properties STS12Properties STS13Properties STS14Properties
  SumCooperativeACtionProducers SumCooperativeACtionDistributors RecyclerContract 
  WEEECollected DeliveringOrNotInTheDay Collection Potential-Contamination 
  DeliveringOrNotInTheMonth UnitsDelivered WEEEStock CrearConsumers deliver
  p d ReportResources Alliance WEEEDelivered UnitsCollected CostPunishment
  STSFull CountingTicks RecordCollection30 WEEEEntregadosSTS4 WEEEEntregadosSTS5 WEEEEntregadosSTS8
  Penalties WEEESTS4AlIniciarTick WEEESTS5AlIniciarTick WEEESTS8alIniciarTick
  SumWEEEInConsumers SumWEEEInConsumersInitial ResourcesBagInSTSInitial
  ConsumerClose1 ConsumerClose2 ConsumerClose3 ConsumerClose4 MoneyInInterest1 MoneyInInterest2 MoneyInInterest3 MoneyInInterest4
  CooperativeACtionProducerSystem1 CooperativeACtionDistributorSystem1
  CooperativeACtionProducerSystem2 CooperativeACtionDistributorSystem2
  CooperativeACtionProducerSystem3 CooperativeACtionDistributorSystem3 PotentialPolutionCause CAPGap MaxGapCAPPD PosibleCausa acumulated
  potencialcontaminacionNotDelivering WEEEnotdelivered potencialcontaminacionNotCollection
  WEEECollectedInSTS4 WEEECollectedInSTS5 activeRandom ReporterPenalties 
  potencialcontaminacionNotDeliveringSTS4 potencialcontaminacionNotDeliveringSTS5]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Setup      ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
to setup
  clear-all
  reset-ticks
  Creation-Producers
  Creation-Distributors
  GlobalLocalArea
  InitialMotivation
end  

to Creation-Producers                                                        
     create-Producers 2                                      ;; 1 a 1 con 3 STS
      [set Categoria "P" set ResourcesP 100 setxy (8 + random 6) (8 + random 7) set shape "person student"
        set size 2 set label categoria set punishments  0]
     ask Producers [set cooperative-actionP 45 + random-float 10]    ; Initial Motivation according to the mobilization of actor-networks 
     ask producer 0 [set TakeBackSystem 1 set color grey - 1 set label Categoria set CooperativeACtionProducerSystem1 cooperative-actionP]
     ask producer 1 [set TakeBackSystem 2 set color red + 1 set label Categoria set CooperativeACtionProducerSystem2 cooperative-actionP] 
end

to Creation-Distributors
    Create-Distributors 2 [set Categoria "D" setxy (-12 + random 4) (8 + random 9) set shape "person business" set size 2  
    ask Distributor 2 [set TakeBackSystem 1 set color grey - 1 set label Categoria]
    ask Distributor 3 [set TakeBackSystem 2 set color red + 1 set label Categoria]
    ask Distributors [set cooperative-actionD 45 + random-float 10]]                 ;; Initial Motivation according to the mobilization of actor-networks
end

to GlobalLocalArea                                                                     ;; display of motivation to cooperate in producers and distributors
  ask patches [set pcolor grey + 2]
  ask patches with [pxcor < min-pxcor + 17 and pycor > min-pycor + 25] [ set pcolor black]
  ask patches with [pycor < min-pycor + 25] [ set pcolor black]
  ask patches [if pcolor = grey + 2 and pycor = 9
        [while [pcolor = grey + 2] [set pcolor yellow - 1]]]
end

to InitialMotivation
     ask Producers [ifelse Cooperative-Actionp >= 70 [set GlobalLocal 1 setxy (8 + random 6) (10 + random 5)]
          [set GlobalLocal 0 setxy (-8 + random 6) (11 + random 5)]
     if any? other producers-here [set TocaMoverloPD 1 find-new-PD]]
     ask Distributors [ifelse Cooperative-ActionD >= 70 [set GlobalLocal 1 setxy (8 + random 6) (10 + random 5)]
          [set GlobalLocal 0 setxy (-8 + random 6) (11 + random 5)]
     if any? other producers-here [set TocaMoverloPD 1 find-new-PD]]
end

to find-new-PD              ; just in case two agents are located in the same patch
ask producers with [TocaMoverloPD = 1 ] [
  if any? other producers-here or any? other distributors-here [
  forward random-float 2 
  find-new-PD]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     The PCP design and implementation      ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to STSImplementation    
  create-STS 2
  ask STS [setxy (1 + random 29) (6 + random -20) set shape "box" set size 2 set Active "Yes" 
      set WEEEinSTS 0 set UnitsDelivered 0 set CollectionCounter 0 if SEP = 1 [set color green]                                
     set ConsumersClose []                  
      if any? other STS-here [find-new-spot-STS]]
  if Inc$-Posc1 [ask Producer 0 [set ResourcesP ResourcesP - 10]]
  if Inc$-Posc2 [ask Producer 1 [set ResourcesP ResourcesP - 10]]
  ask STSs 4 [set color grey - 1 set TakeBackSystem 1 set label TakeBackSystem set label-color grey + 3 if PSA-Posc1  [set SEP 1]
      if Inc$-Posc1 [set ResourcesBag 10] set WEEECollectedInSTS4 0]
  ask STSs 5 [set color red + 1 set TakeBackSystem 2 set label TakeBackSystem set label-color red + 1 if PSA-Posc2 [set SEP 1]
    if Inc$-Posc2 [set ResourcesBag 10] set WEEECollectedInSTS5 0]
  set ResourcesBagInSTSInitial sum [resourcesBag] of STS
  set CrearConsumers 1
  Creation-Consumers
  set Collection 0 set Potential-Contamination 0 set STSFull 0 set CountingTicks 0 set TickWithoutDelivering 0 set PotentialPolutionCause 0
end

to find-new-spot-STS         ; just in case two agents are located in the same patch
  ask STS [if any? other STS-here [setxy (1 + random 29) (6 + random -20)
  find-new-spot-STS]]
end
  
to Creation-Consumers
  if CrearConsumers = 1 [
    create-Consumers 161
    ask Consumers [set WEEEInConsumer 5 set color red set shape "person" set size 1  
      setxy (0 + random 32) (7 + random -22) set IDelivered 0 set MoneyReceived 0
      set TocaMoverlo 0 set PosibleChangeOfMind 0                  
      if any? other consumers-here [set TocaMoverlo 1 find-new-STS]
      set CrearConsumers 0]]
  set SumWEEEInConsumersInitial sum [WEEEInConsumer] of consumers 
  let InterestInCloseness count Consumers * 0.067
  let InterestInMoney count Consumers * 0.167
  let InterestInSEP count Consumers * 0.659
  let InterestInInfo count Consumers * 0.107
  ask n-of InterestInCloseness Consumers with [color = red] [set MainInterest 1 set color green - 2]
  ask n-of InterestInMoney Consumers with [color = red] [set MainInterest 2 set color green - 2.5]
  ask n-of InterestInSEP Consumers with [color = red] [set MainInterest 3 set color green - 1]
  ask n-of InterestInInfo Consumers with [color = red] [set MainInterest 4 set color green - 3]
  ask consumers with [color = red] [set MainInterest 2 set color green - 2.5] ;classify those which are still red as white; rounding errors
  set WEEEnotdelivered 0
end

to find-new-spot-consumer      ; just in case two agents are located in the same patch
  ask consumers [if any? other consumers-here or any? other STS-here [
  setxy (0 + random 32) (6 + random -20)  
  find-new-spot-consumer]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     The collection and cooperation dynamics     ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to STSDynamics
  ask sts [if OrigenDeLaCooperacion = "Sin Regulacion" [set activeRandom random 2 ifelse activeRandom = 0 [ set active "Yes"] [ set active "Not"]]] 
  ConsumersDelivering
  PotentialPunishment
  Satisfaction
  PotentialPolution
  Movement-PD
  tick
end

to ConsumersDelivering
    set EntregadosEnElTick 0
    CheckSTSProperties
    ask Consumers [set IDelivered 0 
       let STSClose count neighbors with [any? STS-here with [Active = "Yes"]] ;show word "hay STS " STSClose 
       ifelse STSClose = 1 [set STStoReceive [who] of (STS-on neighbors)
         ;show word "ststoreceive " STSToReceive
         ask STSs item 0 STStoReceive [set ConsumerCloseToSTStoReceive [who] of (consumers-on neighbors)
         ;show word "ConsumerCloseToSTStoReceive " ConsumerCloseToSTStoReceive
         ]] [set STStoReceive 0] ;show word "STSCerca " STStoReceive show word "consumerCErca " ConsumerCloseToSTStoReceive 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Post-consumption program (PCP) 1   ;;;;;;;;;;;;;;;;;;;;;;
       if STStoReceive = [4] [                                                                                                                  ;; PCP 1
           set WEEESTS4AlIniciarTick 0 + [WEEEinSTS] of STSs 4                                                                     
           ask STSs 4 [ set EntregadosAntesDelTick 0 + [WEEEinSTS] of STSs 4
             ifelse item 2 STS4Properties = 1 [           ;;is it active?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there is 1 consumer close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 1 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                            ;; consumer 1/1                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]] 
                      set IDelivered 1 set EntregadosEnElTick EntregadosEnElTick + 1]
                     [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [               ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                              ;; consumer 1/1
                 ask STSs 4 [set WEEEEntregadosSTS4 count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS4]
                 ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                     ;; end of "if there is 1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 2 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 2 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                            ;; consumer 1/2                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [             ;; >5$ in ResourcesBag
                          set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                          ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                          set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                              ;; consumer 1/2
               ask consumer item 1 ConsumerCloseToSTStoReceive [                                                              ;; consumer 2/2                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                             ;; consumer 2/2
                  ask STSs 4 [set WEEEEntregadosSTS4  count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS4]
                  ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                  ;; end of "if there are 2"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 3 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 3 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                           ;; consumer 1/3                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                              ;; consumer 1/3
               ask consumer item 1 ConsumerCloseToSTStoReceive [                                                              ;; consumer 2/3                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                              ;; consumer 2/3
               ask consumer item 2 ConsumerCloseToSTStoReceive [                                                              ;; consumer 3/3                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                              ;; consumer 3/3
                 ask STSs 4 [set WEEEEntregadosSTS4  count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS4]
                 ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                    ;; end of "if there are 3"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 4 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 4 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                            ;; consumer 1/4                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                              ;; consumer 1/4
                ask consumer item 1 ConsumerCloseToSTStoReceive [                                                             ;; consumer 2/4                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 2/4
               ask consumer item 2 ConsumerCloseToSTStoReceive [                                                               ;; consumer 3/4                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 3/4
               ask consumer item 3 ConsumerCloseToSTStoReceive [                                                               ;; consumer 4/4                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 4/4
                 ask STSs 4 [set WEEEEntregadosSTS4  count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS4]
                 ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                    ;; end of "if there are 4"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 3 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 5 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                             ;; consumer 1/5                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 1/5
               ask consumer item 1 ConsumerCloseToSTStoReceive [                                                               ;; consumer 2/5                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 2/5
               ask consumer item 2 ConsumerCloseToSTStoReceive [                                                               ;; consumer 3/5                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 3/5
               ask consumer item 3 ConsumerCloseToSTStoReceive [                                                               ;; consumer 4/5                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 4/5
               ask consumer item 4 ConsumerCloseToSTStoReceive [                                                               ;; consumer 5/5                     
                   ifelse item 0 STS4Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                  ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS4Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [              ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 4 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                           ;; closeness
                           ifelse not PSA-Posc1 and not Inc$-Posc1 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                               ;; interested in info
                           if DifusPosc1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 4 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 4 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 5/5
                ask STSs 4 [set WEEEEntregadosSTS4  count consumers with [IDelivered = 1]
                  set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS4]
                ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                           ;; end "if there are 5" 
               ][]   ;; end "if it is active"
            ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    SATISFACTION PCP 1   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ask producers with [TakeBacksystem = 1][
            if WEEESTS4AlIniciarTick < WEEESTS4AlIniciarTick + WEEEEntregadosSTS4 [   ;;;;;;; MOTIVACION AL RECIBIR WEEE en STS  ;;;;;;;;    
               ifelse Inc$-Posc1 [ifelse Cooperative-ActionP + WEEEEntregadosSTS4 >= 100 [set Cooperative-ActionP 100]
                 [set Cooperative-ActionP Cooperative-ActionP + WEEEEntregadosSTS4]]
                    [ifelse Cooperative-ActionP + WEEEEntregadosSTS4 >= 100 [set Cooperative-ActionP 100]
                      [set Cooperative-ActionP Cooperative-ActionP + WEEEEntregadosSTS4]]
               ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set ResourcesP ResourcesP + (WEEEEntregadosSTS4 * 0.5)]
               [set ResourcesP ResourcesP + WEEEEntregadosSTS4]]      ;;;;;;; 1 $ PER EACH WEEE DELIVERED - STRENGHT. BRAND  ;;;;;;;;;;para el es mas importante posicionar marca q cumplir ley
                                                                        ;;;;;;; APORTAR DE NUEVO PLATA AL STS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ifelse [resourcesBag] of STSs 4 <= 5 and Inc$-Posc1 and [Cooperative-ActionP] of producer 0 > 20 
                [set resourcesp resourcesp - 10 ask STSs 4 [set resourcesBag resourcesBag + 10]]
                [if [resourcesBag] of STSs 4 <= 5 and Inc$-Posc1 and [Cooperative-ActionP] of producer 0 > 20 and OrigenDeLaCooperacion = "Sin Regulacion"
                 [set resourcesp resourcesp - 2 ask STSs 4 [set resourcesBag resourcesBag + 2]]]
               ]
           ask distributors with [TakeBacksystem = 1][                   ;;;;;;; DESMOTIVACION AL NO RECIBIR WEEE ;;;;;;;;;;;;;;;;;;;;;;;  CHEQUEAR CON OTROS SISTEMAS IMPLEMENTADOS
             ifelse WEEEEntregadosSTS4 = 0 and ticks >= 24 [set Cooperative-ActionD Cooperative-ActionD - 0.2  ;;; 3 meses aprendizaje;;;
             ][ifelse Cooperative-ActionD + (WEEEEntregadosSTS4 * 2) >= 100 [set Cooperative-ActionD 100]
                   [set Cooperative-ActionD Cooperative-ActionD + (WEEEEntregadosSTS4 * 2)] ;;;;;;; MOTIVACION AL RECIBIR WEEE ;;;;;;;;;;;;;;;
             ]]]                                                                                                                                                   ;SYSTEM1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Post-consumption program (PCP) 2   ;;;;;;;;;;;;;;;;;;;;;;
       if STStoReceive = [5] [                                                                                                                  ;; PCP 2
           set WEEESTS5AlIniciarTick 0 + [WEEEinSTS] of STSs 5
           set EntregadosAntesDelTick 0                                                                      
           ask STSs 5 [ set EntregadosAntesDelTick 0 + [WEEEinSTS] of STSs 5
             ifelse item 2 STS5Properties = 1 [                                                                  ;; is it active?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there is 1 consumer close   ;;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 1 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                            ;; consumer 1/1                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]] 
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                     [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [             ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                         ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                             ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 1/1
                 ask STSs 5 [set WEEEEntregadosSTS5 count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS5]
                 ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                     ;; end of "if there are 1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 2 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 2 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                             ;; consumer 1/2                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                          set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                          ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                          set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                         ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                             ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 1/2
               ask consumer item 1 ConsumerCloseToSTStoReceive [                                                               ;; consumer 2/2                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [            ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                         ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                             ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                               ;; consumer 2/2
                  ask STSs 5 [set WEEEEntregadosSTS5 count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS5]
                  ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                  ;; end of "if there are 2"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 3 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 3 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                             ;; consumer 1/3                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                ;;there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [            ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                         ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                             ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                ;; consumer 1/3
               ask consumer item 1 ConsumerCloseToSTStoReceive [                                                                ;; consumer 2/3                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [            ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                         ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                             ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                 ;; consumer 2/3
               ask consumer item 2 ConsumerCloseToSTStoReceive [                                                                 ;; consumer 3/3                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [                ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [            ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                         ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                             ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                 ;; consumer 3/3
                 ask STSs 5 [set WEEEEntregadosSTS5 count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS5]
                 ask consumers with [IDelivered = 1] [set IDelivered 0]]                                                   ;; end of "if there are 3"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 4 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 4 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                               ;; consumer 1 de 4                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;;there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1 set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                  ;; consumer 1/4
                ask consumer item 1 ConsumerCloseToSTStoReceive [                                                                 ;; consumer 2/4                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                 ;; consumer 2/4
               ask consumer item 2 ConsumerCloseToSTStoReceive [                                                                 ;; consumer 3/4                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;;>5$ en ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                ;; consumer 3/4
               ask consumer item 3 ConsumerCloseToSTStoReceive [                                                                ;; consumer 4/4                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                ;; consumer 4/4
                 ask STSs 5 [set WEEEEntregadosSTS5 count consumers with [IDelivered = 1]
                   set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS5]
                 ask consumers with [IDelivered = 1] [set IDelivered 0]]                                        ;; end of "if there are 4"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   if there are 5 consumers close ;;;;;;;;;;;;;;;;;;;;
               if length ConsumerCloseToSTStoReceive = 5 [                                                       
                 ask consumer item 0 ConsumerCloseToSTStoReceive [                                                               ;; consumer 1/5                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; intested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                 ;; consumer 1/5
               ask consumer item 1 ConsumerCloseToSTStoReceive [                                                                 ;; consumer 2/5                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;; there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; intested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                ;; consumer 2/5
               ask consumer item 2 ConsumerCloseToSTStoReceive [                                                                ;; consumer 3/5                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;;there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                ;; consumer 3/5
               ask consumer item 3 ConsumerCloseToSTStoReceive [                                                                ;; consumer 4/5                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;;there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]]]]]                                 ;; consumer 4/5
               ask consumer item 4 ConsumerCloseToSTStoReceive [                                                                 ;; consumer 5/5                     
                   ifelse item 0 STS5Properties = 1 and MainInterest = 3 and WEEEinConsumer > 0 [               ;;there is SEP in STS
                      set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                      if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                      set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]
                      [ifelse item 1 STS5Properties = 1 and MainInterest = 2 and WEEEinConsumer > 0 [           ;; >5$ in ResourcesBag
                        set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 set MoneyReceived MoneyReceived + 1
                        ask STSs 5 [set ResourcesBag ResourcesBag - 1]
                        set IDelivered 1   set EntregadosEnElTick EntregadosEnElTick + 1]
                       [ifelse MainInterest = 1 and WEEEinConsumer > 0 [                                        ;; closeness 
                           ifelse not PSA-Posc2 and not Inc$-Posc2 [set DeliverRandom random 4][set DeliverRandom 1]
                           if DeliverRandom = 1 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1]]
                       [if MainInterest = 4 and WEEEinConsumer > 0 [                                            ;; interested in info
                           if DifusPosc2 [set WEEEinConsumer WEEEinConsumer - 1 set color green + 1 set size 1.3 
                           if [ResourcesBag] of STSs 5 > 0 [set MoneyReceived MoneyReceived + 1
                              ask STSs 5 [set ResourcesBag ResourcesBag - 1]]
                           set IDelivered 1  set EntregadosEnElTick EntregadosEnElTick + 1] ]]]]]                                ;; consumer 5/5
                ask STSs 5 [set WEEEEntregadosSTS5 count consumers with [IDelivered = 1]
                  set WEEEInSTS WEEEInSTS + WEEEEntregadosSTS5]
                ask consumers with [IDelivered = 1] [set IDelivered 0]]]                                        ;; end "if there are 5"  
             []]    ;NO ACTIVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   SATISFACTION PCP  2   ;;;;;;;;;;;;;;;;;;;;;;;;;;
         ask producers with [TakeBacksystem = 2][
            if WEEESTS5AlIniciarTick < WEEESTS5AlIniciarTick + WEEEEntregadosSTS5 [                             ;; Motivation when receive WEEE   
               ifelse Inc$-Posc2 [ifelse Cooperative-ActionP + WEEEEntregadosSTS5 >= 100 [set Cooperative-ActionP 100]
                 [set Cooperative-ActionP Cooperative-ActionP + WEEEEntregadosSTS5]]
                    [ifelse Cooperative-ActionP + WEEEEntregadosSTS5 >= 100 [set Cooperative-ActionP 100]
                      [set Cooperative-ActionP Cooperative-ActionP + WEEEEntregadosSTS5]]
               ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set ResourcesP ResourcesP + (WEEEEntregadosSTS5 * 0.5)]
               [set ResourcesP ResourcesP + WEEEEntregadosSTS5]]                                                ;; 1 $ PER WEEE - STRENGHT.BRAND
            ifelse [resourcesBag] of STSs 5 <= 5 and Inc$-Posc1                                                 ;; additional $ to the PCP
            and [Cooperative-ActionP] of producer 1 > 20 
            [set resourcesp resourcesp - 10 ask STSs 5 [set resourcesBag resourcesBag + 10]]
            [if [resourcesBag] of STSs 5 <= 5 and Inc$-Posc1 
            and [Cooperative-ActionP] of producer 1 > 20 and OrigenDeLaCooperacion = "Sin Regulacion"
            [set resourcesp resourcesp - 2 ask STSs 5 [set resourcesBag resourcesBag + 2]]]]
           ask distributors with [TakeBacksystem = 2][                                                          ;; DESMOTIVACION AL NO RECIBIR WEEE
             ifelse WEEEEntregadosSTS5 = 0 and ticks >= 24 [set Cooperative-ActionD Cooperative-ActionD - 0.2   ;; 3 meses aprendizaje
             ][ifelse Cooperative-ActionD + (WEEEEntregadosSTS5 * 2) >= 100 [set Cooperative-ActionD 100]
                   [set Cooperative-ActionD Cooperative-ActionD + (WEEEEntregadosSTS5 * 2)]                     ;; MOTIVACION AL RECIBIR WEEE 
             ]]]]                                                                                               ;; end ask consumers end          ;; end PCP 2
   ask consumers [set MoneyInInterest1 sum [MoneyReceived] of consumers with [MainInterest = 1]
                  set MoneyInInterest2 sum [MoneyReceived] of consumers with [MainInterest = 2]
                  set MoneyInInterest3 sum [MoneyReceived] of consumers with [MainInterest = 3]     
                  set IDelivered 0
           ifelse DifusPosc1 and DifusPosc2 [set RandomDifus random 2                          ;; to force the movement of consumers towards the STS
           ifelse RandomDifus = 0 [let xSTS4 [xcor] of STSs 4 let ySTS4 [ycor] of STSs 4 
           setxy ((xSTS4 - 1) + random 2) ((ySTS4 - 1) + random 2)]
             [if RandomDifus = 1 [let xSTS5 [xcor] of STSs 5 let ySTS5 [ycor] of STSs 5 
               setxy ((xSTS5 - 1) + random 2) ((ySTS5 - 1) + random 2) find-new-spot-consumer]]]
              [ifelse DifusPosc2 and not DifusPosc1
                  [let xSTS5 [xcor] of STSs 5 let ySTS5 [ycor] of STSs 5 
                   setxy ((xSTS5 - 1) + random 2) ((ySTS5 - 1) + random 2) find-new-spot-consumer]
              [ifelse DifusPosc1 and not DifusPosc2
                  [let xSTS4 [xcor] of STSs 4 let ySTS4 [ycor] of STSs 4 
                   setxy ((xSTS4 - 1) + random 2) ((ySTS4 - 1) + random 2) find-new-spot-consumer]
              [setxy (0 + random 32) (7 + random -22) find-new-spot-consumer]]]]  
   set WEEEDelivered WEEEDelivered + EntregadosEnElTick
   CheckingStops
   plot-WEEEinSTS
   if EntregadosEnElTick = 0 [set TickWithoutDelivering TickWithoutDelivering + 1]
end

to find-new-STS               ; just in case there are more than one agent in the same patch
  ask consumers with [TocaMoverlo = 1 ] [if any? other consumers-here or any? other STS-here 
    [setxy (0 + random 32) (6 + random -20) 
      find-new-STS 
      SET TOCAMOVERLO 0]]
end

to CheckSTSProperties
         set STS4Properties []
         ifelse [Active] of STSs 4 = "Yes" [set STS4Properties fput 1 STS4Properties][set STS4Properties fput 0 STS4Properties]
         ifelse [ResourcesBag] of STSs 4 > 5 [set STS4Properties fput 1 STS4Properties][set STS4Properties fput 0 STS4Properties]
         ifelse [SEP] of STSs 4 = 1 [set STS4Properties fput 1 STS4Properties][set STS4Properties fput 0 STS4Properties]
         ;show word "p s1 " STS4Properties 
         set STS5Properties []
         ifelse [Active] of STSs 5 = "Yes" [set STS5Properties fput 1 STS5Properties][set STS5Properties fput 0 STS5Properties]
         ifelse [ResourcesBag] of STSs 5 > 5 [set STS5Properties fput 1 STS5Properties][set STS5Properties fput 0 STS5Properties]
         ifelse [SEP] of STSs 5 = 1 [set STS5Properties fput 1 STS5Properties][set STS5Properties fput 0 STS5Properties]
         ;show word "p s2 " STS5Properties 
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     Motivation changes and stops    ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to Satisfaction                                 ;;; if $ < un tope en funcion de si esta poniendo $ para inc o no
    ask producers with [TakeBackSystem = 1] [if Inc$-Posc1 [if resourcesP < 80 [set cooperative-actionP cooperative-actionP - 0.1]]]
    ask producers with [TakeBackSystem = 2] [if Inc$-Posc2 [if resourcesP < 80 [set cooperative-actionP cooperative-actionP - 0.1]]]
    set CooperativeACtionProducerSystem1 [cooperative-actionP] of producer 0
    set CooperativeACtionDistributorSystem1 [cooperative-actionD] of distributor 2
    set CooperativeACtionProducerSystem2 [cooperative-actionP] of producer 1
    set CooperativeACtionDistributorSystem2 [cooperative-actionD] of distributor 3
    ask producers [if cooperative-actionP >= 95 [set cooperative-actionP 95 + random 4]]
    ask distributors [if cooperative-actionD >= 95 [set cooperative-actionD 95 + random 4]]
    let CAPP []
    let CAPP0 [cooperative-actionP] of producer 0
    let CAPP1 [cooperative-actionP] of producer 1
    set CAPP fput CAPP0 CAPP
    set CAPP fput CAPP1 CAPP
    ;show word "CAPP  " CAPP 
    let CAPD []
    let CAPD3 [cooperative-actionD] of distributor 2
    let CAPD4 [cooperative-actionD] of distributor 3
    set CAPD fput CAPD3 CAPD
    set CAPD fput CAPD4 CAPD
    ;show word "CAPD  " CAPD
    ifelse abs (min CAPP - max CAPD) > abs (min CAPD - max CAPP) [
    set MaxGapCAPPD abs (min CAPP - max CAPD)][set MaxGapCAPPD abs (min CAPD - max CAPP)]
    ;show word "MaxGapCAPPD " MaxGapCAPPD 
    set CAPGap abs (sum [cooperative-actionD] of distributors / 2 - SUM [cooperative-actionP] of producers / 2) 
end

to CheckingStops
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   No more WEEE in consumers   ;;;;;;;;;;;;;;;;;;;;
   set SumWEEEInConsumers sum [WEEEInConsumer] of consumers 
   if SumWEEEInConsumers <= 10 [user-message "Agotado potencial de entrega de RAEE en consumidores" stop]
   ifelse not DifusPosc1 [
       ifelse ((PSA-Posc1 or PSA-Posc2) and (not Inc$-Posc1 and not Inc$-Posc2)) [
         set SumWEEEInConsumers (sum [weeeinconsumer] of consumers with [maininterest = 3] + sum [weeeinconsumer] of consumers with [maininterest = 1])
         if SumWEEEInConsumers <= 10 [set WEEEnotdelivered (sum [weeeinconsumer] of consumers with [maininterest = 2]
                                                          + sum [weeeinconsumer] of consumers with [maininterest = 4])  
                                    user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]
     [ifelse (not PSA-Posc1 and not PSA-Posc2) and (Inc$-Posc1 or Inc$-Posc2) [
                  set SumWEEEInConsumers (sum [weeeinconsumer] of consumers with [maininterest = 2]
                                 + sum [weeeinconsumer] of consumers with [maininterest = 1])
                  if SumWEEEInConsumers <= 10 [set WEEEnotdelivered (sum [weeeinconsumer] of consumers with [maininterest = 3]
                                                          + sum [weeeinconsumer] of consumers with [maininterest = 4])  
                  user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]
           [ifelse (not Inc$-Posc1 and not Inc$-Posc2) and (not PSA-Posc1 and not PSA-Posc2) [
                    set SumWEEEInConsumers sum [weeeinconsumer] of consumers with [maininterest = 1]
                    if SumWEEEInConsumers <= 10 [set WEEEnotdelivered (sum [weeeinconsumer] of consumers with [maininterest = 2]
                                                          + sum [weeeinconsumer] of consumers with [maininterest = 4]
                                                          + sum [weeeinconsumer] of consumers with [maininterest = 3])  
                    user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]
              [set SumWEEEInConsumers (sum [weeeinconsumer] of consumers with [maininterest = 1]
                                        + sum [weeeinconsumer] of consumers with [maininterest = 2]
                                        + sum [weeeinconsumer] of consumers with [maininterest = 3])
                    ;show SumWEEEInConsumers 
                    if SumWEEEInConsumers <= 10 [set WEEEnotdelivered sum [weeeinconsumer] of consumers with [maininterest = 4]  
                    user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]   
            ]]]
     [ifelse difusposc1 and difusposc2 [ifelse ((PSA-Posc1 or PSA-Posc2) and (not Inc$-Posc1 and not Inc$-Posc2)) [
         set SumWEEEInConsumers (sum [weeeinconsumer] of consumers with [maininterest = 3] + sum [weeeinconsumer] of consumers with [maininterest = 1]
                                 + sum [weeeinconsumer] of consumers with [maininterest = 4])
         if SumWEEEInConsumers <= 10 [set WEEEnotdelivered sum [weeeinconsumer] of consumers with [maininterest = 2]  
                                    user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]
     [ifelse (not PSA-Posc1 and not PSA-Posc2) and (Inc$-Posc1 or Inc$-Posc2) [
                  set SumWEEEInConsumers (sum [weeeinconsumer] of consumers with [maininterest = 2]
                                 + sum [weeeinconsumer] of consumers with [maininterest = 1]
                                 + sum [weeeinconsumer] of consumers with [maininterest = 4])
                  if SumWEEEInConsumers <= 10 [set WEEEnotdelivered (sum [weeeinconsumer] of consumers with [maininterest = 3])  
                  user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]
           [if (not Inc$-Posc1 and not Inc$-Posc2) and (not PSA-Posc1 and not PSA-Posc2) [
                    set SumWEEEInConsumers (sum [weeeinconsumer] of consumers with [maininterest = 1]
                                           + sum [weeeinconsumer] of consumers with [maininterest = 4])
                    if SumWEEEInConsumers <= 10 [set WEEEnotdelivered (sum [weeeinconsumer] of consumers with [maininterest = 2]
                                                          + sum [weeeinconsumer] of consumers with [maininterest = 3])  
                    user-message "Agotado potencial de entrega de RAEE en consumidores" stop]]
              ]]][]]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   No more CAP in producers/distributors   ;;;;;;;;;;;;;;;
    if [cooperative-actionP] of Producer 0 <= 0 or [cooperative-actionP] of Producer 1 <= 0
     [set WEEEnotdelivered WEEEnotdelivered + (sum [WEEEInConsumer] of consumers with [maininterest = 1]) + 
                 (sum [WEEEInConsumer] of consumers with [maininterest = 2]) + (sum [WEEEInConsumer] of consumers with [maininterest = 3])  
      set PosibleCausa "PD"
      user-message "Fallo de programa posconsumo por energía de cooperación baja o en productor o en distribuidor" 
      stop] 
    if [cooperative-actionD] of distributor 2 <= 0 or [cooperative-actionD] of distributor 3 <= 0 
     [set WEEEnotdelivered WEEEnotdelivered + (sum [WEEEInConsumer] of consumers with [maininterest = 1]) + 
                 (sum [WEEEInConsumer] of consumers with [maininterest = 2]) + (sum [WEEEInConsumer] of consumers with [maininterest = 3])  
      set PosibleCausa "PD"
      user-message "Fallo de programa posconsumo por energía de cooperación baja o en productor o en distribuidor" 
      stop]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;to plot-resourcesBag
;  set-current-plot "ResourcesBagSTS"
;  set-current-plot-pen "System1"
;  plot [ResourcesBag] of STSs 4
;  set-current-plot-pen "System2"
;  plot [ResourcesBag] of STSs 5
;end

to plot-WEEEinSTS 
  set-current-plot "# RAEE en Posconsumo"
  set-current-plot-pen "ProgPosc1"
  plot [WEEEinSTS] of STSs 4
  set-current-plot-pen "ProgPosc2"
  plot [WEEEinSTS] of STSs 5
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   "punishments" - motivation in producers  ;;;;;;;;;;;;;;
to PotentialPunishment
 if ticks = 52 [
      ask STSs 4 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.05) > [WEEEinSTS] of STSs 4   ;; chequeo en cada sistema, WEEE en consumidores repartido por igual ;;;;;;;;
       [ask Producers with [TakeBackSystem = 1] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0]
             ][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 0 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [set cooperative-actionP cooperative-actionp - 10]   ;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionP - 20]
             [ set cooperative-actionP cooperative-actionP - 20
               ]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;          
           if [punishments] of producer 0 > 0 [set acumulated acumulated + [weeeinsts] of STSs 4]]  ;para potential polution
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 1] [set cooperative-actionP cooperative-actionP + 5]]]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
      ask STSs 5 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.05) > [WEEEinsTS] of STSs 5 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 2] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 1 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionP - 20 ]
             [ set cooperative-actionP cooperative-actionP - 20]]  ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;            
           if [punishments] of producer 1 > 0 [set acumulated acumulated + [weeeinsts] of STSs 5]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 2] [set cooperative-actionP cooperative-actionP + 5]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
       ]]]
if ticks = 105 [
      ask STSs 4 [ifelse ((SumWEEEInConsumersInitial / 2) * 0.10) > [WEEEinSTS] of STSs 4 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 1] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 0 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionP - 20 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;           
           if [punishments] of producer 0 > 0 [set acumulated acumulated + [weeeinsts] of STSs 4]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 1] [set cooperative-actionP cooperative-actionP + 5]]]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
      ask STSs 5 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.10) > [WEEEinSTS] of STSs 5 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
          ask Producers with [TakeBackSystem = 2] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 1 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionP - 20 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;            
           if [punishments] of producer 1 > 0 [set acumulated acumulated + [weeeinsts] of STSs 5]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 2] [set cooperative-actionP cooperative-actionP + 5]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
       ]]]
if ticks = 157 [
      ask STSs 4 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.15) > [WEEEinSTS] of STSs 4 [  ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 1] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 0 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionP - 20 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;            
           if [punishments] of producer 0 > 0 [set acumulated acumulated + [weeeinsts] of STSs 4]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 1] [set cooperative-actionP cooperative-actionP + 5]]]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
      ask STSs 5 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.15) > [WEEEinSTS] of STSs 5 [  ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 2] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 1 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionP - 20 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;            
           if [punishments] of producer 1 > 0 [set acumulated acumulated + [weeeinsts] of STSs 5]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 2] [set cooperative-actionP cooperative-actionP + 5]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
       ]]]
if ticks = 206 [
      ask STSs 4 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.20) > [WEEEinSTS] of STSs 4 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 1] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incen tives ;;;; 
           ask producer 0 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionp - 10 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;
           if [punishments] of producer 0 > 0 [set acumulated acumulated + [weeeinsts] of STSs 4]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 1] [set cooperative-actionP cooperative-actionP + 5]]]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
      ask STSs 5 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.20) > [WEEEinSTS] of STSs 5 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 2] [
           ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 1 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]           ;;;;;;;;;;;;;que solo sean algunos desmotiva mas  ;;;;;;;;;;;;;;;
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionp - 10 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;            
           if [punishments] of producer 1 > 0 [set acumulated acumulated + [weeeinsts] of STSs 5]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 2] [set cooperative-actionP cooperative-actionP + 5]   ;;;;; cumplir meta motiva ;;;;;;;;;;;;;
       ]]]
if ticks = 261 [
      ask STSs 4 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.25) > [WEEEinSTS] of STSs 4 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 1] [ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 0 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]                                                      ;; que solo sean algunos desmotiva mas
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionp - 10 ]
             [ set cooperative-actionP cooperative-actionP - 20]]                                                  ;; que sean todos desmotiva menos           
           if [punishments] of producer 0 > 0 [set acumulated acumulated + [weeeinsts] of STSs 4]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 1] [set cooperative-actionP cooperative-actionP + 5]]]                 ;; comply the goal increases the motivation 
      ask STSs 5 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.25) > [WEEEinSTS] of STSs 5 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 2] [ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]  ;; q le cueste mas si no pone $ para incentives
           ask producer 1 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]                                                       ;; que solo sean algunos desmotiva mas
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionp - 10 ]
             [ set cooperative-actionP cooperative-actionP - 20]]   ;;;;;;;;;;;;;que sean todos desmotiva menos   ;;;;;;;;;;;;;;;;;;;            
           if [punishments] of producer 1 > 0 [set acumulated acumulated + [weeeinsts] of STSs 5]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 2] [set cooperative-actionP cooperative-actionP + 5]                    ;; comply the goal increases the motivation 
       ]]]
if ticks = 313 [
      ask STSs 4 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.30) >  [WEEEinSTS] of STSs 4 [ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 1] [ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]   ;;;q le cueste mas si no pone $ para incentives
           ask producer 0 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]                                                          ;; que solo sean algunos desmotiva mas
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[set cooperative-actionP cooperative-actionp - 10]
             [ set cooperative-actionP cooperative-actionP - 20]]                                                     ;; que sean todos desmotiva menos             
           if [punishments] of producer 0 > 0 [set acumulated acumulated + [weeeinsts] of STSs 4]]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]]
       [ask Producers with [TakeBackSystem = 1] [set cooperative-actionP cooperative-actionP + 5]]]                   ;; comply the goal increases the motivation 
      ask STSs 5 [ifelse 
       ((SumWEEEInConsumersInitial / 2) * 0.30) >  [WEEEinSTS] of STSs 5[ ;; chequeo en cada sistema colectivo, WEEE en consumidores repartido por igual ;;;;;;;;
         ask Producers with [TakeBackSystem = 2] [ifelse not Inc$-Posc1 [set ResourcesP ResourcesP - 30
             if OrigenDeLaCooperacion = "Sin Regulacion" and not Inc$-Posc1 [set ResourcesP resourcesp + 20 set ReporterPenalties 0
               ]][set ResourcesP ResourcesP - 20
               if OrigenDeLaCooperacion = "Sin Regulacion" [set ResourcesP ResourcesP + 20 set ReporterPenalties 0]]  ;; q le cueste mas si no pone $ para incentives ;;;; 
           ask producer 1 [set punishments punishments + 1] 
           ifelse OrigenDeLaCooperacion = "Algunos RAEE regulados" [
           set cooperative-actionP cooperative-actionp - 10]                                                          ;; que solo sean algunos desmotiva mas
             [ifelse OrigenDeLaCooperacion = "Todos los RAEE regulados"[
                 set cooperative-actionP cooperative-actionp - 10 ]
             [ set cooperative-actionP cooperative-actionP - 20]                                                      ;; que sean todos desmotiva menos
              ]            
           if [punishments] of producer 1 > 0 [set acumulated acumulated + [weeeinsts] of STSs 5]
           ]
         ifelse OrigenDeLaCooperacion != "Sin Regulacion" [set Penalties Penalties + 1 set ReporterPenalties Penalties][set ReporterPenalties 0]
         ]
       [ask Producers with [TakeBackSystem = 2] [set cooperative-actionP cooperative-actionP + 5]                     ;; comply the goal increases the motivation
       ]]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to PotentialPolution                                                                                                 ;; WEEE that have not been delivered 
   set potencialcontaminacionNotDelivering ((sum [WEEEinConsumer] of consumers) * 100 ) / 805
end

to Movement-PD
   ask producers [ifelse cooperative-actionP >= 80 [set GlobalLocal 1 setxy (8 + random 6) (11 + random 5) ]
         [set GlobalLocal 0 setxy (-8 + random 6) (11 + random 5)]]
   ask distributors [ifelse cooperative-actionD >= 80 [set GlobalLocal 1 setxy (8 + random 6) (11 + random 5)]
         [set GlobalLocal 0 setxy (-8 + random 6) (11 + random 5)]]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     END OF THE CODE     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
723
26
1143
467
16
16
12.42424242424243
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
7
105
195
159
1. Implemente Alianza Inicial
SetUp
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
7
54
191
99
OrigenDeLaCooperacion
OrigenDeLaCooperacion
"Algunos RAEE regulados"
0

BUTTON
444
102
521
135
Operación
STSDynamics
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
3
193
429
324
Motivación para cooperar en Productores y Distribuidores
Semanas
%
0.0
60.0
0.0
100.0
true
true
"" ""
PENS
"ProdPosc1" 1.0 0 -16777216 true "" "plot CooperativeACtionProducerSystem1"
"DistrPosc1" 1.0 0 -7500403 true "" "plot CooperativeACtionDistributorSystem1"
"ProdPosc2" 1.0 0 -2674135 true "" "plot CooperativeACtionProducerSystem2"
"DistrPosc2" 1.0 0 -955883 true "" "plot CooperativeACtionDistributorSystem2"

PLOT
431
193
720
323
# RAEE en Posconsumo
Semanas
Un
0.0
60.0
0.0
40.0
true
true
"" ""
PENS
"ProgPosc1" 1.0 0 -16777216 true "" ""
"ProgPosc2" 1.0 0 -2674135 true "" ""

BUTTON
225
101
438
170
2. Implemente Estrategias Posconsumo
STSImplementation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
12
18
187
48
Estado regulatorio para iniciar la cooperación
12
14.0
1

TEXTBOX
230
10
596
42
Seleccione Incentivos para cada Programa Posconsumo
13
14.0
1

TEXTBOX
728
10
1137
40
Prod.-Distrib. Menos Activos               |             Prod.-Distrib. Más Activos
12
0.0
1

MONITOR
3
448
111
493
% Total Entregados
WEEEDelivered * 100 / 800
0
1
11

BUTTON
444
138
521
171
Operación
STSDynamics
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
302
28
402
61
PSA-Posc1
PSA-Posc1
0
1
-1000

SWITCH
302
67
402
100
PSA-Posc2
PSA-Posc2
0
1
-1000

MONITOR
116
461
195
502
RAEE Unidades
[WEEEinSTS] of STSs 4
0
1
10

PLOT
2
326
428
446
Brecha máxima entre motivación Produc. - Distrib.
Semanas
Un
0.0
60.0
0.0
100.0
true
true
"" ""
PENS
"Br.Maxima" 1.0 0 -2674135 true "" "plot MaxGapCAPPD"

MONITOR
564
150
664
191
#RAEE Inicial Total
SumWEEEInConsumersInitial
0
1
10

SWITCH
404
28
503
61
Inc$-Posc1
Inc$-Posc1
0
1
-1000

SWITCH
404
67
503
100
Inc$-Posc2
Inc$-Posc2
0
1
-1000

MONITOR
488
449
603
494
Brecha Motivación P-D
MaxGapCAPPD
0
1
11

PLOT
431
326
719
446
Contaminación Potencial Total
Semanas
%
0.0
60.0
0.0
50.0
true
true
"" ""
PENS
"NoEntreg" 1.0 0 -7858858 true "" "plot potencialcontaminacionNotDelivering"

TEXTBOX
183
177
545
195
Dinámica durante la Operación de los Programas Posconsumo
13
72.0
1

MONITOR
605
449
719
494
%Contamin.Pot.Total
potencialcontaminacionNotDelivering
1
1
11

TEXTBOX
608
32
724
100
PSA : Apoyo a Proyecto Socio Ambiental\nInc$ : incentivo económico a consum.\nDifus : Disfusión información a consum.
9
0.0
1

MONITOR
437
449
487
494
Años
ticks / 4 / 12
1
1
11

TEXTBOX
759
470
850
488
Consumidores:
13
0.0
1

TEXTBOX
872
481
919
509
No\nEntregan
11
0.0
1

TEXTBOX
932
473
1009
501
Verde\noscuro     .....
10
54.0
1

TEXTBOX
1004
474
1038
502
Verde\nClaro
10
65.0
1

TEXTBOX
1048
489
1094
507
Entregan
11
0.0
1

TEXTBOX
149
447
412
475
Posconsumo 1                                 Posconsumo 2
11
0.0
1

MONITOR
275
462
356
503
RAEE Unidades
[WEEEinSTS] of STSs 5
17
1
10

MONITOR
359
462
416
503
RAEE %
[WEEEinSTS] of STSs 5 * 100 / 800
1
1
10

MONITOR
197
461
254
502
RAEE %
[WEEEinSTS] of STSs 4 * 100 / 800
1
1
10

MONITOR
564
106
664
147
# de Consumidores
count consumers
0
1
10

TEXTBOX
668
144
718
187
Cada consumidor inicia con 5 RAEE
9
0.0
1

SWITCH
505
29
604
62
DifusPosc1
DifusPosc1
0
1
-1000

SWITCH
505
67
604
100
DifusPosc2
DifusPosc2
0
1
-1000

TEXTBOX
232
42
298
84
Posconsumo1\n\nPosconsumo2
11
0.0
1

MONITOR
495
495
577
540
punishments
[punishments] of producer 0
0
1
11

MONITOR
582
496
680
541
punishcments 2
[punishments] of producer 1
0
1
11

@#$#@#$#@
## Presentación  y conceptos

Durante el proceso de diseño participativo de la política nacional para la gestión integral de RAEE en Colombia, se ha venido trabajando el concepto de “enfoque sistémico” como la inclusión de los siguientes factores, en de toma de decisiones:
i.	Diferentes fases dentro de la gestión integral
ii.	Intereses y puntos de vista de diferentes actores
iii.	Diferentes dimensiones (técnica, ambiental, social, política, económica, institucional)
iv.	Relaciones causales (lineales y circulares) entre efectos de las decisiones tomadas

Adicional al concepto de enfoque sistémico, como marco teórico de la presente actividad, se plantean las siguientes definiciones:

•	Programa Posconsumo: para la presente actividad se entenderá como programa posconsumo a la estrategia integrada por una urna que se dispondrá físicamente en puntos de venta de equipos, y unas opciones de incentivos enfocados a influenciar a los consumidores, y así, la cantidad de RAEE recolectados 

•	Cooperación: Para la presente actividad se entenderá como cooperación al cumplimiento de las actividades que diferentes actores deberían ejecutar para, entre todos, lograr una gestión de RAEE más sostenible. Para el ejemplo aplicado específico que consiste en programas posconsumo ubicados en puntos de venta, con o sin incentivos de cara al consumidor, se simularán sólo algunas de las actividades necesarias por parte de productores, distribuidores y consumidores, así:

o	Productores: apoyar económicamente los incentivos a consumidores, los cuales formarían parte integral del programa posconsumo
o	Distribuidores: apoyar al sistema disponiendo de un espacio físico en el que se instalen las urnas de recolección de los equipos, y almacenarlos temporalmente entre las recolecciones
o	Consumidores: Entregar los RAEE que están en su poder, a través de las urnas dispuestas en puntos de venta

## OBJETIVO

Con base en información recopilada en campo, la simulación COOP4SWEEEM-1.0  muestra escenarios cooperativos Productor-Distribuidor para lograr la recolección de RAEE desde consumidores (ciudadanos) de AEE, a través de la implementación de dos programas posconsumo ubicados físicamente en puntos de venta de equipos, en el marco del principio de Responsabilidad Extendida al Productor

## USO

PASO 1: Implemente la alianza inicial para la cooperación entre productor – distribuidor, bajo el contexto regulatorio actual de Colombia

PASO 2: A continuación, diseñe los dos programas posconsumo, escogiendo entre ON y OFF según los escenarios que desea simular

PASO 3: Implemente los dos programas posconsumo con el botón correspondiente. 

PASO 4: Luego de implementar los dos programas posconsumo de inicio a la etapa de operación, para lo que encontrará dos botones: en la parte izquierda de la figura, la simulación continuará sola hasta detenerse por completo, mientras que con la de la derecha, con cada click la simulación avanzará solo un “tick” que representa una semana

En cada corrida puede variar la ubicación de productores y distribuidores en las áreas de mayor o menor actividad, así como la distribución espacial de las dos urnas y de los consumidores
 
## RESULTADOS

Gráficas de la izquierda: Durante la operación, podrá visualizar la dinámica de cooperación entre productores y distribuidores, la cual es función de la motivación de cada agente: para los distribuidores la mayor motivación es que se acerquen consumidores a entregar RAEE pues son potenciales clientes en sus negocios, lo cual evalúa semanalmente. Para los productores, la motivación en este modelo es función del porcentaje de RAEE recolectados cada año. Adicionalmente se grafica la brecha máxima que semana a semana va presentándose entre la motivación para la cooperación en productores y distribuidores de los dos programas posconsumo

Gráficas de la derecha: Muestran la dinámica de recepción de RAEE, semana a semana, en cada urna (cada programa posconsumo). En función de los RAEE no entregados por los consumidores se muestra una potencial contaminación, con el objetivo de representar potenciales impactos como:
-	Residuos que los consumidores no entregan y que podrían entregar al sector informal, o entregar mezclados con residuos ordinarios. 
-	 En este mismo sentido, podrían presentarse RAEE en los espacios públicos.
-	Los RAEE acopiados en las urnas de los programas posconsumo, pero que pasado un año no han sido recolectados, podrían generar impactos en los espacios físicos de distribuidores que instalan las urnas, así como podrían salir hacia la línea informal de gestión.

Al final de cada corrida, oprima el botón “Halt” (“Detener”) en el mensaje que le informa que la simulación ha terminado

## CREDITOS

Simulación del modelo conceptual Coop4SWEEEM, diseñado por Sandra Méndez Fajardo, con la revisión y asesoría de Rafael González Rivera (Pontificia Universidad Javeriana, Bogotá, Colombia), Claudia Rebeca Binder y Christian Neuwirth (Ludwig-Maximilian University, Munich, Alemania), y Heinz Böni (Swiss Laboratory for Materials, Science and Technology, EMPA, St Gallen, Suiza)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

orbit 1
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 false true 41 41 218

orbit 2
true
0
Circle -7500403 true true 116 221 67
Circle -7500403 true true 116 11 67
Circle -7500403 false true 44 44 212

orbit 3
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 true true 26 176 67
Circle -7500403 true true 206 176 67
Circle -7500403 false true 45 45 210

orbit 4
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 true true 116 221 67
Circle -7500403 true true 221 116 67
Circle -7500403 false true 45 45 210
Circle -7500403 true true 11 116 67

orbit 5
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 true true 13 89 67
Circle -7500403 true true 178 206 67
Circle -7500403 true true 53 204 67
Circle -7500403 true true 220 91 67
Circle -7500403 false true 45 45 210

orbit 6
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 true true 26 176 67
Circle -7500403 true true 206 176 67
Circle -7500403 false true 45 45 210
Circle -7500403 true true 26 58 67
Circle -7500403 true true 206 58 67
Circle -7500403 true true 116 221 67

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
