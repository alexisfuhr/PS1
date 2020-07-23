%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          Trabajo practico                               %
%                      Procesamiento de señales                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% transferencia y la interferencia                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=2;
mycomb = zeros(3,(2*N+1)*2);
% Filtro Notch
Q = 10;
% Filtro la frecuencia f1 = 210
[b1,a1,sys1] = notch(210, frecuencia_muestreo, Q, N);
mycomb(1,:) = [b1,a1];

% Filtro la frecuencia f2 = 375
[b2,a2,sys2] = notch(375, frecuencia_muestreo, Q, N);
mycomb(2,:) = [b2,a2];

% Filtro la frecuencia f3 = 720
[b3,a3,sys3] = notch(720, frecuencia_muestreo, Q , N);
mycomb(3,:) = [b3,a3];

% Como queda el tono final cuando le paso los Notch's
notch_final = sos(mycomb,tono_final);

plot(notch_final)

% En las variables a1, a2, a3 tengo los coeficientes del denumerador del notch para cada
% frecuencia
% En las variables b1, b2, b3 tengo los coeficientes del numerador del notch para cada
% frecuencia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filtro equalizador




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aca va a estar el audio filtrado

Destino = conv(signal,Notch,'same');
Destino = conv(Destino,equalizador,'same');

% Guardo el audio resultante
filename = 'destino.wav';
audiowrite(filename,Destino,frecuencia_muestreo);

