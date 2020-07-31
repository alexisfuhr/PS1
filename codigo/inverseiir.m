function [b,a,bap,aap] = inverseiir(hd0)
    % Devuelve un filtro iir de fase mínima inverso al filtro de la
    % respuesta al impulso.
    % Entrada:
    %   hd0: vector con la respuesta al impulso del filtro que se desa
    %   invertir
    % Salida:
    %   b: numerador del filtro inversor (denominador del fase minima)
    %   a: denominador del filtro inversor (numerador del fase minima)
    %   bap: numerador del pasa todo
    %   aap: denominador del pasa todo
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ej: [b,a] = inverseiir(h_sys.h);
    
    %Ceros del sistema que se quiere invertir
    c0 = roots(hd0);
    a0 = hd0(1); %Constante que multiplica las raices
    
    %Ceros de fase minima
    cmin = c0.*(abs(c0)<1);
    cmin = nonzeros(cmin);
    
    %Ceros de fase maxima
    cmax = c0.*(abs(c0)>1);
    cmax = nonzeros(cmax);
    
    %Polos del sistema inverso fase minima
    pmin = [cmin;1./cmax];
    
    %Polos del sistema inverso
    a = a0*prod(cmax)*poly(pmin);
    b = 1;
    
    %Pasa todo
    aap = poly(1./cmax)*prod(cmax);
    bap = poly(cmax);
    
    %Descomentar para que grafique la respuesta en frecuencia en veces
    %figure
    %[Hd1,w] = freqz(b,a,2^8);
    %plot(w/pi,abs(Hd1)),grid
    %hold
    %[Hd2,w] = freqz(hd0,1,2^8);
    %plot(w/pi,abs(Hd2))
    
    %Descomentar para que grafique el pasatodo
    %figure
    %[Hd3,w] = freqz(bap,aap,2^8);
    %plot(w/pi,abs(Hd3))
    
    %Descomentar para que grafique la respuesta en frecuencia total
    %figure
    %plot(w/pi,abs(Hd1).*abs(Hd2))
end
