function [tono] = nuevo_tono(amplitud,frecuencia,tiempo,frecuencia_muestreo)
% Esta funcion crea un tono con una amplitud de "amplitud" y una frecuencia
% de "frecuencia. La duracion del tono esta dada por el "tiempo".

w = 2*pi*frecuencia;
t = [0:1/frecuencia_muestreo:tiempo];

% Hago el nuevo tono
tono = amplitud*sin(w*t);
% Guardo el nuevo tono
filename = ['tono_' frecuencia '_Hz.wav'];
%audiowrite(filename,tono,frecuencia_muestreo); %guardamos el sonido en .wav
% Grafico del nuevo tono
%sub_t=(1:100); 
%sub_x=tono(1:100); 
%stem(sub_t,sub_x); 
end

