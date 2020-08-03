%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                          Trabajo practico                               %
%                      Procesamiento de señales                           %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
%Formato de los graficos
formato = '-dpng';

% Cargo la respuesta impulsiva de h_sys.mat me devuelve una variable 'h'
h = load('h_sys.mat');
tiempo = 16;
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

%Transformada de fourier del filtro
[Hd_notch_iir,w] = freqz(b_notch_iir,a_notch_iir,2^19);

%Transformada de fourier de los tonos
fft_tonos = fft(tono_final,2^20)/size(tono_final,2)*2;
fft_tonos = fft_tonos(1:floor(end/2));
f_tonos = (0:size(fft_tonos,2)-1)/size(fft_tonos,2)*frecuencia_muestreo/2;

%Dibuja grafico
fig = figure;
hold
plot(w/pi*frecuencia_muestreo/2,20*log(abs(Hd_notch_iir))/log(10),'LineWidth',3),grid
plot(f_tonos,20*log(abs(fft_tonos))/log(10),'LineWidth',3);

xlim([100 900])
ylim([-60 20])
title('Respuesta en frecuencia del filtro notch IIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]')
legend({'Filtro notch IIR','Interferencias'},'Location','northwest')
print(fig,'img/grafico_notch_iir',formato)

%Dibuja grafico con zoom
fig = figure;
hold

plot(w/pi*frecuencia_muestreo/2,20*log(abs(Hd_notch_iir))/log(10),'LineWidth',3),grid
plot(f_tonos,20*log(abs(fft_tonos))/log(10),'LineWidth',3);

xlim([206 214])
ylim([-60 20])
title('Respuesta en frecuencia del filtro notch IIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]')
legend({'Filtro notch IIR','Interferencias'},'Location','northwest')
print(fig,'img/grafico_notch_iir_zoom',formato)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filtro notch FIR

%Crea el filtro notch
%Esta ajustado para que atenuacion de -34 db en las frecuencias y que
%tengan una separacion de 4Hz por ser el 1% de 400Hz que es alrededor de
%donde se encuentran
[b_notch_fir,a_notch_fir] = notchfir([210 375 720],frecuencia_muestreo,2,@hamming,176400);

%Crea el segundo notch fir que tiene menor orden
[b_notch_fir_2,a_notch_fir_2] = notchfir([210 375 720],frecuencia_muestreo,2,@hamming,44100);

%Transformada de fourier del filtro
[Hd_notch_fir,w] = freqz(b_notch_fir,a_notch_fir,2^18);

%Transformada de fourier del otro filtro
[Hd_notch_fir_2,w] = freqz(b_notch_fir_2,a_notch_fir_2,2^18);

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
print(fig,'img/grafico_notch_fir',formato)

%Dibuja grafico con zoom
fig = figure;
hold
plot(w/pi*frecuencia_muestreo/2,20*log(abs(Hd_notch_fir))/log(10),'LineWidth',3),grid
plot(f_tonos,20*log(abs(fft_tonos))/log(10),'LineWidth',3);

xlim([206 214])
ylim([-60 20])
title('Respuesta en frecuencia del filtro notch FIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]') 
legend({'Filtro notch FIR','Interferencias'},'Location','northwest')
print(fig,'img/grafico_notch_fir_zoom',formato)

%Dibuja grafico del 2
fig = figure;
hold
plot(w/pi*frecuencia_muestreo/2,20*log(abs(Hd_notch_fir_2))/log(10),'LineWidth',3),grid
plot(f_tonos,20*log(abs(fft_tonos))/log(10),'LineWidth',3);

xlim([100 900])
ylim([-60 20])
title('Respuesta en frecuencia del filtro notch FIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]') 
legend({'Filtro notch FIR','Interferencias'},'Location','northwest')
print(fig,'img/grafico_notch_fir_2',formato)

%Dibuja grafico del 2 con zoom
fig = figure;
hold
plot(w/pi*frecuencia_muestreo/2,20*log(abs(Hd_notch_fir_2))/log(10),'LineWidth',3),grid
plot(f_tonos,20*log(abs(fft_tonos))/log(10),'LineWidth',3);

xlim([206 214])
ylim([-60 20])
title('Respuesta en frecuencia del filtro notch FIR')
xlabel('Frecuencia [Hz]')
ylabel('Amplitud [db]') 
legend({'Filtro notch FIR','Interferencias'},'Location','northwest')
print(fig,'img/grafico_notch_fir_2_zoom',formato)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filtro equalizador FIR

%Crea el fir inverso
[b_ecualizador_fir,a_ecualizador_fir] = inversefir(h.h,@rectwin,176,10000);

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
ylabel('Ganancia [db]') 
legend({'Ecualizador FIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/grafico_ecualizador_fir',formato)

%Dibuja grafico solo del error
fig = figure;
plot(w_electroacustico/pi*frecuencia_muestreo/2,20*log(abs(Hd_electroacustico.*Hd_ecualizador_fir))/log(10),'LineWidth',3);
grid

%xlim([0 22050])
%ylim([-15 25])
title('Respuesta en frecuencia del sistema total')
xlabel('Frecuencia [Hz]')
ylabel('Ganancia [db]') 
%legend({'Ecualizador FIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/grafico_ecualizador_fir_total',formato)

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
print(fig,'img/phasedelay_ecualizador_fir',formato)

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
print(fig,'img/pzmap_electroacustico',formato)

%Diagrama de polos y ceros del fase minima
H_fase_minima = tf(a_ecualizador_iir,b_ecualizador_iir,1/41000);

fig = figure;
pzmap(H_fase_minima);
title('Diagrama de polos y ceros del sistema fase mínima')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_fase_minima',formato)

%Diagrama de polos y ceros del pasa todo
H_pasa_todo = tf(b_pasa_todo,a_pasa_todo,1/41000);

fig = figure;
pzmap(H_pasa_todo);
title('Diagrama de polos y ceros del sistema pasa todo')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_pasa_todo',formato)

%Diagrama de polos y ceros del inverso
H_ecualizador_iir = tf(b_ecualizador_iir,a_ecualizador_iir,1/41000);

fig = figure;
pzmap(H_ecualizador_iir);
title('Diagrama de polos y ceros del sistema ecualizador')
xlabel('Parte real')
ylabel('Parte imaginaria') 
print(fig,'img/pzmap_ecualizador_iir',formato)

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
ylabel('Ganancia [db]') 
legend({'Ecualizador IIR','Sistema electroacústico','Total'},'Location','northwest')
print(fig,'img/grafico_ecualizador_iir',formato)

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
print(fig,'img/phasedelay_ecualizador_iir',formato)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Efectos numéricos
a_total = conv(a_notch_iir,a_ecualizador_iir);
b_total = conv(b_notch_iir,b_ecualizador_iir);

%Longitudes de punto fijo
w1 = 16;
w2 = 6;
w3 = 3;

%Punto fijo 1
a_total_1 = round(a_total*2^w1)/2^w1;
b_total_1 = round(b_total*2^w1)/2^w1;

%Punto fijo 2
a_total_2 = round(a_total*2^w2)/2^w2;
b_total_2 = round(b_total*2^w2)/2^w2;

%Punto fijo 3
a_total_3 = round(a_total*2^w3)/2^w3;
b_total_3 = round(b_total*2^w3)/2^w3;

[Hd_total,w_total] = freqz(b_total,a_total,2^16);
[Hd_total_1,w_total_1] = freqz(b_total_1,a_total_1,2^16);
[Hd_total_2,w_total_2] = freqz(b_total_2,a_total_2,2^16);
[Hd_total_3,w_total_3] = freqz(b_total_3,a_total_3,2^16);

%Grafico
fig = figure;
hold
grid
plot(w_total/pi*frecuencia_muestreo/2,20*log(abs(Hd_total))/log(10),'LineWidth',3);
plot(w_total_1/pi*frecuencia_muestreo/2,20*log(abs(Hd_total_1))/log(10),'LineWidth',3);
plot(w_total_2/pi*frecuencia_muestreo/2,20*log(abs(Hd_total_2))/log(10),'LineWidth',3);
plot(w_total_3/pi*frecuencia_muestreo/2,20*log(abs(Hd_total_3))/log(10),'LineWidth',3);

%xlim([100 900])
ylim([-15 25])
title('Respuesta en frecuencia')
xlabel('Frecuencia [Hz]')
ylabel('Ganancia [db]') 
legend({'Filtro original','W = 16','W = 6','W = 3'},'Location','northeast')
print(fig,'img/grafico_numerico_bode',formato)

%Grafico
fig = figure;
hold
grid
plot(w_total/pi*frecuencia_muestreo/2,20*log(abs(Hd_total))/log(10),'LineWidth',3);
plot(w_total_1/pi*frecuencia_muestreo/2,20*log(abs(Hd_total_1))/log(10),'LineWidth',3);

%xlim([100 900])
ylim([-15 25])
title('Filtro original vs W = 16')
xlabel('Frecuencia [Hz]')
ylabel('Ganancia [db]') 
legend({'Filtro original','W = 16'},'Location','northeast')
print(fig,'img/grafico_numerico_bode_1',formato)

%Grafico
fig = figure;
hold
grid
plot(w_total/pi*frecuencia_muestreo/2,20*log(abs(Hd_total))/log(10),'LineWidth',3);
plot(w_total_2/pi*frecuencia_muestreo/2,20*log(abs(Hd_total_2))/log(10),'LineWidth',3);

%xlim([100 900])
ylim([-15 25])
title('Filtro original vs W = 6')
xlabel('Frecuencia [Hz]')
ylabel('Ganancia [db]') 
legend({'Filtro original','W = 6'},'Location','northeast')
print(fig,'img/grafico_numerico_bode_2',formato)

%Grafico
fig = figure;
hold
grid
plot(w_total/pi*frecuencia_muestreo/2,20*log(abs(Hd_total))/log(10),'LineWidth',3);
plot(w_total_2/pi*frecuencia_muestreo/2,20*log(abs(Hd_total_3))/log(10),'LineWidth',3);

%xlim([100 900])
ylim([-15 25])
title('Filtro original vs W = 3')
xlabel('Frecuencia [Hz]')
ylabel('Ganancia [db]') 
legend({'Filtro original','W = 3'},'Location','northeast')
print(fig,'img/grafico_numerico_bode_3',formato)

%Grafico de polos y ceros 1
fig = figure;
hold
grid
plot(real(roots(b_total)),imag(roots(b_total)),'bo');
plot(real(roots(a_total)),imag(roots(a_total)),'bx');

plot(real(roots(b_total_1)),imag(roots(b_total_1)),'ro');
plot(real(roots(a_total_1)),imag(roots(a_total_1)),'rx');

%xlim([100 900])
%ylim([-15 25])
title('Polos y ceros filtro original vs W = 16')
xlabel('Parte real')
ylabel('Parte imaginaria') 
legend({'Ceros filtro original','Polos filtro original','Ceros con W = 16','Polos con W = 16'},'Location','northeast')
print(fig,'img/grafico_numerico_pzmap_1',formato)

%Grafico de polos y ceros 2
fig = figure;
hold
grid
plot(real(roots(b_total)),imag(roots(b_total)),'bo');
plot(real(roots(a_total)),imag(roots(a_total)),'bx');

plot(real(roots(b_total_2)),imag(roots(b_total_2)),'ro');
plot(real(roots(a_total_2)),imag(roots(a_total_2)),'rx');

%xlim([100 900])
%ylim([-15 25])
title('Polos y ceros filtro original vs W = 6')
xlabel('Parte real')
ylabel('Parte imaginaria') 
legend({'Ceros filtro original','Polos filtro original','Ceros con W = 6','Polos con W = 6'},'Location','northeast')
print(fig,'img/grafico_numerico_pzmap_2',formato)

%Grafico de polos y ceros 2
fig = figure;
hold
grid
plot(real(roots(b_total)),imag(roots(b_total)),'bo');
plot(real(roots(a_total)),imag(roots(a_total)),'bx');

plot(real(roots(b_total_3)),imag(roots(b_total_3)),'ro');
plot(real(roots(a_total_3)),imag(roots(a_total_3)),'rx');

%xlim([100 900])
%ylim([-15 25])
title('Polos y ceros filtro original vs W = 3')
xlabel('Parte real')
ylabel('Parte imaginaria') 
legend({'Ceros filtro original','Polos filtro original','Ceros con W = 3','Polos con W = 3'},'Location','northeast')
print(fig,'img/grafico_numerico_pzmap_3',formato)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%