%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          Trabajo practico                               %
%                      Procesamiento de señales                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;

% Defino variables globales
tiempo = 16;
frecuencia_muestreo =  44100;
% Cargo la respuesta impulsiva de h_sys.mat me devuelve una variable 'h'
h = load('C:\Users\Carlos\Documents\alexis\Nueva carpeta\facu\ps1\trabajo_practico\h_sys.mat');
% Cargo el audio
filename = 'C:\Users\Carlos\Downloads\pista_01.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_02.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_03.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_04.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_05.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_06.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_07.wav';
%filename = 'C:\Users\Carlos\Downloads\pista_08.wav';

% corto el audio para que dure 16 segundos.
audio = audioread(filename);
audio = audio(1:705601);
%%%%%%%%%%%%%%%%%%%%%%
% Creo los tonos puros

% Tono puro de frecuencia 210 Hz, amplitud 0.05
tono_f1 = nuevo_tono(0.05,210,tiempo,frecuencia_muestreo); 
% Tono puro de frecuencia 375 Hz, amplitud 0.03
tono_f2 = nuevo_tono(0.03,375,tiempo,frecuencia_muestreo);        
% Tono puro de frecuencia 720 Hz, amplitud 0.02
tono_f3 = nuevo_tono(0.02,720,tiempo,frecuencia_muestreo);     

% creo la funcion de interferencia con la suma de los tonos
tono_final = tono_f1 + tono_f2 + tono_f3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hago la convolucion entre mi señal de audio y la respuesta impulsiva
signal = conv(audio',h.h','same');

% Sumo la interferencia en signal
signal = signal + tono_final;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aca empieza el TP                               %
% Tenemos en signal el audio pasado por la        %
% transferencia y con la interferencia sumada     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Primero creo la transferencia del Notch y despues se lo 
% aplico a signal

% Defino el orden del Notch
N = 1500;
% Filtro Notch
% Filtro la frecuencia f1 = 210
[b1,a1,sys1] = notchfir(210,frecuencia_muestreo,0.15 * 210,@hamming,N);
% Descomentar para ver la resp en frec del notch para esa frecuencia %%%%%%
%freqz(b1, a1, 16e3, frecuencia_muestreo);
%tono_con_notch = filter(b1,a1,tono_f1);
%plot(1:705601,tono_con_notch)
% Filtro la frecuencia f2 = 375
[b2,a2,sys2] = notchfir(375,frecuencia_muestreo,0.1 * 375,@hamming,N);

% Filtro la frecuencia f3 = 720
[b3,a3,sys3] = notchfir(720,frecuencia_muestreo,0.05 * 720,@hamming,N);

% Convierto los tres notch's separados en uno solo a0,b0
% Tiene el problema que no funciona para N > 1
a = conv(a1,a2);
a0 = conv(a,a3);
b = conv(b1,b2);
b0 = conv(b,b3);

% Veo que tan bueno es el notch que hice cuando lo paso por 
% la suma de tonos 'tono_final'
freqz(b0, a0, 16e3, frecuencia_muestreo);
tono_con_notch = filter(b0,a0,tono_final);
audio_con_notch = filter(b0,a0,signal);

plot(1:705601,tono_final,1:705601,tono_con_notch)

plot(1:705601,signal,1:705601,audio_con_notch)
%**************************************************************************
%Notch IIR
Nb = 3;
delta = 0.01;
[bb1,ab1] = notch_butter(210, frecuencia_muestreo, delta, Nb);
[bb2,ab2] = notch_butter(375, frecuencia_muestreo, delta + 0.01, Nb);
[bb3,ab3] = notch_butter(720, frecuencia_muestreo, delta, Nb);
bf1 = conv(bb1,bb3);
%bf = conv(bf1,bb2);
af1 = conv(ab1,ab3);
%af = conv(af1,ab2);
freqz(bf1,af1)
% Analisis subjetivo
% Señal con interferencia
sound(signal, frecuencia_muestreo)
% Señal con interferencia filtrada
sound(audio_con_notch, frecuencia_muestreo)
% Señal original
sound(audio, frecuencia_muestreo)

% En las variables a1, a2, a3 ,a0 (notch final) tengo los coeficientes del denumerador del notch para cada
% frecuencia
% En las variables b1, b2, b3 ,b (notch final) tengo los coeficientes del numerador del notch para cada
% frecuencia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filtro equalizador




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aca va a estar el audio filtrado


% Audio_con_notch 
%Destino = conv(Destino,equalizador,'same');

% Guardo el audio resultante
%filename = 'destino.wav';
%audiowrite(filename,Destino,frecuencia_muestreo);

