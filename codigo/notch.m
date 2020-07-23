function [b,a,sys] = notch(frecuencia,muestreo,Q, N)
% Esta funcion crea un filtro notch.
% Entrada:
%   frecuencia: frecuencia que se elimina
%   muestreo: la frecuencia de muestreo de la señal (para normalizar de 0 a pi)
%   Q: factor de atenuacion
%   N: orden del butter
% Salida:
%   a: denominador 
%   b: numerador
%   sys: seria la funcion de transferencia con el zpk del butter 
%       como no lo tengo hecho devuelvo 1 (para que no me tire error).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notch con la funcion IIRnotch 
    w0 = frecuencia/(muestreo/2);   % frecuencia anulada
    bw = w0/Q;                      % 
    [bb,aa] = iirnotch(w0,bw);

% Creo nuestro filtro con el filtro butter
    %N                  % Orden del filtro
    % Defino la banda a suprimir (cambiando el .25 modificas la caida)
    lim1 = (frecuencia - frecuencia*.05)/(muestreo/2);
    lim2 = (frecuencia + frecuencia*.05)/(muestreo/2);
    % Se usa [z,p,k] porque [b,a] puede traer problemas de redondeo N > 4
    [b,a] = butter(N,[lim1 lim2],'stop');
    sys =1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Descomentando esto se ve el grafico que compara IIRnotch y butter
    % Ahi que comentar de la linea 14 a la 22
    %N = 1                 % Orden del filtro
    % Defino la banda a suprimir
    %lim1 = (frecuencia - frecuencia*.05)/(muestreo/2);
    %lim2 = (frecuencia + frecuencia*.05)/(muestreo/2);
    %[z,p,k] = butter(30,[lim1 lim2],'stop');  
    %sys = zpk(z,p,k);
    %bode(sys)
    % Muestro y comparo la respuesta de los dos filtros
    %hfvt = fvtool(b,a,sos,'FrequencyScale','log');
    %legend(hfvt,'IIrnotch','ZPK Butter')
    %sys = zpk(z,p,k,muestreo);
    
    % Esta forma no se si se puede usar (nose si es fir)
    bsFilt = designfilt('bandstopiir','FilterOrder',20, ...
         'HalfPowerFrequency1',frecuencia - 0.1* frecuencia,'HalfPowerFrequency2',frecuencia +0.1* frecuencia, ...
         'SampleRate',muestreo);
    fvtool(bsFilt)
    
end

