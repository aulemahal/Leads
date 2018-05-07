% Ce script affiche les vitesses u ,v, w 
clear all
close all

%% Valeur initiale et finale
y = 60;  % valeur du plan 


%% On cr�e une image pour chaque it�ration
F = dir('*.data');

for i=1:numel(F)
disp(['Save figure ' num2str(i) ' / ' num2str(numel(F))]);    
h = figure('Visible','off');
% On load la matrice
A = rdmds(F(i).name(1:end-5));
% On check les dimensions
[m,n,o,p] = size(A);
% On v�rifie si le dossier mov exite sinon on le cr�e
if 7 ~= exist('mov','dir') mkdir mov; end 

% L'image
imagesc(reshape(A(:,y,:,1), m,o));

% On d�finie le chemin d'enregistrement
savename=['mov/' 'img_' sprintf('%04d',i) '.png'];

% On enregistre
saveas(h, savename)
end    
