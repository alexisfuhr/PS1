%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          Trabajo practico                               %
%                      Procesamiento de señales                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all

% Cargo la respuesta impulsiva de h_sys.mat me devuelve una variable 'h'
h = load('h_sys.mat');

frecuencia_muestreo = 44100;

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
% Aca empieza el TP                               %
% Tenemos en signal el audio pasado por la        %
% transferencia y la interferencia                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro notch IIR
N=2;
mycomb = zeros(3,(2*N+1)*2);

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
%notch_final = sos(mycomb,tono_final);

% En las variables a1, a2, a3 tengo los coeficientes del denumerador del notch para cada
% frecuencia
% En las variables b1, b2, b3 tengo los coeficientes del numerador del notch para cada
% frecuencia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filtro notch FIR

%Crea el filtro notch
%Esta ajustado para que atenuacion de -34 db en las frecuencias y que
%tengan una separacion de 4Hz por ser el 1% de 400Hz que es alrededor de
%donde se encuentran
[b_notch_fir,a_notch_fir] = notchfir([210 375 720],frecuencia_muestreo,4,@hamming,16500);

%Transformada de fourier del filtro
[Hd_notch_fir,w] = freqz(b_notch_fir,a_notch_fir,2^16);

%Transformada de fourier de los tonos
fft_tonos = fft(tono_final,2^20)/size(tono_final,2)*2;
fft_tonos = fft_tonos(1:floor(end/2));
f_tonos = (0:size(fft_tonos,2)-1)/size(fft_tonos,2)*frecuencia_muestreo/2;

%Dibuja grafico
fig = figure;
hold
plot(w/pi*frecuencia_muestreo/2,20*log(abs(Hd_notch_fir))/log(10),'LineWidth',3),grid
plot(f_tonos,20*log(abs(fft_tonos))/log(10),'LineWidth',3);

xlim([100 900])
ylim([-60 20])
title('Respuesta en frecuencia del filtro notch FIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]') 
legend({'Filtro notch FIR','Interferencias'},'Location','northwest')
print(fig,'img/grafico_notch_fir','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro equalizador FIR

%Crea el fir inverso
[b_ecualizador_fir,a_ecualizador_fir] = inversefir(h.h,@hamming,228,1000);

%Calcula respuestas en frecuencias
[Hd_ecualizador_fir,w_ecualizador_fir] = freqz(b_ecualizador_fir,a_ecualizador_fir,2^16);
[Hd_electroacustico,w_electroacustico] = freqz(h.h,[1 zeros(1,size(h.h,2)-1)],2^16);

%Dibuja grafico
fig = figure;
hold
grid
plot(w_ecualizador_fir/pi*frecuencia_muestreo/2,20*log(abs(Hd_ecualizador_fir))/log(10),'LineWidth',3);
plot(w_electroacustico/pi*frecuencia_muestreo/2,20*log(abs(Hd_electroacustico))/log(10),'LineWidth',3);
plot(w_electroacustico/pi*frecuencia_muestreo/2,20*log(abs(Hd_electroacustico.*Hd_ecualizador_fir))/log(10),'LineWidth',3);

%xlim([100 900])
ylim([-15 25])
title('Respuesta en frecuencia del ecualizador FIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]') 
legend({'Ecualizador FIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/grafico_ecualizador_fir','-dpng')

%Retardo de fase
puntos = 2^16; %Puntos en el grafico
[phi_ecualizador,w_ecualizador] = phasedelay(b_ecualizador_fir,a_ecualizador_fir,puntos); %Ecualizador
[phi_electroacustico,w_electroacustico] = phasedelay(h.h,[1 zeros(1,size(h.h,2)-1)],puntos); %Electroacustico
[phi_total,w_total] = phasedelay(conv(b_ecualizador_fir,h.h),conv(a_ecualizador_fir,[1 zeros(1,size(h.h,2)-1)]),puntos); %Total

fig = figure;
hold
grid
plot(w_ecualizador/pi*frecuencia_muestreo/2,phi_ecualizador,'LineWidth',3);
plot(w_electroacustico/pi*frecuencia_muestreo/2,phi_electroacustico,'LineWidth',3);
plot(w_total/pi*frecuencia_muestreo/2,phi_total,'LineWidth',3);

ylim([40 200])
title('Retardo de fase')
xlabel('Frecuencia [Hz]')
ylabel('Retardo [muestras]') 
legend({'Ecualizador FIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/phasedelay_ecualizador_fir','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro equalizador IIR
%Crea el iir inverso
[b_ecualizador_iir,a_ecualizador_iir,b_pasa_todo,a_pasa_todo] = inverseiir(h.h);

%Calcula respuestas en frecuencias
[Hd_ecualizador_iir,w_ecualizador_iir] = freqz(b_ecualizador_iir,a_ecualizador_iir,2^16);
[Hd_electroacustico,w_electroacustico] = freqz(h.h,[1 zeros(1,size(h.h,2)-1)],2^16);

%Diagrama de polos y ceros del electroacustico
H_electroacustico = tf(h.h,[1 zeros(1,size(h.h,2)-1)],1/41000);

fig = figure;
pzmap(H_electroacustico);
title('Diagrama de polos y ceros del sistema electroacústico')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_electroacustico','-dpng')

%Diagrama de polos y ceros del fase minima
H_fase_minima = tf(a_ecualizador_iir,b_ecualizador_iir,1/41000);

fig = figure;
pzmap(H_fase_minima);
title('Diagrama de polos y ceros del sistema fase mínima')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_fase_minima','-dpng')

%Diagrama de polos y ceros del pasa todo
H_pasa_todo = tf(b_pasa_todo,a_pasa_todo,1/41000);

fig = figure;
pzmap(H_pasa_todo);
title('Diagrama de polos y ceros del sistema pasa todo')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_pasa_todo','-dpng')

%Diagrama de polos y ceros del inverso
H_ecualizador_iir = tf(b_ecualizador_iir,a_ecualizador_iir,1/41000);

fig = figure;
pzmap(H_ecualizador_iir);
title('Diagrama de polos y ceros del sistema ecualizador')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_ecualizador_iir','-dpng')

%Dibuja grafico
fig = figure;
hold
grid
plot(w_ecualizador_iir/pi*frecuencia_muestreo/2,20*log(abs(Hd_ecualizador_iir))/log(10),'LineWidth',3);
plot(w_electroacustico/pi*frecuencia_muestreo/2,20*log(abs(Hd_electroacustico))/log(10),'LineWidth',3);
plot(w_electroacustico/pi*frecuencia_muestreo/2,20*log(abs(Hd_electroacustico.*Hd_ecualizador_iir))/log(10),'LineWidth',3);

%xlim([100 900])
ylim([-15 25])
title('Respuesta en frecuencia del ecualizador IIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]') 
legend({'Ecualizador IIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/grafico_ecualizador_iir','-dpng')

%Retardo de fase
puntos = 2^16; %Puntos en el grafico
[phi_ecualizador,w_ecualizador] = phasedelay(b_ecualizador_iir,a_ecualizador_iir,puntos); %Ecualizador
[phi_electroacustico,w_electroacustico] = phasedelay(h.h,[1 zeros(1,size(h.h,2)-1)],puntos); %Electroacustico
[phi_total,w_total] = phasedelay(conv(b_ecualizador_iir,h.h),conv(a_ecualizador_iir,[1 zeros(1,size(h.h,2)-1)]),puntos); %Total

fig = figure;
hold
grid
plot(w_ecualizador/pi*frecuencia_muestreo/2,phi_ecualizador,'LineWidth',3);
plot(w_electroacustico/pi*frecuencia_muestreo/2,phi_electroacustico,'LineWidth',3);
plot(w_total/pi*frecuencia_muestreo/2,phi_total,'LineWidth',3);

ylim([-10 80])
title('Retardo de fase')
xlabel('Frecuencia [Hz]')
ylabel('Retardo [muestras]') 
legend({'Ecualizador IIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/phasedelay_ecualizador_iir','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%