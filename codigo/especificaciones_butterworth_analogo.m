function [N, w0] = especificaciones_butterworth_analogo(dp,ds,wp,ws)
    D = sqrt(((1-dp)^(-2)-1)/(ds^(-2)-1));
    K = wp/ws;
    
    N = log(1/D)/log(1/K);
    N = max(ceil(N),1);
    
    w01 = wp*((1-dp)^(-2)-1)^(-1/(2*N));
    w02 = ws*(ds^(-2)-1)^(-1/(2*N));
    
    w0 = (w01+w02)/2;
end