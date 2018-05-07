% Ce script affiche les vitesses u ,v, w 
clear all
close all

F = dir('*.data');

y = 60;  % valeur du plan 

% On load les données initiales
A = rdmds(F(1).name(1:end-5));
% On load les données initiales
B = rdmds(F(end).name(1:end-5));
% Dimension des matrices
[m,n,o,p] = size(A);

itera = F(1).name(end-8:end-5);
iterb = F(end).name(end-8:end-5);

%%  ----------------- PLOT ---------------------------
titleg = {'U iter ', 'W iter '};
for i=1:2
    h(i)= subplot(2,2,i);
    imagesc(reshape(A(:,y,:,1), m,o));
    xlabel('X') ; ylabel('Z');
    title([titleg{i} num2str(itera)])
    axis square; axis tight;
    colorbar;
    
    h(i+2) = subplot(2, 2,i+2);
    imagesc(reshape(B(:,y,:,1), m,o));
    xlabel('X') ; ylabel('Z');
    title([titleg{i} num2str(iterb)])
    axis square; axis tight;
    colorbar;
end


enr=1;
    if enr==1
    % Dimensions de la figure sur papier (en cm) 
    paperwidth  = 30;
    paperheight = 20;
    
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperSize',[paperwidth paperheight]);
    set(gcf,'PaperPosition',[0 0 paperwidth paperheight]); 
    savename = ['uw_iter_' itera '_' iterb];
    print('-r150','-dpng', '.png')
    end
