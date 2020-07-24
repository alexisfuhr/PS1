function [b,a] = inversefir(hd0,ventana,N,aproximacion)
    % Devuelve un filtro fir FLG de orden N inverso al filtro de la
    % respuesta al impulso.
    % Entrada:
    %   hd0: vector con la respuesta al impulso del filtro que se desa
    %   invertir
    %   ventana: con esto se ventanea al filtro inversor ideal
    %   N: orden del filtro (recordar que el largo es L = N+1)
    %   aproximacion: la cantidad de puntos que toma de la respuesta en
    %   frecuencia del filtro original para aproximar su inversa (conviene
    %   poner que este numero sea 1000 o una cosa asi)
    % Salida:
    %   a: denominador 
    %   b: numerador
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ej: [b,a] = inversefir(h_sys.h,@hamming,100,1000);
    
    %Respuesta en frecuencia del filtro que se desa invertir evaluada en la
    %cantidad de puntos seteados en la variable "aproximacion"
    [Hd0,w] = freqz(hd0,[1 zeros(1,size(hd0,2)-1)],aproximacion);
    
    %Respuesta en frecuencia del filtro inversor ideal
    Hd = 1./abs(Hd0);
    
    %Respuesta en el tiempo del filtro inversor ideal truncado
    n = 0:N;
    hd = Hd(1)*exp(j*w(1)*n)/2;
    for i = 2:aproximacion
        hd = hd + Hd(i)*exp(-j*w(i)*(n-N/2))/2 + conj(Hd(i))*exp(j*w(i)*(n-N/2))/2;
    end
    hd = hd/aproximacion;
    
    %Ventaneado del filtro ideal
    w1 = window(ventana, N+1)';
    hd = hd.*w1;
    
    b = hd;
    a = [1 zeros(1,size(hd,2)-1)];

    %Descomentar para que grafique respuesta al impulso
    %figure
    %stem(n,hd),grid
     
    %Descomentar para que grafique la respuesta en frecuencia en veces
    %figure
    %[Hd,w] = freqz(hd,1,aproximacion);
    %plot(w/pi,abs(Hd)),grid
    %hold
    %plot(w/pi,abs(Hd0));
end