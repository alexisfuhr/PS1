function [b,a] = notch(frecuencia,muestreo, N)
% Esta funcion crea un filtro notch.
% Entrada:
%   frecuencia: frecuencia que se elimina
%   muestreo: la frecuencia de muestreo de la señal (para normalizar de 0 a pi)
%   N: orden del butter
% Salida:
%   a: denominador 
%   b: numerador
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notch con la funcion butter 
    w0 = frecuencia/(muestreo/2);   % frecuencia anulada
    dw = (frecuencia*0.05)/(muestreo/2);
    lim1 = w0 - dw;         % limite inferior
    lim2 = w0 + dw;         % limite superior
    
    [b,a] = butter(N,[lim1 lim2],'stop');

%    fvtool(sys,'Analysis','freq')
    
end

