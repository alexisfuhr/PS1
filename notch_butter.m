function [b,a] = notch_butter(frecuencia, frecuencia_muestreo,delta, Nb)
    % Esta funcion crea un filtro notch IIR con butter.
    % Entrada:
    %   frecuencia: frecuencia que se elimina
    %   muestreo: la frecuencia de muestreo de la señal (para normalizar de 0 a pi)
    %   delta: el filtro atenua las frecuencias desde
    %   delta hasta frecuencia+deltanotch, segun el orden del
    %   Nb: orden del filtro (recordar que el largo es L = N+1)
    % Salida:
    %   a: denominador 
    %   b: numerador
    %   sys: tf del filtro
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lim1 = (frecuencia - delta*frecuencia)/(frecuencia_muestreo/2);
    lim2 = (frecuencia + delta*frecuencia)/(frecuencia_muestreo/2);
    k = [ lim1 lim2];
    [b,a] = butter(Nb,k,'stop');
    %freqz(b,a)
end

