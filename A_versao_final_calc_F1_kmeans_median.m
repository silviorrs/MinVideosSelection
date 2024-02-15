% Esta é a versão mais recente que resultou no artigo EXPert System and Applications
% Calcula a medida que vai definir o potencial de avaliação de cada vídeo
% A medida é : calcula a mediana) dos TP, TN e FP e FN dos 30 algorimos utilizados na fase de geração da medida
% Gera a mediano do F-score (possivelmente outras métricas tb), que será a medida de potencial de avaliação do vídeo.

clear;
ResVideos = readtable('DadosAlgoritmosNoMap.xlsx','Sheet','VideosMap');
ResVideosName = readtable('DadosAlgoritmosNoMap.xlsx','Sheet','List');


ResDef = readtable('DadosAlgoritmosNoMap.xlsx','Sheet','Overall_Definicao');
OrdemDefinicao_ID_Original = ResDef{:,1}; % faz a leitura dos dados dos algoritmos para definição
OrdemDefinicao_FmeasureOrig = ResDef{:,9};

Ordem_ID_Alg = [OrdemDefinicao_ID_Original OrdemDefinicao_FmeasureOrig];
Ordem_ID_Alg = sortrows(Ordem_ID_Alg, -2);

OrdemDefinicao_FmeasureOrig = Ordem_ID_Alg(:,2);
OrdemDefinicao_ID_Original = Ordem_ID_Alg(:,1);

ResOrd = readtable('DadosAlgoritmosNoMap.xlsx','Sheet','Overall_Validacao');
OrdemIDValidacao = ResOrd{:,1}; %faz a leitura dos dados para validação
OrdemFmeasureValidacao = ResOrd{:,9};

Ordem_ID_Alg_val = [OrdemIDValidacao OrdemFmeasureValidacao];
Ordem_ID_Alg_val = sortrows(Ordem_ID_Alg_val,-2);

OrdemIDValidacao = Ordem_ID_Alg_val(:,1);
OrdemFmeasureValidacao = Ordem_ID_Alg_val(:,2);


%Carrega vídeos validação
ResVideosValidacao = readtable('DadosAlgoritmosNoMap.xlsx','Sheet','Videos');

ValidPixels = ResVideos{:,[1,      5,    23]};


                             %algID  vidId  TP  FP  FN  TN  FMeas
DataAtributos = ResVideos{:,[1,      5,     8,  9 , 10, 11, 18]};
DataAtributosVal = ResVideosValidacao{:,[1,      5,     8,  9 , 10, 11, 18]};

DataAtributos = sortrows(DataAtributos,[2,1]); % ordenar pelo vídeo e depois pelo algoritmo
DataAtributosVal = sortrows(DataAtributosVal,[2,1]); 

DataName = ResVideosName.Var1;

numVideosOriginais = 53;
numAlgDef = size(DataAtributos,1)/numVideosOriginais;

%*********** Calcula a mediana para TP FP FN TN dos 53 videos considerando os 30 algoritmos ************

medianVideo = [];
ValidFinal = [];
 for i=1:size(DataAtributos,1)
        if (mod(i,numAlgDef)==0)
            
            % Calcula a mediana de cada video das medidas TP FP FN TN (armazena o ID do vídeo na primeira coluna)
            medianVideo = [medianVideo; DataAtributos(i,2), median(DataAtributos(i+1-numAlgDef:i,3)),median(DataAtributos(i+1-numAlgDef:i,4)),...
                                    median(DataAtributos(i+1-numAlgDef:i,5)),median(DataAtributos(i+1-numAlgDef:i,6))...
                                    
                                    
                                    ];          
            % pega a quantidade de pixels válidos de cada um dos 53 vídeos
            % armazena o ID do vídeo na primeira coluna
            ValidFinal = [ValidFinal; ValidPixels(i,2) ValidPixels(i,3)];
                                
        end
 end
 
 TPa= medianVideo(:,2); % Mediana dos verdadeiros positivos para cada vídeo
 FPa = medianVideo(:,3);% Mediana dos falsos positivos para cada vídeo
 FNa = medianVideo(:,4);% Mediana dos falsos Negativos para cada vídeo
 TNa = medianVideo(:,5);% Mediana dos verdadeiros negativos para cada vídeo
 
 
 % Calcula 7 metricas para cada vídeo considerando as 30 medianas usando TP,
 % FP, FN e TN
  
 for i=1:size(medianVideo,1)
   Recalla(i) = TPa(i) / (TPa(i)+FNa(i));
   
   Spa(i) = TNa(i) / (TNa(i) + FPa(i));
   
   FPRa(i) = FPa(i) / (FPa(i) + TNa(i));  
   
   FNRa(i) = FNa(i) / (TPa(i) + FNa(i));
   
   PWCa(i) = 100 * (FNa(i) + FPa(i)) / (TPa(i) + FNa(i) + FPa(i) + TNa(i));
   
   Precisiona(i) = TPa(i) / (TPa(i) + FPa(i));
   
   FMeasurea(i) = (2 * Precisiona(i) * Recalla(i)) / (Precisiona(i) + Recalla(i));  
 end
 
 medianVideo = [medianVideo, Recalla', Spa', FPRa', FNRa', PWCa', FMeasurea', Precisiona' ];
 
 % FmeasureMedian é o potencial de avaliação do vídeo
  
 % Armazena em FmeasureMedian (para os 53 videos):
 % - ID do vídeo
 % - F-measure calculado usando a mediana dos 30 algoritmos (fmeasure do vídeo)
 % - FPR calculado usando a mediana dos 30 algoritmos (FPR do vídeo)
 % - FNR calculado usando a mediana dos 30 algoritmos (FNR do vídeo) 
 
 PotencialFmeasureMedian = [medianVideo(:,1), medianVideo(:,7)];%, medianVideo(:,4), medianVideo(:,5)];
 PotencialFmeasureMedian = sortrows(PotencialFmeasureMedian,2);
 %FmeasureMedian = round(FmeasureMedian,4);

 ListaDosPotenciaisDosVideos = [PotencialFmeasureMedian(:,1), round(1-PotencialFmeasureMedian(:,2),4)];
 
  fprintf('Lista do Potencial de cada vídeo \n')
  for i=1:53%size(ListaDosPotenciaisDosVideos,1)
      fprintf('%s & %.4f \\\\ \n',DataName{ListaDosPotenciaisDosVideos(i,1)} , ListaDosPotenciaisDosVideos(i,2));

  end
 fprintf('\n');
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Descobrir a quantidade de grupos
 
 %%%% Fase de Definição
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 perc = [98	96	94	92	90	88	86	85	83	81	79	77	75	73	71	70	68	66	64	62	60 ...
         58	56	55	53	51	49	47	45	43	41	39	38	36	34	32	30	28	26	24	23	21	...
         19	17	15	13	11	9	8	6	4	2];
 
 lista_de_quantidade_de_videos =   [ 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 ...
         25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9  8  7  6   5 4   3 2  1 ];
 
 % PotencialFmeasureMedian é o potencial de avaliação do vídeo
 PotencialFmeasureMedian = sortrows(PotencialFmeasureMedian,1);
 
 mmFeasure = PotencialFmeasureMedian(:,2);
 
 rng(5); %configura a semente do kmeans para não ser randômico
 
 AlgoritmosFmeasureDefinicao = [];
 AlgoritmosOrdemDefinicao = [];
 FmeasureOrdemDefinicao = [];
 it = 0;
 selectedVideosDefinicao = zeros(52,52);
 for nclusters=lista_de_quantidade_de_videos
     it = it+1;
     [clusterIndex, clusterCenters] = kmeans(mmFeasure,nclusters); 
     
     out = [PotencialFmeasureMedian(:,1) clusterIndex mmFeasure];

     outsort = sortrows(out,2);

     near = inf(nclusters,2);

     %Encontra o valor de Fmeasure em cada cluster mais proximo do centro do
     %cluster (no exemplo, são 32 clusters)

     for i=1:nclusters
        for j=1:size(outsort,1)
            clus = clusterCenters(i,1);        
            if(i == outsort(j,2))
                dist = abs(clus - outsort(j,3));
                if dist < near(i)
                    near(i,1)= outsort(j,1);
                    near(i,2)= outsort(j,3);

                end
                    %near(i) = 
            end
        end
     end

     % avariável near armazena o vídeo escolhido do cluster o seu potencial (f-measure)

     % encontra o video que possui o valor de f-measure (da mediana) mais próximo do centro do cluster 
     % Retorna os 39 vídeos 
     % Seleciono os 39 vídeos que, teoricamente, avaliam da mesma forma que os 53 

     selectedVideos = near(:,1);

     FmeasureList30 = [];

     % Carrega o valor de potencial de cada video utilizado (o com fmeasure mais proximo do centroid)

     for i = 1 : size(DataAtributos,1)
        if ismember(DataAtributos(i,2), selectedVideos)
            FmeasureList30 = [FmeasureList30; DataAtributos(i,1) DataAtributos(i,2) DataAtributos(i,7)];    
        end
     end

     FmeasureList30 = sortrows(FmeasureList30,1);
     numVideos = length(selectedVideos);

     mediaSelect30 = [];

     % calcula o F-smeasure de cada um dos 30 algoritmos, considerando a
     % mediana dos f-measure dos 39 vídeos para aquele algoritmo
     % Exemplo: 
     %   Algoritmo 1 tem um valor de f-measure para cada vídeo
     %   então, eu calculo a mediana da fmeasure desse algoritmo condiderando os 39 videos 

     for i=1 : size(FmeasureList30,1)
        if(mod(i,numVideos)==0)
            mediaSelect30 = [mediaSelect30; FmeasureList30(i,1), mean(FmeasureList30(i+1-numVideos:i,3))];          
        end

     end

     % Obtenho a fmeasure (desempenho) do algoritmo quando apenas os 50, 48, 45... vídeos são utilizados

     mediaSelect30 = sortrows(mediaSelect30,-2);
     
     AlgoritmosFmeasureDefinicao = [AlgoritmosFmeasureDefinicao mediaSelect30];
     AlgoritmosOrdemDefinicao = [AlgoritmosOrdemDefinicao mediaSelect30(:,1)];
     FmeasureOrdemDefinicao = [FmeasureOrdemDefinicao mediaSelect30(:,2)];

     % Ordena os 39 vídeos selecionados
     selectedVideos = sortrows(selectedVideos,1); % os videos selecionados na iteração
     %armazena o id dos vídeos selecionados pelo k-means
     selectedVideosDefinicao(1:length(selectedVideos),it) = selectedVideos; 
 end
  
 AcertosFmeasureDefinicao = zeros(1,length(lista_de_quantidade_de_videos)); % 
 %Ordem1 = FmeasureOrdem30(:,1); % armazena os fmeasures de
 
 init = 2;
 distorig = [];

 for i=init:length(OrdemDefinicao_FmeasureOrig)
    distorig = [distorig abs(OrdemDefinicao_FmeasureOrig(i)-OrdemDefinicao_FmeasureOrig(i-(init-1)))];
 end

 B1 = rmoutliers(distorig,'quartiles');
 tolerancia = 2*max(B1);
% tolerancia = 0.0750;

   for i=1:size(FmeasureOrdemDefinicao,2)
    for j=1:size(FmeasureOrdemDefinicao,1) % percorre primeiro a linha
        %fprintf('Compara  %d com %d \n',AlgoritmosOrdem(j,i),Original(j,1));
        %if (FmeasureOrdem30(j,i) >  Ordem1(j) - tolerancia && FmeasureOrdem30(j,i) <  Ordem1(j)+tolerancia  )
        if (FmeasureOrdemDefinicao(j,i) >  OrdemDefinicao_FmeasureOrig(j) - tolerancia && FmeasureOrdemDefinicao(j,i) <  OrdemDefinicao_FmeasureOrig(j)+tolerancia  )    
            AcertosFmeasureDefinicao(i)= AcertosFmeasureDefinicao(i)+1;
        end
    end
    
   end

   AcertosFmeasureDefinicao = [lista_de_quantidade_de_videos; 100-perc; AcertosFmeasureDefinicao]';
  
   for i=1:size(AcertosFmeasureDefinicao,1)
        if(AcertosFmeasureDefinicao(i,3)< numAlgDef)
            %limiar  = AcertosFmeasureDefinicao(i-1,1);
            limiar  = AcertosFmeasureDefinicao(i,1);
            percentual = AcertosFmeasureDefinicao(i-1,2);
            fprintf('Numero de videos a ser utilizado = %d \n',limiar);
            fprintf('Redução de %d%% dos vídeos \n',percentual);
            break
        end
   end
   
   
   listVid = selectedVideosDefinicao(1:limiar,53-limiar);
   selNames = [];
   
   
  for i=1:15  
      
      if(i==15)
        fprintf('%d &  %20s \\\\ \n', listVid(i), DataName{listVid(i)}); %selNames = [selNames; DataName{listVid(i)} ];     
      else
          fprintf('%d &  %20s & %d &  %20s \\\\ \n', listVid(i), DataName{listVid(i)},listVid(i+15), DataName{listVid(i+15)}); %selNames = [selNames; DataName{listVid(i)} ];
      end
  end
   

 %**************************************************************
 % ***** Usando o kmeans para agrupar os videos ****************
 % ***** grupos de videos com base no potencial de avaliação ****
 %***************************************************************
 PotencialFmeasureMedian = sortrows(PotencialFmeasureMedian,1);
 
 %ValidFinal = sortrows(ValidFinal,1); 

 % usa também os valores de FPR e FNR como variáveis de entrada do kmeans para auxliar o agrupamento
 % Coloca as colunas fmeasure, FPR e FNR na variável mm
 %mmFeasure = [FmeasureMedian(:,2), FmeasureMedian(:,3), FmeasureMedian(:,4)];
 
 mmFeasure = PotencialFmeasureMedian(:,2);%, FmeasureMedian(:,3), FmeasureMedian(:,4)];
 
 % define o número de clusters do Kmeans (quantidade de vídeos que pretendemos utilizar)  
 %nclusters = 27; % representa 75% dos vídeos o dataset
 rng(5); %configura a semente do kmeans para não ser randômico
 
 
 
     % Agrupa os vídeos usando o kmeans, considerando como variáveis as metricas fmeasure, FPR e FNR (obtidas da mediana dos algoritmos)
     % cada grupo possui vídeos com mesmo potencial de avaliação
 
  AlgoritmosValidacaoFmeasure = [];
  AlgoritmosValidacaoOrdem = [];
  %OrdemFmeasure = [];
  
  % Calculo o numero de cluster comparo
  
  selectedVideosValidacao = zeros(52,52);
  it=0;
  for nclusters=lista_de_quantidade_de_videos
      it = it+1;
     [clusterIndex, clusterCenters] = kmeans(mmFeasure,nclusters); 

     out = [PotencialFmeasureMedian(:,1) clusterIndex mmFeasure];

     outsort = sortrows(out,2);

     near = inf(nclusters,2);

     %Encontra o valor de Fmeasure em cada cluster mais proximo do centro do
     %cluster (no exemplo, são 32 clusters)

     for i=1:nclusters
        for j=1:size(outsort,1)
            clus = clusterCenters(i,1);        
            if(i == outsort(j,2))
                dist = abs(clus - outsort(j,3));
                if dist < near(i)
                    near(i,1)= outsort(j,1);
                    near(i,2)= outsort(j,3);

                end
                    %near(i) = 
            end
        end
     end

     % avariável near armazena o vídeo escolhido do cluster o seu potencial (f-measure)

     % encontra o video que possui o valor de f-measure (da mediana) mais próximo do centro do cluster 
     % Retorna os 39 vídeos 
     % Seleciono os 39 vídeos que, teoricamente, avaliam da mesma forma que os 53 

     selectedVideos = near(:,1);

     FmeasureList = [];

     % Carrega o valor de f-measure dos 14 algoritmos utilizados na validação
     % para cada um dos 39 videos selecionados (total de 546 valores em FmeasureList)

     for i = 1 : size(DataAtributosVal,1)
        if ismember(DataAtributosVal(i,2), selectedVideos)
            FmeasureList = [FmeasureList; DataAtributosVal(i,1) DataAtributosVal(i,2) DataAtributosVal(i,7)];    
        end
     end

     FmeasureList = sortrows(FmeasureList,1);
     numVideos = length(selectedVideos);

     mediaSelect = [];

     % calcula o F-smeasure de cada um dos 14 algoritmos, considerando a
     % mediana dos f-measure dos 39 vídeos para aquele algoritmo
     % Exemplo: 
     %   Algoritmo 1 tem um valor de f-measure para cada vídeo
     %   então, eu calculo a mediana da fmeasure desse algoritmo condiderando os 39 videos 

     for i=1 : size(FmeasureList,1)
        if(mod(i,numVideos)==0)
            mediaSelect = [mediaSelect; FmeasureList(i,1), mean(FmeasureList(i+1-numVideos:i,3))];          
        end

     end

     % Obtenho a fmeasure (desempenho) do algoritmo quando apenas os 39 vídeos são utilizados

     mediaSelect = sortrows(mediaSelect,-2);
     
     AlgoritmosValidacaoFmeasure = [AlgoritmosValidacaoFmeasure mediaSelect];
     AlgoritmosValidacaoOrdem = [AlgoritmosValidacaoOrdem mediaSelect(:,1)];

     % Ordena os 39 vídeos selecionados
     selectedVideos = sortrows(selectedVideos,1);
     selectedVideosValidacao(1:length(selectedVideos),it) = selectedVideos; 
  end
  
 AcertosValidacaoFmeasure = zeros(1,52);
 
  for i=1:size(AlgoritmosValidacaoOrdem,2)
    for j=1:size(AlgoritmosValidacaoOrdem,1) % percorre primeiro a linha
        %fprintf('Compara  %d com %d \n',AlgoritmosOrdem(j,i),Original(j,1));
        %if (AlgoritmosValidacaoOrdem(j,i) == Original(j,1))
        if (AlgoritmosValidacaoOrdem(j,i) == OrdemIDValidacao(j))
            AcertosValidacaoFmeasure(i)= AcertosValidacaoFmeasure(i)+1;
        end
    end
    
  end
  
  AcertosValidacaoFmeasure = [lista_de_quantidade_de_videos; 100-perc; AcertosValidacaoFmeasure]';
  
  listAlgValid = AlgoritmosValidacaoOrdem(:,23);
  % selNames = [];
   
  for i=1:12  
      %fprintf('%d &  %20s & %d &  %20s \\\\ \n', listVid(i), DataName{listVid(i)},listVid(i+15), DataName{listVid(i+15)}); %selNames = [selNames; DataName{listVid(i)} ];
  end
   
  % Tabela comparando Orginal e Selecionados
  comp = [Ordem_ID_Alg_val AlgoritmosValidacaoFmeasure(:,45:46)];
  compBar = [comp(:,2),comp(:,4)];
  diferences = abs(comp(:,2)-comp(:,4));
    
  figure(1);
%   y = [2 3 4 ; 1 5 2; 6 2 5];
%   b = bar(y);
%   width = b.BarWidth;
%   for i=1:length(y(:, 1)) 
%     row = y(i, :);
%     % 0.5 is approximate net width of white spacings per group
%     offset = ((width + 0.5) / length(row)) / 2;
%     x = linspace(i-offset, i+offset, length(row));
%     text(x,row,num2str(row'),'vert','bottom','horiz','center');
%   end
  
%    b = bar(compBar,1.0);
%    width = b.BarWidth;
%    %compBar = round(compBar,2);
%     for i=1:length(compBar(:, 1))
%         row = abs(compBar(i, 1) - compBar(i, 2));%compBar(i, :);
%         %offset = ((width + 0) / length(row)) / 2;
%         offset = ((width + 0) / length(row))-1;
%         x = linspace(offset, i+offset, length(row));
%         text(x,compBar(i, 1),num2str(row','%.4f'),'vert','bottom','horiz','center');
%     end
  
   b = bar(compBar,1.0);
   width = b.BarWidth;
   compBar = round(compBar,2);
    for i=1:length(compBar(:, 1))
        row = compBar(i, :);
        offset = ((width + 0) / length(row)) / 2;
        %offset = ((width + 0) / length(row))-1;
        x = linspace(i-offset, i+offset, length(row));
        text(x,compBar(i, :),num2str(row','%.2f'),'vert','bottom','horiz','center');
    end
 %text(1:length(diferences),diferences,num2str(diferences'),'vert','bottom','horiz','center');
  
  %s = num2str(A,'%10.5e\n')
  set(gca, 'XTickLabel', {'FgSegNet-v2' 'BSGAN' 'Cascade CNN' 'SemanticBGS' 'SWCD' 'DeepBS' 'M4CDV2' 'AMBER' 'IUTIS-2' 'SOBS-CF' 'Multiscale BG' 'DCB'})
  xtickangle(45)
  title('Performance Comparison','fontweight','bold','fontsize',12);
  xlabel('Algorithms','fontweight','bold','fontsize',12)
  ylabel('{\boldmath$F1$}','fontweight','bold','fontsize',12,'Interpreter','latex')
  %x = AcertosValidacaoFmeasure(:,[1,3]);
  legend('$D$','$R_{g_{min}}$','interpreter','latex','fontsize',15)
  x0=10;
  y0=10;
  width=1100;
  height=450;
  set(gcf,'position',[x0,y0,width,height])
  ax = gca;
  outerpos = ax.OuterPosition;
  ti = ax.TightInset; 
  left = outerpos(1) + ti(1);
  bottom = outerpos(2) + ti(2);
  ax_width = outerpos(3) - ti(1) - ti(3);
  ax_height = outerpos(4) - ti(2) - ti(4);
  ax.Position = [left-0.002 bottom ax_width ax_height-0.09];
  
  figure(2);
  x = AcertosValidacaoFmeasure(:,1);
  y = AcertosValidacaoFmeasure(:,3);
  plot(x,y,'LineWidth',3)
  title('Comparison of rankings','fontweight','bold','fontsize',12);
  xlabel('{\boldmath$R_{g}$}','fontweight','bold','fontsize',16,'interpreter','latex')
  ylabel('Algorithms','fontweight','bold','fontsize',12)
  xlim([1 52])
  xticks(1:1:52)
  set(gca, 'XDir','reverse')
  x0=10;
  y0=10;
  width=1100;
  height=450;
  set(gcf,'position',[x0,y0,width,height])
  ax = gca;
  outerpos = ax.OuterPosition;
  ti = ax.TightInset; 
  left = outerpos(1) + ti(1);
  bottom = outerpos(2) + ti(2);
  ax_width = outerpos(3) - ti(1) - ti(3);
  ax_height = outerpos(4) - ti(2) - ti(4);
  ax.Position = [left-0.002 bottom ax_width ax_height-0.09];
    xline(29,'--','Color','r')
  legend({'$K_{D} = K_{R_{(g)}}$','$R_{g_{min}}$'},'Interpreter','latex','Location','southwest','Orientation','vertical','fontsize',16)
%set(gca, 'XTickLabel', {'52' '51' '50' 'SemanticBGS' 'SWCD' 'DeepBS' 'M4CDV2' 'AMBER' 'IUTIS-2' 'SOBS-CF' 'Multiscale BG' 'DCB'})
%  set(gca, 'XTickLabel',[52	 51	50	49	48	47	46	45	44	43	42	41	40	39	38	37	36	35	34	33	32	31	30	29	28	27	26	25	24	23	22	21	20	19	18	17	16	15	14	13	12	11	10	9	8	7	6	5	4	3	2	1]);   
%   x0=10;
%   y0=10;
%   width=1100;
%   height=450;
%   set(gcf,'position',[x0,y0,width,height])
%   ax = gca;
%   outerpos = ax.OuterPosition;
%   ti = ax.TightInset; 
%   left = outerpos(1) + ti(1);
%   bottom = outerpos(2) + ti(2);
%   ax_width = outerpos(3) - ti(1) - ti(3);
%   ax_height = outerpos(4) - ti(2) - ti(4);
%   ax.Position = [left bottom ax_width ax_height];
  

  maxVariacao = max(abs(compBar(:,2) - compBar(:,1)));
  fprintf('Maxima variacao = %f',maxVariacao);

  figure(3);
  
   Subconjuntos = AlgoritmosValidacaoFmeasure(:,(2:2:104));
  
  A = flip(Subconjuntos,2);
  boxplot(A);
  title('Distribution of the performance values in the subsets','fontweight','bold','fontsize',12);
  ylabel('{\boldmath$F1$}','fontweight','bold','fontsize',12,'Interpreter','latex');
  xlabel('{\boldmath$R_{g}$}','fontweight','bold','fontsize',16,'interpreter','latex');
  xlim([1 52])
  xticks(1:1:52)
  set(gca, 'XDir','reverse')
  x0=10;
  y0=10;
  width=1100;
  height=450;
  set(gcf,'position',[x0,y0,width,height])
  ax = gca;
  outerpos = ax.OuterPosition;
  ti = ax.TightInset; 
  left = outerpos(1) + ti(1);
  bottom = outerpos(2) + ti(2);
  ax_width = outerpos(3) - ti(1) - ti(3);
  ax_height = outerpos(4) - ti(2) - ti(4);
  ax.Position = [left-0.002 bottom ax_width ax_height-0.1];
  %y = 0.7;
  %line([1,52],[y,y])
  xline(29,'--','Color','r')
  legend({'{$R_{g_{min}}$}'},'Location','southwest','Orientation','horizontal', 'Interpreter', 'latex','fontsize', 16)
  %x = 29;
  %line([0,1],[x,x])
  
  %OrdemIDValidacao;
  
    
  
  
  pause();
  
  close all;
  %xticks(52:1);
  
 clear clus clusterCenters DataAtributos DataAtributosVal DataName ;
 clear dist FMeasurea FmeasureList FmeasureMedian FNa FNRa FPa FPRa i j lv;
 clear medianVideo mediaSelect mmFeasure nclusters near numVideos out outsort;
 clear Precisiona PWCa Recalla ResVideos ResVideosName ResVideosValidacao;
 clear Spa TNa TPa ValidFinal ValidPixels selectedVideos perc tolerancia;
 clear percentual init do distorig Ordem1 OrdemID OrdemFmeasure;
 clear B1 ResDef ResOrd numAlgDef lista_de_quantidade_de_videos clusterIndex
  
 %close all;
 
%  x = 0:5;
% y = 3 + 2*x;
% figure(1)
% subplot(2,1,1)
% plot(x, y)
% grid
% subplot(2,1,2)
% plot(x,y)
% set(gca, 'XDir','reverse')
% grid
 
