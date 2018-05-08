function [u,v ] = fgenturb(dim, Kmin, Kmax, moy)

% Boucle sur u et v
for p=1:2
    % On initialise
    Y = zeros(dim);
    C111=Y; C121=Y; C221=Y; C211=Y;

    %% On crée le beignes
    % On met k-1 et l-1 car MATLAB part l'itération a 1 ---> nb onde 0 = k(1) - 1
    for k=-Kmax:Kmax
        for l=-Kmax:Kmax
            for m=0:Kmax;
                % L'un des coin contient les index k,l=0
                if sqrt(k^2 + l^2 + m^2) >= Kmin
                    if sqrt(k^2 + l^2 + m^2) <= Kmax
                        clear i;
                        % On crée la coquille dans le coin
                        Y((dim(1)/2)+k, (dim(2)/2)+l , (dim(3)/2)+m) = ...
                            rand(1) * exp(i*rand(1));
                    end
                end
            end
        end
    end
    
    
    %% On le sépare en cartier
    % Les coins du bas
    
    % Coin (111)
    C111(1:(dim(1)/2)+1, 1:(dim(2)/2)+1, 1:(dim(3)/2)+1 ) = ...
        Y((dim(1)/2):dim(1), dim(2)/2 :dim(2), (dim(3)/2):dim(3));
    % Coin (211)
    C211((dim(1)/2)+2:dim(1),1:(dim(2)/2)+1, 1:(dim(3)/2)+1) =...
        Y(1:(dim(1)/2)-1, dim(2)/2 :dim(2),(dim(3)/2):dim(3));
    % Coin (121)
    C121(1:(dim(1)/2)+1,(dim(2)/2)+2:dim(2), 1:(dim(3)/2)+1) =...
        Y((dim(1)/2):dim(1), 1:(dim(2)/2)-1,(dim(3)/2):dim(3));
    %Coin  (221)
    C221((dim(1)/2)+2:dim(1),(dim(2)/2)+2:dim(2), 1:(dim(3)/2)+1) =...
        Y(1:(dim(1)/2)-1, 1:(dim(2)/2)-1,(dim(3)/2):dim(3));
    
    
    % La matrice traité en fourrier
    Y2 = C111 + C121 + C211 + C221;
    
    
    %% On passe dans l'espace réel
    uimag= ifftn(Y2,'symmetric');
    % Les vitesses
    vel = abs(uimag);
    % On normalise par la moyenne désiré
    vel = (vel / mean(mean(mean(vel)))) * moy;
    
    % On enregistre ceci pour nos deux composante
    if p==1
        u=vel;
    else
        v=vel;
    end
end
 

end
