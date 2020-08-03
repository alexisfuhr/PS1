%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          Trabajo practico                               %
%                      Procesamiento de señales                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all

% Defino variables globales
tiempo = 16;
% Cargo la respuesta impulsiva de h_sys.mat me devuelve una variable 'h'
h = load('h_sys.mat');
% Cargo el audio
 filename = 'audio\pista_01.wav';
%filename = 'audio\pista_02.wav';
%filename = 'audio\pista_03.wav';
%filename = 'audio\pista_04.wav';
%filename = 'audio\pista_05.wav';
%filename = 'audio\pista_06.wav';
%filename = 'audio\pista_07.wav';
%filename = 'audio\pista_08.wav';

[audio,frecuencia_muestreo] = audioread(filename);
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hago la convolucion entre mi señal de audio y la respuesta impulsiva
signal = conv(audio',h.h','same');

% Sumo la interferencia en signal
signal = signal + tono_final;

% Guardo el audio con la interferencia
filename = 'audio_salida\audio_interferencia.wav';
audiowrite(filename,signal,frecuencia_muestreo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aca empieza el TP                               %
% Tenemos en signal el audio pasado por la        %
% transferencia y la interferencia                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro notch IIR
% Filtro la frecuencia f1 = 210
[b1,a1,sys1] = notchiir(210+[-2 -0.01 0.01 2],44100,0.02,0.122,0.122);

% Filtro la frecuencia f2 = 375
[b2,a2,sys2] = notchiir(375+[-2 -0.01 0.01 2],44100,0.02,0.122,0.122);

% Filtro la frecuencia f3 = 720
[b3,a3,sys3] = notchiir(720+[-2 -0.01 0.01 2],44100,0.02,0.122,0.122);

%Transferencia total
b_notch_iir = [1];
b_notch_iir = conv(b_notch_iir,b1);
b_notch_iir = conv(b_notch_iir,b2);
b_notch_iir = conv(b_notch_iir,b3);

a_notch_iir = [1];
a_notch_iir = conv(a_notch_iir,a1);
a_notch_iir = conv(a_notch_iir,a2);
a_notch_iir = conv(a_notch_iir,a3);

% En las variables a_notch_iir y b_notch_iir tengo los coeficientes del
% denominador y numerador respectivamente
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filtro notch FIR
%Crea el filtro notch
%Esta ajustado para que atenuacion de -34 db en las frecuencias y que
%tengan una separacion de 4Hz
[b_notch_fir,a_notch_fir] = notchfir([210 375 720],frecuencia_muestreo,4,@hamming,16500);

%Transformada de fourier del filtro
[Hd_notch_fir,w] = freqz(b_notch_fir,a_notch_fir,2^16);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro equalizador FIR

%Crea el fir inverso
[b_ecualizador_fir,a_ecualizador_fir] = inversefir(h.h,@rectwin,176,10000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro equalizador IIR
%Crea el iir inverso
[b_ecualizador_iir,a_ecualizador_iir] = inverseiir(h.h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filtrado de audio

a_notch_iir_ecualizador_iir = conv(a_notch_iir,a_ecualizador_iir);
b_notch_iir_ecualizador_iir = conv(b_notch_iir,b_ecualizador_iir);

a_notch_fir_ecualizador_fir = conv(a_notch_fir,a_ecualizador_fir);
b_notch_fir_ecualizador_fir = conv(b_notch_fir,b_ecualizador_fir);

%Guardo el audio resultante fir
filename = 'audio_salida\sonido_filtrado_notch_fir_ecualizador_fir.wav';
salida =  filter(b_notch_fir_ecualizador_fir,a_notch_fir_ecualizador_fir,signal);
audiowrite(filename,salida,frecuencia_muestreo);

%Guardo el audio resultante iir
filename = 'audio_salida\sonido_filtrado_notch_iir_ecualizador_iir.wav';
salida =  filter(b_notch_iir_ecualizador_iir,a_notch_iir_ecualizador_iir,signal);
audiowrite(filename,salida,frecuencia_muestreo);
