function [b,a,sys] = notchfir(frecuencias,muestreo,deltanotch,ventana,N)
    % Esta funcion crea un filtro notch fir.
    % Entrada:
    %   frecuencias: vector con frecuencias para eliminar
    %   muestreo: la frecuencia de muestreo de la señal (para normalizar de 0 a pi)
    %   deltanotch: el filtro atenua las frecuencias desde
    %   frecuencia-deltanotch hasta frecuencia+deltanotch, segun el orden del
    %   filtro y la ventana, es cuanto las atenua y que tan bien respeta el
    %   delta
    %   N: orden del filtro (recordar que el largo es L = N+1)
    % Salida:
    %   a: denominador 
    %   b: numerador
    %   sys: tf del filtro
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ej: notchfir(0.5,2,0.1,@hamming,80);
    
    %Esto se basa en irle restando a un filtro pasa todo un filtro pasa
    %banda sintonizado para cada frecuencia del vector de frecuencias
    n = 0:N;
    hd1 = sinc(n-N/2); %filtro pasa todo
    for frecuencia = frecuencias
        %Especificaciones del filtro
        wc = 2*pi*frecuencia/muestreo; %frecuencia a eliminar
        wc1 = wc+2*pi*deltanotch/muestreo; %frecuencia de corte superior
        wc2 = wc-2*pi*deltanotch/muestreo; %frecuencia de corte inferior

        %Le resta un pasa bandas a lo que hay en hd1
        hd1 = hd1-wc1/pi*sinc(wc1/pi*(n-N/2))+wc2/pi*sinc(wc2/pi*(n-N/2));
    end
    
    %Ventaneo del filtro
    w1 = window(ventana, N+1)';
    hd1 = hd1.*w1;
    
    %Arma el numerador y el denominador del filtro y la tf
    b = hd1;
    a = [1 zeros(1,N)];
    sys = tf(b,a,1/muestreo);

    %Descomentar para que grafique respuesta al impulso
    %figure
    %stem(n,hd1),grid
     
    %Descomentar para que grafique la respuesta en frecuencia
    %figure
    %[Hd1,w] = freqz(hd1,1,2048);
    %plot(w/pi*muestreo/2,abs(Hd1)),grid
end