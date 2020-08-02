function [b,a,sys] = notchiir(banda,muestreo,ds,dp1,dp2)
% Esta funcion crea un filtro notch iir.
    % Entrada:
    %   banda: vector con las frecuencias de corte [ws1 wp1 wp2 ws2]
    %   muestreo: la frecuencia de muestreo de la señal (para normalizar de 0 a pi)
    %   ds: constante de atenuacion en la banda eliminada.
    %   dp1: constante de distorsion en la banda de paso de la izquierda.
    %   dp2: constante de distorsion en la banda de paso de la derecha.
    % Salida:
    %   a: denominador 
    %   b: numerador
    %   sys: tf del filtro
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ej: [b,a,sys] = notchiir([400 500 600 700],1000,0.01,0.05,0.05);
    
    tustin = @(w) tan(w/2);
    
    %Frecuencias continuas a frecuencias discretas
    ws1 = banda(1)*2*pi/muestreo;
    wp1 = banda(2)*2*pi/muestreo;
    wp2 = banda(3)*2*pi/muestreo;
    ws2 = banda(4)*2*pi/muestreo;

    %Pretransformacion de frecuencias para antidistorsion del tustin
    ws1 = tustin(ws1);
    wp1 = tustin(wp1);
    wp2 = tustin(wp2);
    ws2 = tustin(ws2);

    %Transformacion a especificaciones pasa bajo
    dp = min(dp1,dp2);
    ds = ds;

    w0 = sqrt(wp1*wp2);
    B = wp2-wp1;

    wp = 1;
    ws = min(abs((ws1*B)/(ws1^2-w0^2)),abs((ws2*B)/(ws2^2-w0^2)));

    %Especificaciones pasabajos
    [N, w0lp] = especificaciones_butterworth_analogo(dp,ds,wp,ws);
    
    %Crea filtro butterworth
    k = 0:N-1;
    poloslp = w0lp*exp(j*(N+1+2*k)*pi/2/N);
    poloslp = round(poloslp,4);

    %Transformacion pasa banda
    num = [1];
    den = [1];

    for sk = poloslp
        num = conv(num,[1 0 w0^2]);
        den = conv(den,[1 -sk^-1*B w0^2]);
    end
    
    %Quita la parte residual imaginaria
    num = real(num);
    den = real(den);
    
    %Transforma la tf continua a una tf discreta por tustin
    Hc = tf(num,den);
    Hd = c2d(Hc,2,'tustin');
    
    %Toma los datos de la funcion transferencia
    [b,a] = tfdata(Hd,'v');
    sys = Hd;

    %Grafico
    %figure
    %[Hd1,w] = freqz(b,a,2048);
    %plot(w/pi*muestreo/2,abs(Hd1)),grid
end